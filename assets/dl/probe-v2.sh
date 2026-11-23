#!/usr/bin/env bash

set -u

find_secret() {
    if [ "$#" -gt 0 ]; then
        [ -f "$1" ] || return 1
        printf '%s\n' "$1"
        return 0
    fi
    local here
    here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    if [ -n "${here:-}" ] && [ -f "$here/secret.txt" ]; then
        printf '%s\n' "$here/secret.txt"
        return 0
    fi
    if [ -f "./secret.txt" ]; then
        printf '%s\n' "./secret.txt"
        return 0
    fi
    return 1
}

clean() {
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"   # ltrim
    v="${v%"${v##*[![:space:]]}"}"   # rtrim
    if [ "${#v}" -ge 2 ]; then
        local first="${v:0:1}" last="${v: -1}"
        if { [ "$first" = '"' ] || [ "$first" = "'" ]; } && [ "$first" = "$last" ]; then
            v="${v:1:${#v}-2}"
        fi
    fi
    printf '%s\n' "$v"
}

path="$(find_secret "$@")" || {
    printf 'secret.txt not found (looked next to script and in cwd)\n' >&2
    exit 1
}

line="$(grep -v '^[[:space:]]*$' -- "$path" | head -n 1 | tr -d '\r')"

case "$line" in
    *=*)  key="${line#*=}" ;;
    *:*)  key="${line#*:}" ;;
    *：*) key="${line#*：}" ;;
    *)    key="$line" ;;
esac

clean "$key"
