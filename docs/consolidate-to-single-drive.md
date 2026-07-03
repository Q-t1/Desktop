# Consolidating onto a single system drive

## Background

This machine shipped with a stale duplicate install. Two NVMe drives carried
**identical GPT partition labels** (`disk-disk1-esp`, `disk-disk1-luksroot`), so
`/dev/disk/by-partlabel/...` resolved nondeterministically at boot — causing the
random "can't find drive, retry" failures and passphrase prompts.

Layout before consolidation:

| Drive     | Size  | p1 (ESP)          | p2 (LUKS)                    | Role                    |
|-----------|-------|-------------------|------------------------------|-------------------------|
| nvme0n1   | 931 G | `C867-B087`       | LUKS `bcc56ded…` (stale)     | held `/boot` only       |
| nvme1n1   | 465 G | `3A91-FD6D`       | LUKS `8e7dc6dc…` → pool/root | **the running system**  |

**Target:** keep `nvme1n1` (465 G) as the sole, self-contained system drive
(ESP + LUKS + root all on it) and repurpose `nvme0n1` (931 G) as a games/data drive.

Stable IDs used by the flake:
- Root LUKS header UUID: `8e7dc6dc-bd69-4632-84d3-b127051c0e54` (`nvme1n1p2`)
- New `/boot` ESP partuuid: `74a0c4b2-4359-48a4-9286-8afd40ce6d5d` (`nvme1n1p1`)

The config in this repo already targets that end state. The steps below perform the
one-time, stateful disk operations. **Do them in order. Do not skip the reboot
verification before wiping `nvme0n1`.**

---

## Phase 1 — TPM auto-unlock (kills the passphrase prompt)

Enroll the TPM into the *real* root LUKS header (one-time, stateful — cannot be
declarative):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs= \
  /dev/disk/by-uuid/8e7dc6dc-bd69-4632-84d3-b127051c0e54
```

Verify a `systemd-tpm2` token now exists:

```bash
sudo cryptsetup luksDump /dev/disk/by-uuid/8e7dc6dc-bd69-4632-84d3-b127051c0e54 | grep -A3 -i token
```

Keep your passphrase keyslot as a fallback — do **not** remove it.

---

## Phase 2 — Relocate /boot onto the system drive (nvme1n1p1)

The old `/boot` on `nvme0n1p1` stays intact as a fallback until Phase 3, so this is
recoverable.

```bash
# 1. Fresh-format the system drive's own ESP (GPT type stays EF00; partuuid unchanged)
sudo mkfs.vfat -F 32 -n BOOT /dev/nvme1n1p1

# 2. Swap /boot over to the new ESP
sudo umount /boot
sudo mount /dev/nvme1n1p1 /boot

# 3. Rebuild: lanzaboote signs + installs the bootloader onto the new ESP and
#    creates a matching UEFI boot entry (the flake now pins /boot to nvme1n1p1).
sudo nixos-rebuild switch --flake .#desktop

# 4. Confirm a boot entry pointing at the new ESP exists and is first in BootOrder
sudo efibootmgr -v
```

If `efibootmgr` shows the new Linux Boot Manager entry, **reboot now.**

### Verification checkpoint (must pass before Phase 3)

After reboot, confirm:

```bash
findmnt /boot        # SOURCE must be /dev/nvme1n1p1
findmnt /            # /dev/mapper/pool-root, backed by nvme1n1p2
lsblk /dev/nvme0n1   # only the OLD esp+luks, NOT providing /boot or /
```

You should reach the desktop **without a passphrase prompt and without retries.**
If boot fails, the old ESP on `nvme0n1p1` is still bootable — pick it in the UEFI
boot menu, then investigate. **Do not proceed until this checkpoint passes.**

---

## Phase 3 — Wipe nvme0n1 and set it up as the games/data drive

Only after Phase 2 verification passes. This **destroys everything on nvme0n1**,
including the stale duplicate install and the old `/boot`.

```bash
# 1. Nuke partition table + all filesystem/LUKS signatures (also clears the
#    duplicate partition labels for good)
sudo wipefs -a /dev/nvme0n1
sudo sgdisk --zap-all /dev/nvme0n1

# 2. Single GPT data partition spanning the whole disk
sudo sgdisk -n 1:0:0 -t 1:8300 -c 1:games /dev/nvme0n1

# 3. ext4 with the label the flake mounts by (modules/storage.nix -> by-label/games)
sudo mkfs.ext4 -L games /dev/nvme0n1p1

# 4. Apply — mounts it at /mnt/games (nofail) and chowns to qt1
sudo nixos-rebuild switch --flake .#desktop
```

Verify:

```bash
findmnt /mnt/games   # /dev/nvme0n1p1, ext4
```

Optional cleanup — remove the dangling UEFI entry that pointed at the old ESP:

```bash
sudo efibootmgr           # find the stale entry's number (BootXXXX)
sudo efibootmgr -b XXXX -B
```

Add `/mnt/games` as a Steam library folder from Steam → Settings → Storage.

> The games drive is unencrypted for simplicity. If you want it encrypted too, it
> can be added as a LUKS volume with its own TPM keyslot later — ask and we'll wire
> it into `modules/storage.nix`.
