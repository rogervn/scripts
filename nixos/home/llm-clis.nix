{ pkgs, osConfig, ... }:
{
  home.packages = with pkgs; [
    claude-code
    codex
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
          vim_insert_after_submit = true;
        }
      ]
    ];
    settings = {
      model = "openrouter/deepseek/deepseek-v4-pro-0813";
      small_model = "openrouter/deepseek/deepseek-v4-flash";
      agent.explore.model = "openrouter/deepseek/deepseek-v4-flash";
      provider.openrouter.options.apiKey = "{file:${osConfig.age.secrets.openrouter_api_key.path}}";
    };
  };
}
