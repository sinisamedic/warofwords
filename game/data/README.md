# English dictionary

Source: [SCOWL 2020.12.07](https://downloads.sourceforge.net/project/wordlist/SCOWL/2020.12.07/scowl-2020.12.07.zip), an explicit versioned release of [en-wl/wordlist](https://github.com/en-wl/wordlist).

- Archive SHA256: `dc3435e1cb56f3394aea91b5d2ab5d10d80c98bc7dd88c3fccb7348f6ab913a0`.
- Files: `final/{english,american}-words.{10,20,35,40,50,55,60}`.
- Include only lowercase ASCII words of 3–16 letters, unique and sorted. No proper-name, abbreviation, hyphenated or apostrophe lists. Common inflections and rarer vocabulary are included. This is a spelling dictionary, not a definitions database or an age-rating filter.
- 76,802 entries. Runtime matching is case-insensitive.
- Generated UTF-8/LF dictionary SHA256: `4e4d3f4b7aac716a64c013ef16788fbd6e0fc2ec6cd7a86e2268597bd561b01b`.
- Word solver searches paths up to 12 letters for board checks/hints; manual submissions can use the full dictionary.
- Copyright and permission notices are in `../licenses/SCOWL-Copyright.txt`; upstream README is also retained.

Rebuild from the unchanged archive, from repo root:

```powershell
./tools/build-dictionary.ps1 -ScowlZip .local/downloads/scowl.zip
```

Dictionary data is committed; players and developers do not need to download it separately.

## Serbian Latin — test dictionary, 0.1.1

- Source: LibreOffice/dictionaries, **sr/** at commit `5fe575dbcfeb789e2ab2d9731b88ac0dacc4f453`.
- [Upstream README and licensing](https://github.com/LibreOffice/dictionaries/blob/5fe575dbcfeb789e2ab2d9731b88ac0dacc4f453/sr/README.txt). Author: Milutin Smiljanic. We elect **MPL-2.0** from the upstream license alternatives. This license covers the dictionary source and derived word list, not unrelated game code.
- Unmodified `sr-Latn.dic`, `sr-Latn.aff`, README are retained in `tools/dictionaries/sr/`. License and source notice also ship in `game/licenses/` inside the APK.
- Build: `node tools/build-serbian-dictionary.cjs`. Requires only Node built-ins, no network. Applies the pinned numeric prefix/suffix rules and cross products; excludes uppercase source entries, punctuation, abbreviations containing punctuation, and foreign letters. Keeps **3–12 Serbian alphabet tiles** per word. No general guarantee that every colloquial word is included or that every homograph is suitable for a word game.
- **1,740,276 forms**, including noun cases and verb inflections. The uncompressed UTF-8/LF list is 19,373,889 bytes, SHA256 `515ac56e66dfdcb272116cac546dc72230a8da6a38a88fa089bf1f44eb3a6a91`.
- Stored as `serbian.txt.gz` (4,057,209 bytes) to avoid a large uncompressed Git asset. Its complete preferred source and reproduction script are included. No LFS needed: every new binary is under 10 MiB.
- Č, Ć, Š, Đ, Ž and single-tile **LJ, NJ, DŽ**. At least three selected tiles; energy and damage use the number of selected tiles. Tutorial begins with KAMEN. This is a spelling resource for testing, not a curated tournament word list or definitions database.
- Runtime uses sorted strings and binary search with a short prefix index, avoiding a large per-word hash map. Dictionary loading happens on a background thread and both selected dictionaries can be cached. UI and dictionary choices are independent. Each saved duel records its dictionary; 0.1.0 saves default to English.
