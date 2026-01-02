{
  # free up port 53 locally
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true;
  };
}
