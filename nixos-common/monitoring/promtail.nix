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
        # {
        #   url = "http://10.0.0.122:3100/loki/api/v1/push";
        # }
      ];

      scrape_configs = [
        {
          job_name = "systemd-journal";

          journal = {
            path = "/var/log/journal";
            max_age = "12h";
            labels = {
              job = "systemd";
              host = "prometheus";
            };
          };

          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "hostname";
            }
            {
              source_labels = [ "__journal__transport" ];
              target_label = "transport";
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
