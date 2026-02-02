{
  users.users.ops = {
    isNormalUser = true;
    description = "Ops User";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY7yfcUgzDRtAxxRe07DcXV8CpljRjYQWERAUETEE+E grabowskip@koksownik"
    ];
  };
}
