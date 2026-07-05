#!/usr/bin/env bash
# Shared timestamp builder — sourced by the timestamp hooks so the on-screen
# marker and the model-facing context always agree.
#
# current_timestamp prints one formatted timestamp on stdout, honoring:
#
#   CLAUDE_TIMESTAMPS_TZ      pin the timezone (KST, MST, Asia/Seoul, …).
#                            See resolve-tz.sh. Unset = machine local time.
#
#   CLAUDE_TIMESTAMPS_FORMAT  a `date` format string (the part after the `+`),
#                            e.g. '%y-%m-%d %H:%M:%S %Z'. Overrides the default
#                            layout entirely, so you control exactly which of
#                            date / time / zone appear and in what order.
#
# Default when CLAUDE_TIMESTAMPS_FORMAT is unset: '%y-%m-%d %H:%M:%S' (date +
# time) — plus ' %Z' only when a timezone is pinned (so the zone label appears
# exactly when it's needed to disambiguate). Time is computed with `date`
# (local/pinned TZ); we never use jq's now|strftime, which renders in UTC.

# shellcheck source=resolve-tz.sh
source "$(dirname "${BASH_SOURCE[0]}")/resolve-tz.sh"

current_timestamp() {
  local tz fmt
  tz="$(resolve_tz)"
  [ -n "$tz" ] && export TZ="$tz"

  fmt="${CLAUDE_TIMESTAMPS_FORMAT:-}"
  fmt="${fmt#+}"                       # tolerate an accidental leading '+'
  if [ -z "$fmt" ]; then
    if [ -n "$tz" ]; then
      fmt='%y-%m-%d %H:%M:%S %Z'
    else
      fmt='%y-%m-%d %H:%M:%S'
    fi
  fi

  date "+$fmt"
}
