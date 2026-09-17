# Fonts

Original font files from Google Fonts, distributed under the SIL Open Font License. Full notices: `../../licenses/`.

| File | Pinned upstream revision | SHA256 |
| --- | --- | --- |
| Cinzel.ttf | google/fonts `45071f07c63e863a539442ef3562b71ab1f147a6`, `ofl/cinzel/Cinzel[wght].ttf` | f4d83d34d1f6c741193e4acf4b3dff9531e5a67b6aa65228d00a7db72a4e0f34 |
| Lato-Bold.ttf | google/fonts `f3b885d5590e307e02542f1a724cec55d567fdaa`, `ofl/lato/Lato-Bold.ttf` | 8a0aace75d33794eece4b28187bfc1df0bbd2888b5d8a56e01788c8d65d16be1 |
| NotoSerif.ttf | google/fonts `8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5`, `ofl/notoserif/NotoSerif[wdth,wght].ttf` | 4d8e6761424656867019081a1a01336f3cb086982682698714054fc33f782713 |

Sources: https://github.com/google/fonts/tree/45071f07c63e863a539442ef3562b71ab1f147a6/ofl/cinzel and https://github.com/google/fonts/tree/f3b885d5590e307e02542f1a724cec55d567fdaa/ofl/lato. Retrieved 2026-09-16. Cinzel heading weight is set to 800 at runtime with the numeric OpenType wght tag; body/UI text uses Lato Bold.

0.1.2 uses **Noto Serif at weight 800** for headings and letters, replacing Cinzel in runtime text to give Serbian Đ/đ a clear conventional crossbar and consistent accented glyphs. Lato Bold remains the body font; Cinzel is retained as an earlier design source. Noto upstream: https://github.com/google/fonts/tree/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/notoserif. Retrieved 2026-09-17, unchanged variable font, SIL OFL in `../../licenses/NotoSerif-OFL.txt`. The brand title uses original illustration artwork, not a replacement text font. Tests check all Serbian diacritics in both active fonts; visual QA renders ĐAK and UNAPREĐENJA at actual UI size.
