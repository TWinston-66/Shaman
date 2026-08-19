#!/usr/bin/env bash
set -eu

OUTDIR="${1:-./test_files}"
mkdir -p "$OUTDIR"

for s in 1M 100M 1G 5G 10G 20G; do
  n="${s%[MG]}"
  case "$s" in
    *M) bytes=$(( n * 1024 * 1024 )) ;;
    *G) bytes=$(( n * 1024 * 1024 * 1024 )) ;;
  esac

  echo "writing $OUTDIR/test-$s.bin"
  openssl enc -aes-256-ctr -pass "pass:testdata-$s" -nosalt < /dev/zero 2>/dev/null \
    | head -c "$bytes" > "$OUTDIR/test-$s.bin" || true
done

echo "done"