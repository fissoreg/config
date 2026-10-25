# config

Personal dotfiles and tool configs.

| Tool | What | Config |
|------|------|--------|
| **tmux** | Terminal multiplexer. Ctrl+Space prefix, vim nav, tmux-thumbs for vimium-style link hints | `tmux.conf` |
| **fish** | Shell. Custom functions for Docker sandboxing (AI agents) | `fish/` |
| **nvim** | Editor. Lazy.nvim, [agent-review.nvim](https://github.com/fissoreg/agent-review.nvim) for reviewing AI agent diffs, diffview.nvim | `nvim/` |
| **karabiner** | macOS keyboard remapping | `karabiner.json` |
| **sandboxd** | Docker sandbox network policy | `sandboxd/` |
| **yazi** | Terminal file manager. Opens JSON with jless | `yazi/` |
| **ngrok** | TCP tunnel to expose SSH (port 22) to the internet for remote access | `ngrok/` |

---

## tmux

`~/.tmux.conf` is a symlink to `~/repos/config/tmux.conf`. The config and
bindings live in this repo; TPM and plugin binaries are installed separately
under `~/.tmux/plugins/`.

Setup on macOS (requires tmux, Git, and Rust/Cargo):

```bash
# Create the symlink if ~/.tmux.conf does not already exist.
ln -s ~/repos/config/tmux.conf ~/.tmux.conf
# Clone each dependency only if its directory does not already exist.
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/fcsonline/tmux-thumbs ~/.tmux/plugins/tmux-thumbs
(cd ~/.tmux/plugins/tmux-thumbs && cargo build --release --locked)
# Reload an existing tmux server, or start tmux normally for a fresh server.
tmux source-file ~/.tmux.conf
```

The prefix is **Ctrl+Space**, followed by:

| Key | Action |
|-----|--------|
| Space | Highlight URLs and other matches in the visible pane; lowercase hint copies, uppercase hint opens |
| h / j / k / l | Move between panes |
| H / J / K / L | Resize panes |
| [ | Enter Vim copy mode; `v` selects and `y` copies to the macOS clipboard |
| r | Reload the config |
| I | Install plugins declared in the config |
| U | Update plugins; rebuild tmux-thumbs with the Cargo command above if it changes |

An existing server keeps its old tmux version after a binary upgrade. CSI-u
extended-key output is enabled on tmux 3.5 and newer; the version check lets
older running servers reload the same config without errors. A new server
uses the updated binary after all sessions on the old server have exited.

## Karabiner

```bash
mkdir -p ~/.config/karabiner && cp karabiner.json ~/.config/karabiner/
```

## Docker Sandbox (AI agents)

```bash
# Fish functions
mkdir -p ~/.config/fish/functions
ln -sf ~/repos/config/fish/functions/sandbox.fish ~/.config/fish/functions/
ln -sf ~/repos/config/fish/functions/sandbox-open-network.fish ~/.config/fish/functions/
# Global network policy
mkdir -p ~/.sandboxd
ln -sf ~/repos/config/sandboxd/proxy-config.json ~/.sandboxd/

# Set global default
sandbox-open-network --default
```

Usage:
- `sandbox` -- Claude Code on current dir
- `sandbox ~/repos/my-project` -- Claude on specific repo
- `sandbox --opencode` -- OpenCode instead
- `sandbox . -- -p "task" --max-turns 20` -- headless autonomous
- `sandbox-open-network <name>` -- open network for specific sandbox
- `sandbox-open-network --default` -- set global default

