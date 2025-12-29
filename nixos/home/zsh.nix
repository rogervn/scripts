{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      size = 130000;
      save = 130000;
      path = "$HOME/.histfile";
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    defaultKeymap = "viins";
  };

  programs.fzf.enable = true;
  programs.oh-my-posh = {
    enable = true;
    settings = {
      version = 2;
      final_space = true;
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          segments = [
            {
              type = "os";
              style = "diamond";
              leading_diamond = "╭─";
              background = "15"; # ANSI Bright White
              foreground = "0"; # ANSI Black
              template = " {{ if .WSL }}WSL at {{ end }}{{.Icon}} ";
              properties = {
                linux = "";
                macos = "";
                windows = "";
              };
            }
            {
              type = "root";
              style = "diamond";
              background = "1"; # ANSI Red
              foreground = "15"; # ANSI White
              template = "<parentBackground></>  ";
            }
            {
              type = "path";
              style = "powerline";
              powerline_symbol = "";
              background = "4"; # ANSI Blue
              foreground = "0"; # ANSI White
              template = "   {{ .Path }} ";
              properties = {
                folder_icon = "  ";
                home_icon = "";
                style = "folder";
              };
            }
            {
              type = "git";
              style = "powerline";
              powerline_symbol = "";
              background = "11"; # ANSI Bright Yellow
              foreground = "0"; # ANSI Black
              background_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}3{{ end }}" # ANSI Yellow/Orange
                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}10{{ end }}" # ANSI Bright Green
                "{{ if gt .Ahead 0 }}13{{ end }}" # ANSI Bright Magenta
                "{{ if gt .Behind 0 }}13{{ end }}"
              ];
              template = " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} <#c75809> {{ .Working.String }}{{ end }}</>{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}<#6cb30b>  {{ .Staging.String }}</>{{ end }} ";
              properties = {
                branch_icon = " ";
                fetch_status = true;
                fetch_upstream_icon = true;
              };
            }
            {
              type = "executiontime";
              style = "diamond";
              trailing_diamond = "";
              background = "0"; # ANSI Purple
              foreground = "15";
              template = " 󱑆 {{ .FormattedMs }} ";
              properties = {
                style = "roundrock";
                threshold = 0;
              };
            }
          ];
        }

        {
          type = "prompt";
          alignment = "right";
          segments = [
            {
              type = "time";
              style = "diamond";
              leading_diamond = "";
              trailing_diamond = "";
              background = "6"; # ANSI Cyan
              foreground = "0"; # ANSI Black
              template = " {{ .CurrentDate | date .Format }}  ";
              properties = {
                time_format = "15:04:05";
              };
            }
          ];
        }

        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "text";
              style = "plain";
              foreground = "6"; # ANSI Cyan
              template = "╰─";
            }
            {
              type = "status";
              style = "plain";
              foreground = "#e0f8ff";
              foreground_templates = ["{{ if gt .Code 0 }}#ef5350{{ end }}"]; # Red on Error
              template = "";
              properties = {
                always_enabled = true;
              };
            }
          ];
        }
      ];
    };
  };
}
