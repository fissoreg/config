# ngrok (remote SSH access)

Exposes SSH over the internet via ngrok TCP tunnel for remote access from any machine.

## Setup

```bash
brew install ngrok
ngrok config add-authtoken YOUR_TOKEN
```

Token is at https://dashboard.ngrok.com/get-started/your-authtoken

## SSH hardening

Password auth is disabled — key-only access:
- Key pair: `~/.ssh/id_ed25519_tailscale` / `~/.ssh/id_ed25519_tailscale.pub`
- Copy the private key to any machine you want to connect from

sshd_config changes:
```
PasswordAuthentication no
KbdInteractiveAuthentication no
ClientAliveInterval 60
ClientAliveCountMax 3
```

## Start tunnel

```bash
ngrok tcp 22
```

The assigned address (e.g. `tcp://8.tcp.us-cal-1.ngrok.io:10869`) changes every restart (free tier).

## Connect from remote

```bash
# SSH
ssh -i ~/.ssh/id_ed25519_tailscale -p PORT user@HOST

# SSH + VNC (Screen Sharing over SSH tunnel)
ssh -i ~/.ssh/id_ed25519_tailscale -p PORT -L 5900:localhost:5900 user@HOST
# Then connect VNC client to localhost:5900
```

## Notes
- Free tier: one tunnel at a time, random address on restart
- Tailscale SSH also works between devices on the same tailnet (no ngrok needed)
- Tailscale Funnel does NOT work for SSH (HTTPS only)
