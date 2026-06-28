{ pkgs, lib, ... }:
let
  # Sleepy cat under a starry purple-night sky — for Quentin
  avatarQt1 = pkgs.writeText "qt1-avatar.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
      <circle cx="50" cy="50" r="50" fill="#1e1240"/>
      <circle cx="20" cy="20" r="2"   fill="#ffd700" opacity="0.8"/>
      <circle cx="80" cy="15" r="1.5" fill="#ffd700" opacity="0.6"/>
      <circle cx="85" cy="72" r="1"   fill="#ffd700" opacity="0.7"/>
      <circle cx="14" cy="63" r="1.5" fill="#ffd700" opacity="0.5"/>
      <circle cx="55" cy="10" r="1"   fill="#ffd700" opacity="0.6"/>
      <!-- ears -->
      <polygon points="26,40 32,24 40,41" fill="#e8956d"/>
      <polygon points="60,41 68,24 74,40" fill="#e8956d"/>
      <polygon points="28,40 32,27 38,41" fill="#f4b8a0"/>
      <polygon points="62,41 68,27 72,40" fill="#f4b8a0"/>
      <!-- head -->
      <ellipse cx="50" cy="57" rx="28" ry="25" fill="#e8956d"/>
      <!-- sleepy eyes (closed arcs) -->
      <path d="M 36 53 Q 42 49 48 53" stroke="#5a2e14" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <path d="M 52 53 Q 58 49 64 53" stroke="#5a2e14" stroke-width="2.5" fill="none" stroke-linecap="round"/>
      <!-- nose -->
      <ellipse cx="50" cy="62" rx="4" ry="3" fill="#df6090"/>
      <!-- mouth -->
      <path d="M 46 65 Q 50 69 54 65" stroke="#5a2e14" stroke-width="1.5" fill="none" stroke-linecap="round"/>
      <!-- whiskers -->
      <line x1="22" y1="59" x2="40" y2="62" stroke="#5a2e14" stroke-width="1" opacity="0.5"/>
      <line x1="22" y1="64" x2="40" y2="65" stroke="#5a2e14" stroke-width="1" opacity="0.5"/>
      <line x1="60" y1="62" x2="78" y2="59" stroke="#5a2e14" stroke-width="1" opacity="0.5"/>
      <line x1="60" y1="65" x2="78" y2="64" stroke="#5a2e14" stroke-width="1" opacity="0.5"/>
      <!-- zzz -->
      <text x="68" y="32" font-family="serif" font-size="11" fill="#ffd700" opacity="0.9">z</text>
      <text x="75" y="23" font-family="serif" font-size="8"  fill="#ffd700" opacity="0.7">z</text>
      <text x="80" y="16" font-family="serif" font-size="6"  fill="#ffd700" opacity="0.5">z</text>
    </svg>
  '';

  # Rosy-cheeked bunny with flowers — for Cécile
  avatarCecile = pkgs.writeText "cecile-avatar.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
      <circle cx="50" cy="50" r="50" fill="#f3e8ff"/>
      <!-- ears -->
      <ellipse cx="36" cy="30" rx="9"  ry="20" fill="#fdf0f8"/>
      <ellipse cx="64" cy="30" rx="9"  ry="20" fill="#fdf0f8"/>
      <ellipse cx="36" cy="30" rx="5.5" ry="14" fill="#ffb3d9"/>
      <ellipse cx="64" cy="30" rx="5.5" ry="14" fill="#ffb3d9"/>
      <!-- head -->
      <ellipse cx="50" cy="62" rx="26" ry="23" fill="#fdf0f8"/>
      <!-- eyes -->
      <circle cx="41" cy="59" r="5.5" fill="#bb77cc"/>
      <circle cx="59" cy="59" r="5.5" fill="#bb77cc"/>
      <circle cx="41" cy="59" r="3.5" fill="#220033"/>
      <circle cx="59" cy="59" r="3.5" fill="#220033"/>
      <circle cx="42" cy="58" r="1.2" fill="white"/>
      <circle cx="60" cy="58" r="1.2" fill="white"/>
      <!-- blush -->
      <ellipse cx="32" cy="66" rx="7" ry="4.5" fill="#ffb3d9" opacity="0.5"/>
      <ellipse cx="68" cy="66" rx="7" ry="4.5" fill="#ffb3d9" opacity="0.5"/>
      <!-- nose -->
      <ellipse cx="50" cy="68" rx="3.5" ry="2.5" fill="#ff99bb"/>
      <!-- smile -->
      <path d="M 45 72 Q 50 77 55 72" stroke="#bb77cc" stroke-width="1.5" fill="none" stroke-linecap="round"/>
      <!-- decorative flowers (left) -->
      <circle cx="16" cy="78" r="3.5" fill="#ffdd66"/>
      <circle cx="10" cy="78" r="3"   fill="#ff99bb"/>
      <circle cx="16" cy="72" r="3"   fill="#ff99bb"/>
      <circle cx="22" cy="78" r="3"   fill="#ff99bb"/>
      <circle cx="16" cy="84" r="3"   fill="#ff99bb"/>
      <!-- decorative flowers (right) -->
      <circle cx="84" cy="78" r="3.5" fill="#ffdd66"/>
      <circle cx="78" cy="78" r="3"   fill="#ff99bb"/>
      <circle cx="84" cy="72" r="3"   fill="#ff99bb"/>
      <circle cx="90" cy="78" r="3"   fill="#ff99bb"/>
      <circle cx="84" cy="84" r="3"   fill="#ff99bb"/>
    </svg>
  '';
in
{
  services.accounts-daemon.enable = true;

  systemd.tmpfiles.rules = [
    "L+ /var/lib/AccountsService/icons/qt1    - - - - ${avatarQt1}"
    "L+ /var/lib/AccountsService/icons/cecile - - - - ${avatarCecile}"
  ];
}
