{ pkgs, osConfig, ... }:
{
  home.packages = with pkgs; [
    claude-code
    codex
    ha-mcp
    pi-coding-agent
  ];

  # Pi installs package extensions declared here into ~/.pi/agent/npm on its
  # first launch. Pin them so a Home Manager generation has stable behavior.
  home.file.".pi/agent/settings.json".text = builtins.toJSON {
    npmCommand = [ "${pkgs.nodejs}/bin/npm" ];
    packages = [
      "npm:pi-vim@0.14.1"
      "npm:pi-subagents@0.57.0"
      "npm:pi-codex-limit@1.8.2"
    ];
    subagents = {
      defaultModel = "openai-codex/gpt-5.6-luna";
      defaultThinking = "medium";
      agentOverrides.oracle = {
        model = "openai-codex/gpt-5.6-terra";
        thinking = "high";
      };
    };
  };

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
      agent.explore.description = "Use for ALL file and web discovery: finding files, grepping/globbing for symbols, mapping the codebase, and web search/fetch lookups. Delegate here before reading full file contents yourself.";
      provider.openrouter.options.apiKey = "{file:${osConfig.age.secrets.openrouter_api_key.path}}";
    };
  };
}
