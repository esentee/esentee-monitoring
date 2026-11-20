#!/bin/bash
# GitHub naplánovaná workflow po 60 dnech bez aktivity v repozitáři sám vypne.
# Tenhle skript proto commitne časovou značku. Spouští ho Keepalive workflow
# prvního každého měsíce.

set -eu

echo "$(date -u +%s) $(date -u '+%Y-%m-%d %H:%M:%S') UTC" > posledni-beh.txt

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add posledni-beh.txt

if git diff --cached --quiet; then
  echo "Značka se nezměnila, necommituji."
  exit 0
fi

git commit -m "Keepalive: udržení naplánovaných běhů"
git push
