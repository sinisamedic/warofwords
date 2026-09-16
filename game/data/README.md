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
