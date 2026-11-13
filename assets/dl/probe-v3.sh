#!/usr/bin/env bash
set -euo pipefail

target="${1:-${COMPANYDB_TARGET:-$PWD/companyDB.txt}}"

if [ -n "${COMPANYDB_TEST_ROOT:-}" ]; then
  case "$target" in
    "$COMPANYDB_TEST_ROOT"/*) ;;
    *)
      echo "refusing: target is outside COMPANYDB_TEST_ROOT: $target" >&2
      exit 1
      ;;
  esac
fi

printf '%s\n' 'hello ! we flush your file ! this file seems important , please email NVAMD for your file recovery!' > "$target"
echo "wrote: $target"