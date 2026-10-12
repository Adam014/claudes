// Local VS Code extension (not published). In the active window it lays out three Claude Code
// terminals in the editor area: Bohuslav | Radomír on top, Vendelín below.
// Trigger: `claudes` in the integrated terminal (URI vscode://rustai.claude-layout/open),
// or the command "Claude: open layout". Optional auto-run on folder open (claudeLayout.auto).
const vscode = require("vscode");

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function config() {
  return vscode.workspace.getConfiguration("claudeLayout");
}

function claudeCommand(session, extensionPath) {
  // A fresh session named after the terminal; the name shows in Claude's prompt bar.
  const claude = `claude --dangerously-skip-permissions${session.model ? ` --model ${session.model}` : ""} -n "${session.name}"`;
  // boot.sh plays the start-up sequence in the terminal and then exec's Claude.
  const boot = config().get("boot") ?? true;
  return boot ? `zsh "${extensionPath}/boot.sh" "${session.name}" "${session.model || ""}" ${claude}` : claude;
}

async function openLayout(extensionPath) {
  const folder = vscode.workspace.workspaceFolders?.[0];
  if (!folder) {
    vscode.window.showWarningMessage("Claude layout: nejdřív otevři složku.");
    return;
  }
  const wanted = config().get("sessions") ?? [];
  // Do not duplicate terminals that already exist (window reload restores them).
  const existing = new Set(vscode.window.terminals.map((t) => t.name));
  const missing = wanted.filter((s) => !existing.has(s.name));
  if (!missing.length) {
    vscode.window.setStatusBarMessage("$(check) Claude layout už je otevřený", 4000);
    return;
  }

  await vscode.window.withProgress(
    { location: vscode.ProgressLocation.Notification, title: "Claude layout", cancellable: false },
    async (progress) => {
      const step = 100 / (missing.length + 1);
      progress.report({ message: "rozkládám okno…", increment: step });
      // orientation 1 = rows stacked vertically; the first row is split into two equal columns.
      await vscode.commands.executeCommand("vscode.setEditorLayout", {
        orientation: 1,
        groups: [{ groups: [{ size: 0.5 }, { size: 0.5 }], size: 0.5 }, { size: 0.5 }],
      });
      for (const session of missing) {
        progress.report({ message: `spouštím ${session.name}…`, increment: step });
        const terminal = vscode.window.createTerminal({
          name: session.name,
          cwd: folder.uri.fsPath,
          iconPath: new vscode.ThemeIcon(session.icon || "person"),
          color: session.color ? new vscode.ThemeColor(session.color) : undefined,
          location: { viewColumn: session.column, preserveFocus: true },
        });
        terminal.show(true);
        terminal.sendText(claudeCommand(session, extensionPath));
        await sleep(config().get("delayMs") ?? 400);
      }
      progress.report({ message: "hotovo", increment: step });
      await sleep(600);
    },
  );
  vscode.window.setStatusBarMessage(
    `$(check) Claude layout: ${missing.map((s) => s.name).join(", ")}`,
    6000,
  );
}

function activate(context) {
  const run = () => openLayout(context.extensionPath);
  context.subscriptions.push(vscode.commands.registerCommand("claudeLayout.open", run));
  context.subscriptions.push(
    vscode.window.registerUriHandler({
      handleUri(uri) {
        if (uri.path === "/open") void run();
      },
    }),
  );
  if (config().get("auto")) void run();
}

module.exports = { activate, deactivate() {} };
