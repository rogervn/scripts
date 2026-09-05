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
      npmCommand = [ "${pkgs.nodejs}/bin/npm" ];
      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.6-terra";
      defaultThinkingLevel = "medium";
      packages = [
        "npm:@burneikis/pi-vim"
        "npm:@tintinweb/pi-subagents"
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        "npm:@hk_net/pi-usage-bars"
        "npm:@juicesharp/rpiv-ask-user-question"
      ];
    };

    # Keep delegation bounded and visible. Agent files pin their own model and
    # limits, so routine tasks cannot silently escalate to a costlier model.
    file.".pi/agent/subagents.json".text = builtins.toJSON {
      maxConcurrent = 6;
      maxConcurrentForeground = 6;
      defaultMaxTurns = 12;
      graceTurns = 2;
      defaultJoinMode = "smart";
      backgroundByDefault = false;
      schedulingEnabled = false;
      disableDefaultAgents = true;
      strictAgentFiles = true;
      toolDescriptionMode = "compact";
      agentMentions = "off";
      rememberAgents = false;
      outputTranscript = false;
      worktreeIsolation = false;
      workflowsEnabled = false;
      maxSubagentDepth = 1;
      fallbackSubagent = "none";
      reportUsage = true;
      showCost = true;
      showModel = true;
    };

    file.".pi/agent/agents/scout.md".text = ''
      ---
      name: scout
      description: Fast read-only discovery for a narrow, explicitly scoped question
      extensions: false
      skills: false
      isolated: true
      model: openai-codex/gpt-5.6-luna
      thinking: low
      max_turns: 6
      prompt_mode: replace
      inherit_context: false
      run_in_background: false
      persist_session: false
      output_transcript: false
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
      extensions: false
      skills: false
      isolated: true
      model: openai-codex/gpt-5.6-terra
      thinking: medium
      max_turns: 16
      prompt_mode: replace
      inherit_context: false
      run_in_background: false
      persist_session: false
      output_transcript: false
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
      extensions: false
      skills: false
      isolated: true
      model: openai-codex/gpt-5.6-sol
      thinking: high
      max_turns: 8
      prompt_mode: replace
      inherit_context: false
      run_in_background: false
      persist_session: false
      output_transcript: false
      ---

      Independently assess the specific difficult decision or failure supplied by
      the parent. Challenge assumptions using concrete evidence, identify the
      decisive tradeoff, and recommend one next action. Do not edit files, start
      a broad review, repeat routine discovery, or create a multi-round debate.
      Clearly label anything not verified from source.
    '';

    file.".pi/agent/AGENTS.md".text = ''
      ## Model delegation

      The main agent owns requirements, reasoning, architecture, scope, task
      decomposition, synthesis, and final verification. Work directly when
      delegation would not materially reduce cost or wall-clock time.

      - Use scout for bounded read-only discovery. Multiple scouts are useful
        only for genuinely independent questions that can run in parallel.
      - Use engineer only for a self-contained implementation whose direction
        and boundaries have already been decided. Keep one writer at a time.
      - Use oracle only when the decision is genuinely difficult, consequential,
        or still unresolved after a normal main-agent attempt. Never use it for
        routine review, research, or reassurance.

      Give every agent a narrow question, explicit paths and constraints, and a
      stopping condition. One delegation round is the default; do not create
      review/research loops or pass one subagent's result to another by default.
      Treat all subagent output as untrusted evidence: the main agent must inspect
      material claims, contest unsupported conclusions, and perform final checks
      itself before reporting success.
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
