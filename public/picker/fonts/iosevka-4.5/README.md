# Iosevka 4.5.0, self-hosted for the picker (#15)

Iosevka is a stroke-built monospace whose **widths are drawn, not scaled**: the
Extended cut is 15.2% wider per character than the Normal cut at the *same*
x-height and the same stroke weights. That is what the picker's pitch modes
want and what a CSS `scaleX()` stretch can only fake, so both widths are served
from this origin rather than from a CDN that carries the Normal width alone.

| cut      | advance per character | x-height | OS/2 width class |
| -------- | --------------------- | -------- | ---------------- |
| Normal   | 0.500 em              | 0.530 em | 5                |
| Extended | 0.576 em              | 0.530 em | 7                |

## What these files are

Nine weights (100–900) of each cut, upright only, subset to Latin and repacked
as woff2 at roughly 8.5 KB per face. They come from the `iosevka-valkyrie`
package on npm, which ships a **custom Iosevka build**, not an official
release:

- Font version: `4.5.0` (2021), built with ttfautohint 1.8.3
- Copyright: `Copyright 2015-2021, Renzhi Li (aka. Belleve Invis, belleve@typeof.net)`
- Licence: SIL Open Font License 1.1, per the name table of the files
  themselves; the full text is in `OFL.txt`. The font declares no Reserved
  Font Name, so subsetting needs no rename. Note that the npm package's own
  metadata claims MPL-2.0, which contradicts the font and is wrong.
- Subset: `U+0020-007E, U+00A0-00FF, U+2013, U+2014, U+2018-201A, U+201C-201E,
  U+2022, U+2026`, via `pyftsubset --flavor=woff2 --layout-features=''
  --no-hinting --desubroutinize`

**Caveat worth knowing before any of this is adopted.** A custom Iosevka build
selects character variants, so these letterforms are not guaranteed to match an
official Iosevka release. The picker keeps the official current Iosevka (5.3.0,
Normal width, from Fontsource) under the plain name `Iosevka` so the shapes can
be compared. Judge width here; judge letterforms against that.

## Replaced by our own build

This build has been replaced for the brand by our own: Iosevka 34.8.1 built
from source by `.github/workflows/iosevka-build.yml`, in
`../iosevka-sprue-34.8.1-run10/`. That directory's README records the plan,
the upstream commit and the hashes a rebuild reproduces. The files here stay,
unchanged, for comparison in the picker as "Iosevka 4.5" and "Iosevka 4.5
Extended". The `/picker/fonts/*` rule in `public/_headers` serves them as
`immutable`, so they are never overwritten.
