#!/usr/bin/env bash
# Shared timezone resolver — sourced by the timestamp hooks.
#
# Lets a user pin the timezone used for on-screen and model-facing timestamps.
# The zone comes from one of two sources, in order:
#
#   1. CLAUDE_TIMESTAMPS_TZ env var — set once at launch, fixed for the session:
#        CLAUDE_TIMESTAMPS_TZ=KST         claude   # -> Asia/Seoul
#        CLAUDE_TIMESTAMPS_TZ=MST         claude   # -> America/Denver
#        CLAUDE_TIMESTAMPS_TZ=Asia/Seoul  claude   # any IANA name, passed through
#
#   2. A live override file, read fresh on every message so you can switch zones
#      mid-session without restarting Claude Code:
#        echo KST > ~/.claude/timestamps-tz       # next message -> Asia/Seoul
#      Path: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/timestamps-tz. The env var, when
#      set, takes precedence over the file. An empty/absent file = machine local.
#
# `date` reads the TZ env var, but TZ does NOT reliably accept short
# abbreviations — `TZ=KST` is not a valid POSIX TZ and silently renders as UTC.
# So we map common abbreviations to IANA zone names, and pass anything else
# (IANA names like America/Denver) straight through. The abbreviation shown on
# screen still comes from `date '+%Z'`, so a resolved zone displays its own
# current abbreviation (e.g. America/Denver shows MST or MDT correctly).
#
# resolve_tz prints the resolved TZ value on stdout, or nothing when no override
# is set (callers then fall back to the machine's local time). It never errors.

resolve_tz() {
  # Precedence: env var (launch-fixed) > live override file > machine local.
  local raw="${CLAUDE_TIMESTAMPS_TZ:-}"
  if [ -z "$raw" ]; then
    local tz_file="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/timestamps-tz"
    if [ -r "$tz_file" ]; then
      raw="$(cat "$tz_file" 2>/dev/null)"
      raw="${raw%%$'\n'*}"                         # first line only
      raw="${raw#"${raw%%[![:space:]]*}"}"         # trim leading whitespace
      raw="${raw%"${raw##*[![:space:]]}"}"         # trim trailing whitespace
    fi
  fi
  [ -n "$raw" ] || return 0

  # Uppercase for abbreviation lookup (IANA passthrough keeps original case).
  local key
  key="$(printf '%s' "$raw" | tr '[:lower:]' '[:upper:]')"

  case "$key" in
    UTC|GMT|ZULU|Z)                 printf 'UTC' ;;
    # North America
    EST|EDT|ET)                     printf 'America/New_York' ;;
    CST|CDT|CT)                     printf 'America/Chicago' ;;
    MST|MDT|MT)                     printf 'America/Denver' ;;
    PST|PDT|PT)                     printf 'America/Los_Angeles' ;;
    AKST|AKDT)                      printf 'America/Anchorage' ;;
    HST|HAST|HADT)                  printf 'Pacific/Honolulu' ;;
    AST|ADT)                        printf 'America/Halifax' ;;
    NST|NDT)                        printf 'America/St_Johns' ;;
    # South America
    BRT|BRST)                       printf 'America/Sao_Paulo' ;;
    ART)                            printf 'America/Argentina/Buenos_Aires' ;;
    CLT|CLST)                       printf 'America/Santiago' ;;
    # Europe / Africa
    BST|WET|WEST)                   printf 'Europe/London' ;;
    CET|CEST)                       printf 'Europe/Paris' ;;
    EET|EEST)                       printf 'Europe/Athens' ;;
    MSK)                            printf 'Europe/Moscow' ;;
    WAT)                            printf 'Africa/Lagos' ;;
    CAT)                            printf 'Africa/Maputo' ;;
    EAT)                            printf 'Africa/Nairobi' ;;
    SAST)                           printf 'Africa/Johannesburg' ;;
    # Middle East / South Asia
    GST)                            printf 'Asia/Dubai' ;;
    IRST|IRDT)                      printf 'Asia/Tehran' ;;
    PKT)                            printf 'Asia/Karachi' ;;
    IST)                            printf 'Asia/Kolkata' ;;   # India (most common IST)
    NPT)                            printf 'Asia/Kathmandu' ;;
    # East / Southeast Asia
    ICT)                            printf 'Asia/Bangkok' ;;
    WIB)                            printf 'Asia/Jakarta' ;;
    SGT)                            printf 'Asia/Singapore' ;;
    HKT)                            printf 'Asia/Hong_Kong' ;;
    CHINA|CN)                       printf 'Asia/Shanghai' ;;
    PHT|PST_PH)                     printf 'Asia/Manila' ;;
    JST)                            printf 'Asia/Tokyo' ;;
    KST)                            printf 'Asia/Seoul' ;;
    # Oceania
    AWST)                           printf 'Australia/Perth' ;;
    ACST|ACDT)                      printf 'Australia/Adelaide' ;;
    AEST|AEDT)                      printf 'Australia/Sydney' ;;
    NZST|NZDT)                      printf 'Pacific/Auckland' ;;
    # Not a known abbreviation: pass the raw value through (IANA name, or a
    # POSIX TZ string). Preserves original case, which IANA names require.
    *)                              printf '%s' "$raw" ;;
  esac
}
