---
name: delegate-tabs
description: Delegate work to persistent external coding-agent tabs managed by Herdr. Use for Herdr panes or when the user explicitly invokes $delegate-tabs; built-in subagents are outside this workflow.
---

# Delegate to Herdr tabs

Use `tabdo` as the sole control surface for the external agent hub. The host's internal subagents are a separate facility.

## Start

1. Run `tabdo doctor --json`. If `tabdo` is not installed, direct the user to the repository quick start. If the doctor reports that the host agent is outside a Herdr pane or cannot reach the backend, surface that blocker and its hint.
2. Run `tabdo status --json` to inspect the project-scoped hierarchy.
3. When the current project has no hub and delegation is requested, run `tabdo init --json`. This is idempotent for the active overseer pane.

## Delegate

- Create a worker with `tabdo hire NAME --kind KIND --purpose PURPOSE --json`.
- `agy` workers launch sandboxed in `accept-edits` mode. Keep Antigravity's permission mode at **Proceed in sandbox**; do not use `--dangerously-skip-permissions`.
- Give each worker one bounded task. For multiline prompts, pipe them to `tabdo run NAME --task-file - --json`.
- Add repeatable `--expect PATH` arguments for required filesystem artifacts.
- Dispatch every independent task before waiting. Capture each returned `task_id`.
- Wait by task ID with `tabdo wait TASK_ID... --json`. Prefer bounded waits and continue useful local work between polls.

Workers receive their identity and completion command in the dispatched prompt. A successful worker runs:

```bash
tabdo complete TASK_ID --summary "one-line result" --artifact PATH
```

A worker that cannot finish uses `--status blocked` and explains why in `--summary`.

## Interpret results

- Treat only `status: completed` plus satisfied expectations as completion.
- For `blocked`, inspect `tabdo screen NAME --json`; send keys with `tabdo tap` only when resolving an understood interactive prompt is within the user's authorization.
- `unreported`, `unverified`, `unknown`, and `timeout` require investigation or another bounded wait.
- Verify material filesystem changes yourself before reporting success.

Use `tabdo --help` or `tabdo COMMAND --help` for command syntax not covered here. Human-readable output is the default; use `--json` for decisions.
