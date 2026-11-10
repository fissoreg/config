# local-model sub-agent (privacy-by-scheduling gateway)

A generic pattern for giving **other agents** (cloud or local, any harness) scoped access
to a resource that should only ever be *interpreted* by a **local model** — here, an email
mailbox, but the shape generalizes (filesystem, browser, internal APIs).

## The rule this enforces

> Other agents may *ask questions* and *receive answers + file assets*.
> They never get a raw handle to the resource, and no cloud model ever sees it.

```
Caller agent (Codex, pi, any MCP/A2A client — any model)
   │  email_lookup / email_digest / email_draft      ← MCP (stdio) or POST /a2a
   ▼
gateway (this setup; spawns as a uvx-style child process, or HTTP daemon)
   │  FIFO queue, concurrency 1  (local model is the bottleneck)
   │  fresh sub-SDK agent session PER TASK
   │     model:  <your local provider>/<your local model>   (NO cloud creds in process)
   │     tools:  mcp__<your resource server>__*  (whitelist, default-hidden)
   │             + read/write in a per-task scratch dir
   ▼
resource MCP server (e.g. an IMAP mail server; stdio, spawned per call)
```

## Why not just give the caller the MCP server directly?

- The caller becomes a raw client: full search, full bodies, full history, in its own
  (possibly cloud) model's context, at its own pace.
- "Trust me to only look at what I asked about" is a prompt-level guarantee.
  A local-model middle layer + tool whitelist is a *process-level* guarantee.

## Properties

| Property | Mechanism |
|---|---|
| Local model only | sub-agent sessions run in a **private agent dir** with a models.json containing only the local provider; no cloud auth file, no cloud API key in the process env. Model down ⇒ task fails loudly, never falls back to cloud. |
| No raw resource access | the gateway is the *only* MCP client of the resource server. Callers see 3-4 narrow tools (`*_lookup`, `*_digest`, `*_draft`, `queue_status`). |
| Write scoping | tool whitelist is **default-hidden**: only explicitly whitelisted tools (e.g. read + `save_draft`) are reachable; whatever the upstream server adds later stays hidden. Drafts are saved, never sent. |
| Full content as assets | full documents are written to per-task work dirs and referenced by path (MCP `filePaths`, A2A `file://` parts), never inlined into the answer. |
| One model at a time | in-process FIFO queue, concurrency 1; the local model runtime also serializes generations, so overlapping callers queue safely. |
| No daemon to babysit | **stdio MCP** shape: the caller spawns the gateway as a child process with its session. Model warmth across calls is the model server's job (e.g. Ollama `keep_alive`), not the gateway's. |
| Auditable | every task appended to `data/audit.jsonl` (request, answer, tool calls, timing). |

## Shape A — stdio MCP (uvx-style; recommended for harnesses)

A tiny launcher script, registered like any other stdio MCP server in the caller's config.
Replace the `YOUR_*` values:

```bash
#!/bin/zsh
# <resource>-subagent.mcp.sh — spawned on demand by the calling agent.
set -euo pipefail
cd "${GATEWAY_DIR:-$HOME/gateways/<resource>-subagent}"
exec npx tsx src/stdio.ts
```

Caller config example (TOML-shaped server config; map to your harness's format):

```toml
[mcp_servers.personal_email]
command = "/Users/giancarlofissore/repos/config/local-model-subagent/email-subagent.mcp.sh"
startup_timeout_sec = 120
tool_timeout_sec = 3600        # local 27B-class models can take minutes per task

# approve-on-use, matching the rest of your MCP policy (optional but sane):
[mcp_servers.personal_email.tools.email_lookup]
approval_mode = "approve"
[mcp_servers.personal_email.tools.email_digest]
approval_mode = "approve"
[mcp_servers.personal_email.tools.email_draft]
approval_mode = "approve"
```

JSON-shaped (pi `mcp.json` / generic):

```json
{
  "mcpServers": {
    "personal_email": {
      "command": "/Users/giancarlofissore/repos/config/local-model-subagent/email-subagent.mcp.sh",
      "exposure": "direct",
      "description": "Personal email via local-model sub-agent. email_lookup / email_digest / email_draft / queue_status. Never sends."
    }
  }
}
```

## Shape B — HTTP daemon + agent card (for agent-to-agent / multi-caller)

- `POST /mcp` — same tools over the MCP streamable-HTTP transport (stateless: one
  server+transport per request).
- `POST /a2a` — A2A JSON-RPC (`message/send` blocking, `message/stream` SSE with
  task lifecycle events, `tasks/get`), per A2A ~0.3.
- `GET /.well-known/agent.json` — A2A agent card: name, description, skills with
  examples, I/O modes. This is the discoverability surface.
- `GET /healthz`, `GET /queue` — ops + live queue position.
- Bind `127.0.0.1` only; optional shared-secret `Authorization: Bearer` gate.

A2A task hint by message prefix: `DRAFT:` → draft & save (never send),
`DIGEST:` → overview, anything else → lookup.

## Design decisions worth copying

1. **Per-task disposable agent session.** No cross-task memory (no inbox context leak
   between questions), no long-lived conversation to compact, one work dir to clean up.
2. **Strict tool allowlist with default-hidden upstream exposure.** If the upstream MCP
   server ships new tools, they are invisible unless you whitelist them.
   The gateway's own allowlist (`mcp__<server>__*`, `read`, `write`) is enforced by the
   session factory, not by prompt.
3. **Answer contract in the system prompt:** short answer first; full content goes to
   files with a trailing `FILES:` section; `mark_as_read: false` always; say "not found"
   rather than guessing.
4. **Assets, not tokens.** Big content crosses the boundary as a file path / `file://`
   part. The calling agent decides whether to read it.
5. **Queue in the gateway, warmth in the model server.** The process is short-lived and
   cheap; the expensive state (model weights) lives in one place (Ollama), serialized
   server-side. Two callers ⇒ two cheap gateways ⇒ one queue of model generations.
6. **Audit JSONL.** Cheap, local, and it answers "what did the agent actually look at?"

## Reference implementation

The concrete implementation of this pattern (email, via the pi SDK) lives in a local
`email-agent` project. Reuse its structure for other resources:

```
gateways/<resource>-subagent/
  src/
    config.ts        env-driven settings (host, port, model, timeouts, paths)
    queue.ts         FIFO, concurrency 1, status()
    model-runtime.ts private agent dir, local-provider-only models.json
    mcp-config.ts    THE policy file: default-hidden, whitelisted tools
    prompt.ts        steward system prompt + per-kind task prompt
    subagent.ts      one disposable agent session per task
    task-runner.ts   queue -> sub-agent -> audit (the single door)
    server.ts        HTTP router (healthz, queue, agent card, /mcp, /a2a)
    mcp-gateway.ts   stateless MCP-over-HTTP tools
    a2a.ts           agent card + JSON-RPC (send / stream / tasks.get)
    stdio.ts         stdio MCP entrypoint (Shape A)
    main.ts          daemon bootstrap (Shape B)
  <resource>-subagent.mcp.sh   uvx-style launcher
```
