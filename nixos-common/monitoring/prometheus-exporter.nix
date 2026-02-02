{
  services.prometheus.exporters.node = {
    enable = true;

    port = 9100;
    listenAddress = "0.0.0.0";

    enabledCollectors = [
      "systemd"
      "filesystem"
      "cpu"
      "meminfo"
      "loadavg"
      "netdev"
      "diskstats"
    ];

    disabledCollectors = [
      "textfile"
    ];

    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 9100 ];
}
