# Treće strane

## Godot MCP

- Izvor: https://github.com/mkdevkit/godot-mcp
- Commit: `328e15f7d38092371b2aca8b81c40b8188bbe747`
- Autor: mkdevkit; MIT licenca.
- Server izvori: `tools/godot-mcp/server/src`, package.json, package-lock.json i tsconfig.json.
- Licenca servera: `tools/godot-mcp/LICENSE`.
- Godot dodatak: `setup-probe/addons/godot_mcp`, uz njegov LICENSE.
- Lokalna izmena: `commands/scene_commands.gd` čeka process_frame pre save_scene i proverava povratni kod zbog Godot 4.7 dijaloga napretka u deferred pozivu.
- `.gd.uid` fajlovi generisani tokom uvoza čuvaju identitete resursa i verzionišu se.
- Zavisnosti Node servera zaključane su njegovim package-lock.json; instalacija putem npm ci. Njihove licence ostaju deo odgovarajućih paketa.

Kopije su obični verzionisani fajlovi, ne submodule niti ugnježden repo. Preuzeti ostali upstream fajlovi ostaju lokalni i ignorisani. Izvorni Git metapodaci sačuvani su samo lokalno u .local/.

Ne proširivati MIT licencu dodatka na našu igru: licenca celog projekta još nije izabrana. Za buduće slike, zvukove, fontove i rečnike dodati izvore, tačne verzije i licence pre uključivanja.

## Dodatni rečnici — 0.1.19

DE/FR/ES/IT: LibreOffice/dictionaries, revizija `5fe575dbcfeb789e2ab2d9731b88ac0dacc4f453`. DE i IT: GPL-3.0; FR: MPL-2.0; ES: iz ponuđene MPL-1.1-or-later izabrana MPL-2.0. Izvorne datoteke i licence sačuvane u `tools/dictionaries/`, a odgovarajući izvori i postupak obrade isporučeni u APK-u kao `game/licenses/dictionary-sources.zip`. Detalji konverzije i brojevi oblika: `docs/languages.md`.

Build alat spylls 0.1.7 (Python, MIT) instalira se isključivo lokalno, ne ulazi u aplikaciju. Novi pojedinačni gzip/zip materijali su ispod 3 MiB; nema novih datoteka preko 10 MiB i nisu uvedeni LFS obrasci. Upstream tekstualni izvori čuvaju originalne bajtove/enkoding.
