#!/usr/bin/env bash
set -eu

for s in 1M 100M 1G 5G 10G 20G; do
  n="${s%[MG]}"
  case "$s" in
    *M) bytes=$(( n * 1024 * 1024 )) ;;
    *G) bytes=$(( n * 1024 * 1024 * 1024 )) ;;
  esac

  echo "writing test-$s.bin"
  openssl enc -aes-256-ctr -pass "pass:testdata-$s" -nosalt < /dev/zero 2>/dev/null \
    | head -c "$bytes" > "test-$s.bin" || true
done

echo "done"