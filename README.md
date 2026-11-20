# Externí sonda dostupnosti webů

Kontroluje deset domén na multihostingu Webglobe `multi_600090` z infrastruktury GitHubu,
tedy zcela mimo naši síť a mimo kontrolovaný server. Nasazeno 20. 11. 2026.

## Jak to funguje

| Soubor | Účel |
|---|---|
| `kontrola.sh` | změří deset domén, při chybě druhý pokus po 15 s, končí kódem 1 když některá selže dvakrát |
| `.github/workflows/uptime.yml` | spouští kontrolu každých 5 minut |
| `keepalive.sh`, `.github/workflows/keepalive.yml` | prvního každého měsíce commitnou značku, aby GitHub naplánované běhy nevypnul |
| `posledni-beh.txt` | časová značka od keepalive, nic víc |

Sledované domény: `digitalniporadna.cz`, `esentee.cz`, `esenteeacademy.cz`,
`esenteepublishing.cz`, `itur.cz`, `kultivacereklamy.cz`, `kurzylevne.cz`, `sntgroup.cz`,
`sonetstudio.cz`, `statek-vlkov.cz`.

Výsledek každého běhu je v záložce **Actions** jako tabulka s HTTP kódem, TTFB a celkovým
časem. Běh spadne jen tehdy, když doména selže **dvakrát po sobě** — jednorázový zákmit
sítě runneru poplach nebudí.

## Upozornění při výpadku

Spadlý běh pošle GitHub e-mailem vlastníkovi repozitáře. Ověřte si to v
**GitHub → Settings → Notifications → Actions**, kde má být zapnuté
*Send notifications for failed workflows only* a e-mail jako kanál.

## Co o tom platí

- **Repozitář musí být veřejný.** Minuty Actions jsou u veřejných repozitářů zdarma
  bez limitu, u privátních se na free tarifu počítají z 2 000 minut měsíčně. Kontrola
  každých 5 minut znamená ~8 640 běhů měsíčně, což by se do privátní kvóty nevešlo.
  Nic citlivého tady proto není — jen seznam domén, které jsou veřejné tak jako tak.
  Logy a historie měření se do repozitáře **nezapisují**.
- **Cron na GitHubu není přesný.** Naplánované běhy se při zátěži zdrží,
  reálná granularita je 5–20 minut. Na výpadky, které u Webglobe trvají minuty až
  hodiny a chodí řádově raz měsíčně, to stačí.
- **Tohle není náhrada lokálního monitoru**, ale jeho protiváha. Lokální skript ve
  složce `monitoring/` měří každé 2 minuty z Macu a vidí víc detailu, zato neměří,
  když Mac spí, a nerozliší výpadek serveru od ztráty vlastní sítě. Dvě nezávislá
  místa měření tu otázku rozhodnou.

## Lokální spuštění

```bash
bash kontrola.sh
```

## Souvislosti

Kontext, historie výpadků 502 a vyhodnocení lokálního monitoru jsou v repozitáři
`esentee-interni`, dokument `SNT Group/04-hosting-webglobe-a-vypadky.md`.
Status page provozovatele: <https://status.webglobe.cz>
