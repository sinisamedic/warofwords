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
