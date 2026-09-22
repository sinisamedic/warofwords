# Google Play URL provera — Cloudflare nalaz

2026-09-22. URL: https://gottaplay.net/wow/delete-data/

Security → Analytics → Events potvrđuje Managed Challenge, Service Bot fight mode, ASN AS15169 Google LLC, GET, User-Agent Google odnosno GooglePlayConsole, tačna putanja `/wow/delete-data/`.

Korisnik izričito odobrio isključivanje Bot Fight Mode; OFF potvrđen na Settings i ponovo učitanom Overview. Ostala bezbednosna podešavanja nisu menjana. Free Bot Fight Mode nema WAF/Page Rule izuzetak po putanji: https://developers.cloudflare.com/bots/get-started/bot-fight-mode/ .

Prva ponovljena validacija i dalje403; query-parametar za svež URL takođe403. Kasniji Cloudflare događaji potvrđuju da su zahtevi zaista stigli i bili izazvani posle izmene, pa se ne može tvrditi da je problem samo Google cache.

- 16:12:12 GMT+2, Ray `a3f1e73a5f80135d`, UA Google, bez query-ja (pre izmene).
- 16:38:15 GMT+2, Ray `a3f20d611f99811d`, UA GooglePlayConsole, `?source=google-play`.
- 16:40:57 GMT+2, Ray `a3f2115879a01f6b`, UA GooglePlayConsole, bez query-ja.

Lokalni curl GET/HEAD i bot User-Agent provere vraćaju200; to ne simulira Google IP/mrežu. U Play obrascu vraćen originalni kanonski URL, bez query-ja. Ne menjati dalje zaštitu bez konkretnih novih dokaza i odgovarajućeg odobrenja.

## Pripremljen tekst za podršku (nije poslat)

Our Google Play Console URL validator receives HTTP403 for https://gottaplay.net/wow/delete-data/. Cloudflare Security Events identify AS15169 Google LLC, User-Agent GooglePlayConsole, GET, Managed Challenge, service Bot fight mode. We disabled Bot Fight Mode in the dashboard and confirmed it remains OFF after reloading, but requests continued to receive the same challenge. Example:2026-09-22 14:40:57 UTC, Ray ID a3f2115879a01f6b. Please investigate why Bot Fight Mode is still being applied after disabling it and whether configuration propagation is pending. Other protections remain enabled; we do not want to disable the WAF or DDoS protection.
