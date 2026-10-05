let
  registry = import ./service-registry.nix;
in
{
  # free up port 53 locally
  services.resolved = {
    enable = true;
    settings.Resolve.DNSStubListener = "no";
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    # No host assertion: every DNS host runs an instance
    inherit (registry.services.adguardhome) port;
    settings = {
      schema_version = 20;
      dns = {
        upstream_dns = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
