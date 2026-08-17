{ pkgs, ... }:
{
  users.users."cecile" = {
    isNormalUser = true;
    description = "Cécile";
    home = "/home/cecile";
    shell = pkgs.bash;
    # "i2c" — DDC/CI monitor brightness, see modules/brightness.nix.
    extraGroups = [ "i2c" ];
    packages = with pkgs; [
      ghostty
      firefox
      nautilus
    ];
  };

  users.users."qt1" = {
    isNormalUser = true;
    description = "Quentin";
    home = "/home/qt1";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "networkmanager"
      # DDC/CI monitor brightness, see modules/brightness.nix. Redundant with
      # the uaccess tag for a local login, but keeps `ddcutil detect` working
      # over SSH where there's no seat.
      "i2c"
    ];
    packages = with pkgs; [
      quickshell
      vim
      gnutar
      git
      zed-editor
      ghostty
      claude-code
      nautilus
    ];
    hashedPassword = "$6$mX3KybIzvY4Kcl/Y$LN5lcc5iefNmKDSitgRd84GXdJ5VMup/DPLojazNMD8Yj/AAuRxnd0CsYxEmmQX7TEMHBA7AbN96yMWQ25IKY0";
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBqSbEXb7nSmu2vAl99sDH0Di4YMH0foOiv0XSywfcIAWqqXE7twoateg/1AiVoNSE5nHfLL791XxUcQ5lPYHLM= qt1@nixos"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDtASdfLMatnUWsdJIjIvIXqXrnmABAznN/6mji1/rzRLqrusduqahyi4htTRvOuue3vrhUqeywiRTNTpzthfhVqeF5WehE1wAPkbgGwAvxC8ltqLPza6KkfZF0WXdXj/MsKJDTJUwui+acbyJocuMz0teJOhURoaEetXzr+ffj6P9Txz7uX6KN8D2DYGi9WvG8QPdlF/89f5vtCx4GFrKkdSET+yNC3PEcf+X8wDoL+ztuvcTGLb4rC42NzLJ82VCAYZ6KS085s8GD+lcgU/jxpRUeCVoY7Ciym/VKs2oxVsyM45fP+d33BJmqV+WGgVLHz0T4y05HOS6CBLObbXZYLfDg7jNl/MVxVktNRfvPLr23z8IvUL1DR8lHIqc6jesFMe8W5PuaoxwzQIhRl8ywGT/rVq1btMiS41mqo/86pZAFtehTt04A3GbMVGB7NNO3tmaVbUlr/aSFdB/hLr0pU3uuZQsHCipZ/3+IGs7erU1r2VVNhnxd/JcDJEVstd8= quentin@MacBook-Air-de-Quentin.local"
    ];
  };
}
