#!/usr/bin/env bash
# UserPromptSubmit hook — model-facing.
#
# Gives Claude the local time each prompt was sent, wrapped by Claude Code in a
# <system-reminder> so the model treats it as passive metadata (never as part of
# the user's typed text). The system prompt already supplies today's date, so we
# send time + timezone only — no redundant date, fewer tokens.
#
# Invoked as `bash <this script>` (see hooks.json), so it does not depend on the
# executable bit being preserved across clones/zips/Windows.
#
# Time is computed with `date` (local TZ). We do NOT use jq's `now|strftime`,
# which renders in UTC.
set -euo pipefail

# Fail safe: if jq is unavailable, add no context rather than erroring the prompt.
command -v jq >/dev/null 2>&1 || exit 0

# Opt out of model-facing context injection (display-only mode).
[ "${CLAUDE_TIMESTAMPS_INJECT_CONTEXT:-true}" = "false" ] && exit 0

# Build the timestamp, honoring CLAUDE_TIMESTAMPS_TZ (pin a zone) and
# CLAUDE_TIMESTAMPS_FORMAT (custom `date` layout). Default is 'YY-MM-DD HH:MM:SS'.
source "$(dirname "${BASH_SOURCE[0]}")/lib/timestamp.sh"
ts="$(current_timestamp)"
jq -n --arg ts "$ts" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: ("Message sent at local time " + $ts)}}'
