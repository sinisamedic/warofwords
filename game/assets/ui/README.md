# Original vector UI artwork

Token SVGs and metal disc are original code-authored artwork for War of Words,
2026-09-16. Reproduce them with `node tools/build-ui-tokens.cjs` from the repository
root. Gold bevels, enamel gradients and specular highlights are rendered once on
import and reused as texture quads during play. Letters, paths, ornaments and
ability charge rings remain dynamic Godot drawing commands.

No third-party icon set or bitmap post-processing is used here. Illustrated
ability content comes from the separately documented ImageGen atlas in `../art/`.
