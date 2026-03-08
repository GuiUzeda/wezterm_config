# 💻 WezTerm Configuration

A highly customized and functional WezTerm configuration featuring smart navigation, workspace management, and session persistence.

## 🚀 Highlights

- **Leader Key:** `CTRL-a` (tmux-style)
- **Smart Split & Nav:** Seamless navigation between WezTerm panes and Vim windows.
- **Session Management:** Automatic and manual session saving/restoring via `resurrect.wezterm`.
- **Workspace-Aware Status:** Dynamic status bar showing active Leader state and Workspace name.
- **Persistent Sessions:** Configured with Unix domains for background persistence.

---

## ⌨️ Keybindings

### Leader Commands (`CTRL-a`)

| Key           | Action                                 |
| :------------ | :------------------------------------- |
| `c`           | Create a new tab                       |
| `f`           | Fuzzy find/switch tabs                 |
| `,`           | Rename current tab                     |
| `0-9`         | Switch to Tab 1-10 (0=10th)            |
| `ALT + 1-0`   | Move tab to position 1-10              |
| `<` / `>`     | Move tab Left / Right                  |
| `x`           | Close current pane (with confirmation) |
| `&` (Shift+7) | Close current tab (with confirmation)  |
| `w`           | Open fuzzy workspace/launcher          |
| `$` (Shift+4) | Rename current workspace               |
| `D` (Shift+d) | Switch to "default" workspace          |
| `Q` (Shift+q) | Quit WezTerm                           |

### Smart Navigation & Resizing

These bindings automatically switch between WezTerm panes and Vim windows depending on what is active.

| Key              | Action                         | Context                   |
| :--------------- | :----------------------------- | :------------------------ |
| `CTRL + h/j/k/l` | Move focus Left/Down/Up/Right  | WezTerm / Vim / AwesomeWM |
| `META + h/j/k/l` | Resize pane Left/Down/Up/Right | WezTerm / Vim             |
| `Leader + -`     | Horizontal Split               | Smart Split (Vim aware)   |
| `Leader + \`     | Vertical Split                 | Smart Split (Vim aware)   |
| `Leader + \|`    | Split Right (50%)              | WezTerm                   |
| `Leader + _`     | Split Down (50%)               | WezTerm                   |

### Session Management (`resurrect.wezterm`)

| Key          | Action                                              |
| :----------- | :-------------------------------------------------- |
| `Leader + S` | Save current workspace state                        |
| `Leader + R` | Restore state (fuzzy search through saved sessions) |
| `Leader + X` | Delete a saved state (fuzzy search)                 |

_Note: States are autosaved every 15 minutes._

---

## 🎨 Appearance

- **Theme:** BlulocoDark
- **Font:** Victor Mono (SemiBold, Size 12.5)
- **Opacity:** 95% background opacity
- **Tab Bar:** Minimalist/Flat style (hidden when only one tab is open)

---

## 🛠 Default WezTerm Commands

These are built-in WezTerm defaults that remain active:

| Key                | Action                   |
| :----------------- | :----------------------- |
| `CTRL + SHIFT + C` | Copy to clipboard        |
| `CTRL + SHIFT + V` | Paste from clipboard     |
| `CTRL + SHIFT + F` | Search scrollback buffer |
| `CTRL + SHIFT + L` | Open Debug Overlay       |
| `CTRL + SHIFT + K` | Clear scrollback         |
| `CTRL + SHIFT + +` | Zoom In                  |
| `CTRL + SHIFT + -` | Zoom Out                 |
| `CTRL + SHIFT + 0` | Reset Zoom               |

---

## 📦 Requirements & Plugins

- **Font:** [Victor Mono](https://rubjo.github.io/victor-mono/)
- **Plugin:** [resurrect.wezterm](https://github.com/MLFlexer/resurrect.wezterm) (Automatically managed)
- **Vim Integration:** Works best with `christoomey/vim-tmux-navigator` or similar "smart-split" plugins.
