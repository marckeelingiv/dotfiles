# Subagent lifecycle

Each subagent is single-use: start a fresh session for each delegated task and have it report its results back when finished.
Omit `task_id` from every Task tool call. Never resume an existing subagent session.
For follow-up work, launch a new subagent with the relevant context and previous results in its prompt.
