# claudes: in a VS Code integrated terminal, lays out three Claude Code terminals in the
# current window (Bohuslav | Radomír on top, Vendelín at the bottom). Outside VS Code it
# first opens the current (or given) folder in a new window. The layout itself is done by
# the local extension in ./extension (install.sh links it into ~/.vscode/extensions).
claudes() {
  if [[ "$TERM_PROGRAM" != "vscode" || -n "$1" ]]; then
    code -n "${1:-.}"
    sleep 3
  fi
  open "vscode://rustai.claude-layout/open"
}
