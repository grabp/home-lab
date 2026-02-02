{ config, ... }:
{
  services.promtail = {
    enable = false; # Disabling for now as I have no client
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/run/promtail/positions.yaml";
      };

      clients = [
        {
          # Replace with your Loki endpoint
          url = "http://metrics-vm:3100/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "host-logs";

          static_configs = [
            {
              targets = [ "localhost" ];
              labels = {
                job = "system";
                host = config.networking.hostName;
                __path__ = "/var/log/*.log";
              };
            }
          ];
        }
      ];
    };
  };

  # Required so Promtail can read the journal
  services.journald.extraConfig = ''
    Storage=persistent
  '';

  users.users.promtail.extraGroups = [ "systemd-journal" ];

  networking.firewall.allowedTCPPorts = [ 9080 ];

  systemd.tmpfiles.rules = [
    "d /run/promtail 0750 promtail promtail -"
  ];
}
