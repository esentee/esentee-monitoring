#!/bin/bash
# Externí sonda dostupnosti webů skupiny. Spouští ji GitHub Actions každých 5 minut.
# Končí kódem 1, když alespoň jedna doména selže dvakrát po sobě – tím spadne běh
# workflow a GitHub pošle upozornění e-mailem.
#
# Jde spustit i lokálně: bash kontrola.sh

set -u

DOMAINS="digitalniporadna.cz esentee.cz esenteeacademy.cz esenteepublishing.cz
         itur.cz kultivacereklamy.cz kurzylevne.cz sntgroup.cz
         sonetstudio.cz statek-vlkov.cz"

# Mimo GitHub Actions zahodíme souhrn do /dev/null.
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"
FAIL=0

{
  echo "## Kontrola $(date -u '+%Y-%m-%d %H:%M:%S') UTC"
  echo
  echo "| Doména | Kód | TTFB | Celkem | Pokusů |"
  echo "|---|---|---|---|---|"
} >> "$SUMMARY"

popis_kod() {
  case "$1" in
    000) echo "bez odpovědi / timeout" ;;
    502) echo "Bad Gateway – nginx nedostal odpověď od LiteSpeed backendu" ;;
    503) echo "služba nedostupná" ;;
    504) echo "Gateway Timeout" ;;
    *)   echo "neočekávaný kód" ;;
  esac
}

for d in $DOMAINS; do
  POKUS=0
  CODE=000
  TTFB=0
  TOTAL=0

  # Dva pokusy. Do chyby se počítá jen to, co se zopakuje – jednorázový zákmit
  # sítě runneru nemá budit poplach.
  while [ "$POKUS" -lt 2 ]; do
    POKUS=$((POKUS + 1))
    OUT="$(curl -sS -o /dev/null -L --max-time 20 \
      -w '%{http_code} %{time_starttransfer} %{time_total}' "https://$d/" 2>/dev/null || true)"
    [ -z "$OUT" ] && OUT="000 0 0"
    CODE="$(echo "$OUT" | cut -d' ' -f1)"
    TTFB="$(echo "$OUT" | cut -d' ' -f2)"
    TOTAL="$(echo "$OUT" | cut -d' ' -f3)"
    [ "$CODE" = "200" ] && break
    [ "$POKUS" -lt 2 ] && sleep 15
  done

  if [ "$CODE" = "200" ]; then
    printf 'OK     %-24s ttfb=%ss celkem=%ss pokusu=%s\n' "$d" "$TTFB" "$TOTAL" "$POKUS"
    echo "| $d | 200 | ${TTFB}s | ${TOTAL}s | $POKUS |" >> "$SUMMARY"
  else
    NOTE="$(popis_kod "$CODE")"
    printf 'CHYBA  %-24s kod=%s (%s), dva pokusy po sobe\n' "$d" "$CODE" "$NOTE"
    echo "| $d | **$CODE** | – | – | $POKUS |" >> "$SUMMARY"
    echo "::error title=Výpadek $d::$d vrací $CODE – $NOTE (dva pokusy po sobě)"
    FAIL=1
  fi
done

if [ "$FAIL" = "1" ]; then
  {
    echo
    echo "Alespoň jedna doména selhala dvakrát po sobě."
    echo "První místo ke kontrole: <https://status.webglobe.cz>"
  } >> "$SUMMARY"
fi

exit "$FAIL"
