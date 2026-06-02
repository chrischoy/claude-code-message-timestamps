#!/usr/bin/env bash
# Visual mock of a Claude Code session with message-timestamps active.
DIM=$'\033[2m'; CYAN=$'\033[36m'; GREEN=$'\033[32m'; RST=$'\033[0m'; BOLD=$'\033[1m'
printf '\033[2J\033[3J\033[H'

say() { printf '%s\n' "$1"; }
ts()  { printf '%s[%s]%s ' "$DIM" "$1" "$RST"; }
prompt() { printf '%s>%s %s\n' "$CYAN" "$RST" "$1"; }

say "${BOLD}Claude Code${RST} ${DIM}— message-timestamps plugin active${RST}"
say ""
sleep 0.5
prompt "refactor the auth module and run the tests"
sleep 0.8
ts "09:12:54"; say "On it — I'll refactor \`auth.py\`, then run the suite."
sleep 1.0
ts "09:13:48"; say "${GREEN}Done.${RST} Refactor complete, 42 tests pass."
sleep 0.9
say ""
prompt "how long did that whole thing take?"
sleep 0.8
ts "09:14:20"; say "About 90 seconds end to end — you sent the request at 09:12:50,"
say "         and the tests finished at 09:14:20."
sleep 1.4
