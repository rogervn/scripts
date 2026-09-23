{
  pkgs,
  osConfig,
  ...
}:
{
  home = {
    packages = with pkgs; [
      claude-code
      codex
      ha-mcp
      uv
      python313
    ];

    file.".pi/agent/agents/delegate.md".text = ''
      ---
      name: delegate
      description: Generic child for an explicitly assigned task
      model: inherit
      defaultContext: fresh
      systemPromptMode: append
      inheritProjectContext: true
      inheritSkills: true
      ---

      Complete only the assigned task. Do not spawn other agents.
      Report the result and any unresolved blockers.
    '';

    file.".pi/agent/AGENTS.md".text = ''
      ## Subagent delegation

      Work on the user's task directly by default. Invoke a subagent only when
      the user explicitly asks to use a subagent, agent, or a named role. Do not
      interpret a request to research, review, investigate, or implement as a
      delegation request by itself.

      When explicitly asked, delegate only the bounded portion requested and
      retain responsibility for the task, judgment, and final answer. Use the
      generic delegate for each independently scoped task, with fresh context
      and the current model unless the user requests otherwise. Do not delegate
      further from a subagent. Isolate parallel edits or use only one writer.
    '';
  };

  programs.pi-coding-agent = {
    enable = true;
    extraPackages = [ pkgs.nodejs ];
    settings = {
      # Bare extension specs stay updateable with `pi update --extensions`.
      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.6-terra";
      defaultThinkingLevel = "medium";
      subagents.disableBuiltins = true;
      packages = [
        "npm:@burneikis/pi-vim"
        "npm:pi-subagents"
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        "npm:@hk_net/pi-usage-bars"
        "npm:@juicesharp/rpiv-ask-user-question"
      ];
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
