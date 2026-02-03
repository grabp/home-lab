{
  description = "Multi-node declarative Incus homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      sops-nix,
      hardware,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";

      # Helper for creating NixOS systems
      mkSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
          };
          modules = modules;
        };
    in
    {
      ##########################################################################
      # NixOS CONFIGURATIONS
      ##########################################################################

      nixosConfigurations = {
        ######################################################################
        # PHYSICAL HOSTS (Incus nodes)
        ######################################################################

        elitedesk-1 = mkSystem [
          ./host/nodes/elitedesk-1/configuration.nix
        ];

        ######################################################################
        # GUEST VMS (managed by Incus)
        ######################################################################

        nixos-test = mkSystem [
          sops-nix.nixosModules.sops
          ./guests/nixos-test/configuration.nix
        ];

        # edge-vm = mkSystem [
        #   sops-nix.nixosModules.sops
        #   ./guests/common.nix
        #   ./guests/edge-vm/configuration.nix
        # ];
        #
        # metrics-vm = mkSystem [
        #   sops-nix.nixosModules.sops
        #   ./guests/common.nix
        #   ./guests/metrics-vm/configuration.nix
        # ];
        #
        # home-vm = mkSystem [
        #   sops-nix.nixosModules.sops
        #   ./guests/common.nix
        #   ./guests/home-vm/configuration.nix
        # ];
      };

      ##########################################################################
      # DEPLOY-RS CONFIGURATION
      ##########################################################################

      deploy = {
        nodes = {
          ####################################################################
          # PHYSICAL HOST DEPLOYMENTS
          ####################################################################

          elitedesk-1 = {
            hostname = self.nixosConfigurations.elitedesk-1.config.my.networking.staticIPv4.address;
            sshUser = "ops";

            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.elitedesk-1;
            };
          };

          ####################################################################
          # GUEST VM DEPLOYMENTS
          ####################################################################

          # edge-vm = {
          #   hostname = "edge-vm";
          #   sshUser = "root";
          #   profiles.system.path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.edge-vm;
          # };
          #
          # metrics-vm = {
          #   hostname = "metrics-vm";
          #   sshUser = "root";
          #   profiles.system.path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.metrics-vm;
          # };
          #
          # home-vm = {
          #   hostname = "home-vm";
          #   sshUser = "root";
          #   profiles.system.path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.home-vm;
          # };
        };
      };
    };
}
