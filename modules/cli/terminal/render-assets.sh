#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="${DOTFILES_REPO_ROOT:-$(CDPATH='' cd -- "${SCRIPT_DIR}/../../.." && pwd)}"
readonly REPO_ROOT

readonly BASELINE_JSON="${REPO_ROOT}/assets/cli/terminal/baseline.json"
readonly GHOSTTY_OUTPUT="${REPO_ROOT}/assets/cli/ghostty/config"
readonly WINDOWS_TERMINAL_OUTPUT="${REPO_ROOT}/assets/windows/terminal/settings.json"
readonly VSCODE_OUTPUT="${REPO_ROOT}/assets/cli/vscode/settings.json"

render_ghostty() {
  jq -r '
    [
      "# Ghostty baseline for Apple Silicon macOS.",
      "font-family = \(.font.terminalFamily)",
      "font-size = \(.sizes.ghosttyTerminal)",
      "window-padding-x = \(.layout.paddingX)",
      "window-padding-y = \(.layout.paddingY)",
      "macos-titlebar-style = tabs",
      "background = \(.palette.background)",
      "foreground = \(.palette.foreground)",
      "cursor-color = \(.palette.cursorColor)",
      "cursor-text = \(.palette.foreground)",
      "selection-background = \(.palette.selectionBackground)",
      "selection-foreground = \(.palette.selectionForeground)",
      "palette = 0=\(.palette.black)",
      "palette = 1=\(.palette.red)",
      "palette = 2=\(.palette.green)",
      "palette = 3=\(.palette.yellow)",
      "palette = 4=\(.palette.blue)",
      "palette = 5=\(.palette.purple)",
      "palette = 6=\(.palette.cyan)",
      "palette = 7=\(.palette.white)",
      "palette = 8=\(.palette.brightBlack)",
      "palette = 9=\(.palette.brightRed)",
      "palette = 10=\(.palette.brightGreen)",
      "palette = 11=\(.palette.brightYellow)",
      "palette = 12=\(.palette.brightBlue)",
      "palette = 13=\(.palette.brightPurple)",
      "palette = 14=\(.palette.brightCyan)",
      "palette = 15=\(.palette.brightWhite)"
    ] | join("\n") + "\n"
  ' "${BASELINE_JSON}"
}

render_windows_terminal() {
  jq '
    {
      "$schema": "https://aka.ms/terminal-profiles-schema",
      "copyFormatting": "none",
      "copyOnSelect": false,
      "profiles": {
        "defaults": {
          "colorScheme": .palette.name,
          "fontFace": .font.terminalFamily,
          "fontSize": .sizes.windowsTerminal,
          "historySize": 50000,
          "padding": "\(.layout.paddingX), \(.layout.paddingY), \(.layout.paddingX), \(.layout.paddingY)",
          "scrollbarState": "visible",
          "snapOnInput": true
        }
      },
      "schemes": [
        {
          "name": .palette.name,
          "background": .palette.background,
          "black": .palette.black,
          "blue": .palette.blue,
          "brightBlack": .palette.brightBlack,
          "brightBlue": .palette.brightBlue,
          "brightCyan": .palette.brightCyan,
          "brightGreen": .palette.brightGreen,
          "brightPurple": .palette.brightPurple,
          "brightRed": .palette.brightRed,
          "brightWhite": .palette.brightWhite,
          "brightYellow": .palette.brightYellow,
          "cursorColor": .palette.cursorColor,
          "cyan": .palette.cyan,
          "foreground": .palette.foreground,
          "green": .palette.green,
          "purple": .palette.purple,
          "red": .palette.red,
          "selectionBackground": .palette.selectionBackground,
          "white": .palette.white,
          "yellow": .palette.yellow
        }
      ]
    }
  ' "${BASELINE_JSON}"
}

render_vscode_settings() {
  jq -s '
    .[0] as $settings |
    .[1] as $baseline |
    $settings
    | .["editor.fontFamily"] = ("'\''" + $baseline.font.editorFamily + "'\''" + ", monospace")
    | .["editor.fontSize"] = $baseline.sizes.vscodeEditor
    | .["terminal.integrated.fontFamily"] = (
        (["'\''" + $baseline.font.terminalFamily + "'\''"] +
        ($baseline.font.terminalFallbacks | map(if . == "monospace" then . else "'\''" + . + "'\''" end)))
        | join(", ")
      )
    | .["terminal.integrated.fontSize"] = $baseline.sizes.vscodeTerminal
  ' "${VSCODE_OUTPUT}" "${BASELINE_JSON}"
}

write_or_check() {
  target_path="$1"
  temp_path="$2"
  mode="$3"

  if [ "${mode}" = '--check' ]; then
    if cmp -s "${temp_path}" "${target_path}"; then
      return 0
    fi

    echo "Generated asset is out of date: ${target_path}" >&2
    return 1
  fi

  mv "${temp_path}" "${target_path}"
}

main() {
  mode="${1:-}"
  if [ -n "${mode}" ] && [ "${mode}" != '--check' ]; then
    echo "Unsupported option: ${mode}" >&2
    exit 1
  fi

  ghostty_temp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-ghostty.XXXXXX")"
  windows_temp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-wt.XXXXXX")"
  vscode_temp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-vscode.XXXXXX")"
  trap "rm -f '${ghostty_temp}' '${windows_temp}' '${vscode_temp}'" EXIT

  render_ghostty > "${ghostty_temp}"
  render_windows_terminal > "${windows_temp}"
  render_vscode_settings > "${vscode_temp}"

  write_or_check "${GHOSTTY_OUTPUT}" "${ghostty_temp}" "${mode:-write}"
  write_or_check "${WINDOWS_TERMINAL_OUTPUT}" "${windows_temp}" "${mode:-write}"
  write_or_check "${VSCODE_OUTPUT}" "${vscode_temp}" "${mode:-write}"
}

main "$@"
