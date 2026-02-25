# config

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

# Global network policy (allow all public internet for new sandboxes)
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