'use strict';
// NOTE: .hyper.js settings are not separated into separate files, so there are duplicate settings for platforms other than Windows.
module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 16,
    // font family with optional fallbacks
    fontFamily: 'FiraCode Nerd Font',
    // set to `true` (without backticks and without quotes) for blinking cursor
    cursorBlink: true,
    // custom CSS to embed in the terminal window
    termCSS: 'opacity: 0.33',
    // if you're using a Linux setup which show native menus, set to false
    // default: `true` on Linux, `true` on Windows, ignored on macOS
    showHamburgerMenu: false,
    // if `true` (without backticks and without quotes), on right click selected text will be copied or pasted if no
    // selection is present (`true` by default on Windows and disables the context menu feature)
    quickEdit: false,
    // choose either `'vertical'`, if you want the column mode when Option key is hold during selection (Default)
    // or `'force'`, if you want to force selection regardless of whether the terminal is in mouse events mode
    // (inside tmux or vim with mouse mode enabled for example).
    macOptionSelectionMode: 'vertical',
    // Whether to use the WebGL renderer. Set it to false to use canvas-based
    // rendering (slower, but supports transparent backgrounds)
    webGLRenderer: false,
    // if `false` (without backticks and without quotes), Hyper will use ligatures provided by some fonts
    disableLigatures: false,
    // hyper-opacity plugin config
    opacity: {
      focus: 0.85,
    },
    // Settings for Windows
    fontFamily: 'FiraCode NF',
    shell: 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
    shellArgs: [],
    // for advanced config flags please refer to https://hyper.is/#cfg
  },
  plugins: ['hyper-relaxed', 'hyper-opacity'],
};
//# sourceMappingURL=config-default.js.map
