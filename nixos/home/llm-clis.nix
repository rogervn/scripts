{ pkgs, osConfig, ... }:
{
  home.packages = with pkgs; [
    claude-code
    ha-mcp
  ];

  programs.opencode = {
    enable = true;
    tui.plugin = [
      [
        "@leohenon/opencode-vim-plugin"
        {
          enabled = true;
          vim_escape_sequence = "jk";
          vim_enter_submit = true;
        }
      ]
    ];
    settings.provider.openrouter.options.apiKey =
      "{file:${osConfig.age.secrets.openrouter_api_key.path}}";
  };
}
