# claudes

One word in a VS Code terminal, three Claude Code agents laid out and booting.

```
┌──────────────┬──────────────┐
│   Bohuslav   │   Radomír    │
├──────────────┴──────────────┤
│           Vendelín          │
└─────────────────────────────┘
```

Type `claudes` in the integrated terminal of any project. The current window splits into
two columns on top and one row below, each with a terminal named after an agent. Every
terminal plays a short boot sequence and then starts `claude -n "<name>"`, so the session
carries the agent's name. Bohuslav and Radomír run on Opus, Vendelín on the default model.

Outside VS Code, `claudes` (or `claudes ~/some/folder`) first opens the folder in a new window.

## Install

```
git clone https://github.com/Adam014/claudes.git
cd claudes && ./install.sh
```

Then reload open VS Code windows (`Developer: Reload Window`) and open a new terminal.
Requires the `code` CLI (`Shell Command: Install 'code' command in PATH`) and Claude Code.

## How it works

- `extension/` is a tiny local VS Code extension (not published). `install.sh` symlinks it
  into `~/.vscode/extensions`. It registers the command **Claude: open layout** and the URI
  `vscode://rustai.claude-layout/open`, calls `vscode.setEditorLayout` for the 2 + 1 grid and
  creates the terminals in the editor area.
- `claudes.zsh` is the shell function. Inside VS Code it only opens that URI, which lands in
  the active window.
- `extension/boot.sh` is the boot animation (zsh, because macOS ships bash 3.2 which breaks
  accented names). It ends with `exec claude …`.

## Settings (VS Code → "Claude layout")

| Setting | Default | Meaning |
| --- | --- | --- |
| `claudeLayout.sessions` | Bohuslav / Radomír / Vendelín | name, column (1–2 top, 3 bottom), model, icon, colour |
| `claudeLayout.boot` | `true` | play the boot sequence before Claude starts |
| `claudeLayout.delayMs` | `400` | pause between starting terminals |
| `claudeLayout.auto` | `false` | also run on every folder open |

Terminals that already exist with those names are left alone, so running `claudes` twice
does nothing harmful.
