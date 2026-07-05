#!/usr/bin/env bash
# MessageDisplay hook — user-facing, display-only.
#
# Prepends a local-time [HH:MM:SS ZONE] marker to each assistant message on screen.
# This is purely cosmetic: MessageDisplay never changes the transcript or what
# Claude sees, so the marker cannot confuse the model.
#
# MessageDisplay fires once per streamed batch of an assistant message, with a
# zero-based `index`. We stamp only the first batch (index == 0) so the marker
# appears exactly once per message, not before every chunk.
#
# Invoked as `bash <this script>` (see hooks.json), so it does not depend on the
# executable bit being preserved across clones/zips/Windows.
#
# Time is computed with `date` (local TZ). We do NOT use jq's `now|strftime`,
# which renders in UTC.
set -euo pipefail

# Fail safe: if jq is unavailable, emit nothing and exit 0. Claude Code then
# displays the original message text unchanged — never swallow assistant output.
command -v jq >/dev/null 2>&1 || exit 0

# Build the timestamp, honoring CLAUDE_TIMESTAMPS_TZ (pin a zone) and
# CLAUDE_TIMESTAMPS_FORMAT (custom `date` layout). Default is 'YY-MM-DD HH:MM:SS',
# with the zone label added only when a zone is pinned.
source "$(dirname "${BASH_SOURCE[0]}")/lib/timestamp.sh"
ts="$(current_timestamp)"
jq --arg ts "$ts" '
  if .index == 0 then
    {hookSpecificOutput: {hookEventName: "MessageDisplay", displayContent: ("[" + $ts + "] " + .delta)}}
  else
    {hookSpecificOutput: {hookEventName: "MessageDisplay", displayContent: .delta}}
  end
'
