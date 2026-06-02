#!/usr/bin/env bash
# SessionStart hook — runs once when a session starts.
#
# The timestamp hooks need `jq`. If it's missing they fail safe (no timestamps,
# nothing broken) — but silent degradation isn't helpful. This check surfaces a
# one-time, user-visible message explaining how to enable the plugin.
#
# `systemMessage` (JSON output) is the documented way to show text to the USER on
# any platform; plain stdout would only reach the model. We exit 0 either way so
# the session is never blocked.
#
# Invoked as `bash <this script>` (see hooks.json), so it does not depend on the
# executable bit.
set -euo pipefail

if command -v jq >/dev/null 2>&1; then
  exit 0
fi

# jq is missing: warn the user once, without jq (hand-built minimal JSON, no
# untrusted interpolation so this is safe to emit literally).
msg="⚠ message-timestamps: 'jq' is not installed, so timestamps are disabled. Install it to enable them — macOS: brew install jq · Linux: sudo apt-get install jq · Windows: winget install jqlang.jq — then restart Claude Code."
printf '{"systemMessage": "%s"}\n' "$msg"
exit 0
