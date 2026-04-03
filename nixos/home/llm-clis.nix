{pkgs, ...}: {
  home.packages = with pkgs; [
    claude-code
    gemini-cli
    ha-mcp
  ];
}
