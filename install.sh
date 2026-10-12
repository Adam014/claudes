#!/usr/bin/env bash
# Links the extension into VS Code and adds the `claudes` function to ~/.zshrc.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.vscode/extensions/rustai.claude-layout-1.0.0"
mkdir -p "$HOME/.vscode/extensions"
rm -rf "$target"
ln -s "$here/extension" "$target"
echo "✓ extension linked: $target -> $here/extension"
line="source \"$here/claudes.zsh\""
grep -qF "$line" "$HOME/.zshrc" 2>/dev/null || printf '\n# claudes (https://github.com/Adam014/claudes)\n%s\n' "$line" >> "$HOME/.zshrc"
echo "✓ ~/.zshrc sources claudes.zsh"
echo "Now: reload VS Code windows (Developer: Reload Window) and open a new terminal."
