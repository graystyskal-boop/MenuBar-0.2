# MenuBarAssistant

A lightweight, menu-bar-only AI chat popup for macOS: a global hotkey (customizable
in Settings) toggles a small chat window backed by the Anthropic API.

## What it does

- Lives only in the menu bar — no Dock icon, no Cmd-Tab entry (`LSUIElement`).
- Global keyboard shortcut opens/closes the popup (default `⌘⇧Space`), rebindable
  from Settings via a click-and-press recorder control.
- Idle footprint is essentially zero: the hotkey is handled by the Carbon Event
  Manager (event-driven, no polling), and there's no background timer or network
  call until you actually open the popup and send a message.
- Quits only when you choose "Quit Assistant" from the menu-bar icon's right-click
  menu. Not hidden from Activity Monitor, `ps`, or Force Quit — those work
  normally, as they should for any legitimate Mac app.

## Building without local disk space (GitHub Actions)

See `.github/workflows/build-dmg.yml` — push this repo to GitHub and a free
macOS runner will build `dist/MenuBarAssistant.dmg` for you, downloadable from
the Actions tab. No Xcode or Command Line Tools needed on your own machine.

## Building locally (if you have Xcode Command Line Tools)

```bash
chmod +x make_dmg.sh
./make_dmg.sh
```

Produces `dist/MenuBarAssistant.dmg`.

## First run

1. Launch the app — a sparkle icon appears in the menu bar.
2. Click it, then the gear icon, to open Settings.
3. Paste your Anthropic API key (stored locally via `UserDefaults`).
4. Click "Change" next to the shortcut field and press your preferred key combo.
5. Use the hotkey or click the menu-bar icon any time to chat.

## Permissions

macOS will prompt for Accessibility/Input Monitoring permission the first time
the global hotkey fires — normal, user-visible, same as Alfred or Rectangle.

## Gatekeeper note

The DMG is ad-hoc signed, not notarized with a paid Apple Developer ID. First
launch requires right-click → Open instead of double-click. One-time per machine.
