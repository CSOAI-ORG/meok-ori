#!/usr/bin/env bash
# meok-ori pre-push safety suite: 41-test unit gate + content guard.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

echo "gate 1/2: unit suite (41 tests)…"
PYTHONPATH=. python3 -m unittest test_meok_ori 2>&1 | tail -2
PYTHONPATH=. python3 -m unittest test_meok_ori >/dev/null 2>&1 || {
  echo "gate 1 FAILED: unit suite red — push blocked."; exit 1; }
echo "gate 1 passed"

echo "gate 2/2: content guard (secrets + internal codenames)…"
if git grep -nE 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|-----BEGIN.*PRIVATE KEY|dagon|OWEM|sov6|SOV-\*' -- . 2>/dev/null; then
  echo "gate 2 FAILED: secret/codename pattern above — push blocked."; exit 1
fi
echo "gate 2 passed"
echo "pre-push: meok-ori gates green (41/41 + content guard clean)"
