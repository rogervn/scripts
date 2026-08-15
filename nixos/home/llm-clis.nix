{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    ha-mcp
  ];
}
