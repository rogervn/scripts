{ pkgs, osConfig, ... }:
{
  home.packages = with pkgs; [
    claude-code
    ha-mcp
  ];

  programs.opencode = {
    enable = true;
    tui.vim = true;
    # key lives in modules/secrets/openrouter_api_key.age; edit with:
    #   agenix -e nixos/modules/secrets/openrouter_api_key.age -i <ssh-key>
    settings.provider.openrouter.options.apiKey =
      "{file:${osConfig.age.secrets.openrouter_api_key.path}}";
  };
}
