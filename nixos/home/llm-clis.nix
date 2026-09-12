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
      pi-coding-agent
      uv
      python313
    ];

    # Bare extension specs stay updateable with `pi update --extensions`.
    file.".pi/agent/settings.json".text = builtins.toJSON {
      npmCommand = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''PATH=${pkgs.nodejs}/bin:$PATH exec ${pkgs.nodejs}/bin/npm "$@"''
        "--"
      ];
      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.6-terra";
      defaultThinkingLevel = "medium";
      packages = [
        "npm:@burneikis/pi-vim"
        "npm:pi-subagents"
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        "npm:@hk_net/pi-usage-bars"
        "npm:@juicesharp/rpiv-ask-user-question"
      ];
    };

    file.".pi/agent/agents/scout.md".text = ''
      ---
      name: scout
      description: Fast read-only discovery for a narrow, explicitly scoped question
      advertise: true
      model: openai-codex/gpt-5.6-luna
      thinking: low
      systemPromptMode: replace
      inheritProjectContext: false
      inheritGlobalContext: false
      inheritSkills: false
      defaultContext: fresh
      completionGuard: false
      ---

      Find the minimum concrete evidence needed to answer the delegated question.
      Stay inside the supplied paths and scope. Report exact paths and relevant
      lines, distinguish observations from inferences, and say when evidence is
      missing. Do not propose unrelated work, edit files, review the whole
      project, or continue after the question is answered.
    '';

    file.".pi/agent/agents/engineer.md".text = ''
      ---
      name: engineer
      description: Implementation agent for a decided, self-contained change
      advertise: true
      model: openai-codex/gpt-5.6-terra
      thinking: medium
      systemPromptMode: replace
      inheritProjectContext: false
      inheritGlobalContext: false
      inheritSkills: false
      defaultContext: fresh
      ---

      Implement only the explicitly approved change. Inspect the named files,
      make the smallest coherent edit, and run proportionate validation. Do not
      redesign the task, broaden scope, spawn other agents, or invent missing
      requirements. If a material decision is missing, stop and report it. End
      with changed files, validation performed, and any unresolved risk.
    '';

    file.".pi/agent/agents/oracle.md".text = ''
      ---
      name: oracle
      description: Second opinion for genuinely difficult or consequential decisions
      advertise: true
      model: openai-codex/gpt-5.6-sol
      thinking: high
      systemPromptMode: replace
      inheritProjectContext: false
      inheritGlobalContext: false
      inheritSkills: false
      defaultContext: fresh
      completionGuard: false
      ---

      Independently assess the specific difficult decision or failure supplied by
      the parent. Challenge assumptions using concrete evidence, identify the
      decisive tradeoff, and recommend one next action. Do not edit files, start
      a broad review, repeat routine discovery, or create a multi-round debate.
      Clearly label anything not verified from source.
    '';

    file.".pi/agent/AGENTS.md".text = ''
      ## Subagent delegation

      Work on the user's task directly by default. Invoke a subagent only when
      the user explicitly asks to use a subagent, agent, or a named role. Do not
      interpret a request to research, review, investigate, or implement as a
      delegation request by itself.

      When explicitly asked, delegate only the bounded portion requested and
      retain responsibility for the task, judgment, and final answer. Use scout
      for narrow discovery, engineer for an approved self-contained change, and
      oracle for a difficult decision. Do not delegate further from a subagent.
    '';
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
