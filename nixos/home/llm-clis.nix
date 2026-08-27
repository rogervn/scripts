{ lib, pkgs, osConfig, ... }:
{
  home = {
    packages = with pkgs; [
      claude-code
      codex
      ha-mcp
      pi-coding-agent
    ];

    # Pi installs package extensions declared here into ~/.pi/agent/npm on its
    # first launch. Pin them so a Home Manager generation has stable behavior.
    file.".pi/agent/settings.json".text = builtins.toJSON {
      npmCommand = [ "${pkgs.nodejs}/bin/npm" ];
      defaultModel = "openai-codex/gpt-5.6-terra";
      defaultThinkingLevel = "medium";
      packages = [
        "npm:pi-vim@0.14.1"
        "npm:pi-subagents@0.57.0"
        # TODO: Remove the local patch after https://github.com/santychuy/pi-setup/pull/1 merges.
        "npm:pi-codex-limit@1.8.2"
        "npm:@juicesharp/rpiv-ask-user-question@2.7.1"
      ];
      subagents = {
        defaultModel = "openai-codex/gpt-5.6-luna";
        defaultThinking = "medium";
        agentOverrides = {
          scout = {
            model = "openai-codex/gpt-5.6-luna";
            thinking = "low";
            defaultContext = "fresh";
          };
          researcher = {
            model = "openai-codex/gpt-5.6-luna";
            thinking = "medium";
            defaultContext = "fresh";
          };
          delegate = {
            model = "openai-codex/gpt-5.6-luna";
            thinking = "low";
            defaultContext = "fresh";
          };
          worker = {
            model = "openai-codex/gpt-5.6-luna";
            thinking = "medium";
            defaultContext = "fresh";
          };
          reviewer = {
            model = "openai-codex/gpt-5.6-luna";
            thinking = "high";
            defaultContext = "fresh";
          };
          oracle = {
            model = "openai-codex/gpt-5.6-terra";
            thinking = "high";
            defaultContext = "fork";
          };
        };
      };
    };

    file.".pi/agent/AGENTS.md".text = ''
      ## Model delegation

      Keep the main agent responsible for requirements, reasoning, architecture,
      scope decisions, task decomposition, and final verification.

      Delegate bounded busy work:
      - Use scout for all codebase and local-configuration discovery, including
        file searches, metadata checks, and context gathering. Do this before
        the main agent reads source files; it may then inspect paths returned
        by scout.
      - Use researcher for external documentation and source summaries.
      - Use delegate for simple lookups, transformations, and summaries.
      - Use worker only after the implementation direction is decided.
      - Use reviewer for fresh-context verification after implementation.
      - Use oracle only for difficult or consequential decisions.

      Give Luna agents narrow tasks with explicit paths, constraints, expected output,
      and validation. Subagents must escalate ambiguity rather than changing the plan.
      Keep one writer per worktree.
    '';
  };

  home.activation.patchPiCodexLimit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    packageDir="$HOME/.pi/agent/npm/node_modules/pi-codex-limit"

    if [ ! -f "$packageDir/index.ts" ]; then
      $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm --prefix "$HOME/.pi/agent/npm" install pi-codex-limit@1.8.2
    fi

    if ! ${pkgs.gnugrep}/bin/grep -q 'let sessionGeneration = 0;' "$packageDir/index.ts"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --directory="$packageDir" --batch --forward --input=${./pi-codex-limit-stale-context.patch}
    fi
  '';

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
