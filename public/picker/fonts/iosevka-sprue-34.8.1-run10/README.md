# Iosevka Sprue — our own build (#15)

These are the files the brand uses. They come from **our** build of upstream
Iosevka 34.8.1, made by `.github/workflows/iosevka-build.yml` with the build
plan that workflow writes, not from a release or a package:

| | |
| --- | --- |
| Upstream | `be5invis/Iosevka` at `fe27e532e296102a2afb5b27963cf034a50866f7`, version 34.8.1 |
| Built by | `Build Iosevka` workflow, run 10 (2026-09-23), `npm ci` against upstream's lockfile |
| Family name | `Iosevka Sprue` (Iosevka declares no Reserved Font Name; a custom build gets a custom name) |
| Licence | SIL Open Font License 1.1, `OFL.txt` beside these files |
| Ligatures | `default-calt`, landing in `calt` and `dlig` — arrows, `!=`, `<=`, `>=`, `|>` ligate without the consumer opting in |
| Subset | `U+0020-007E, U+00A0-017F, U+0370-03FF, U+2010-2027, U+2030-203A, U+20AC, U+2190-21FF, U+2200-22FF, U+2300-23FF, U+2500-259F, U+25A0-25FF, U+2713-2718`: Latin, Latin Extended-A, Greek, punctuation, arrows, maths, technical symbols, box drawing, blocks, shapes, check marks. pyftsubset's default layout features plus `dlig`, so `ccmp` and `locl` survive alongside the ligatures |

| cut | advance per character | x-height | weights here |
| --- | --- | --- | --- |
| normal | 0.500 em | 0.520 em | 200, 300, 500 |
| extended | 0.576 em | 0.520 em | 200, 300, 500 |

200 is the wordmark's "works" weight and 500 is the code weight; 300 is kept
because the comparisons that chose this face were made at it. Another weight
means another run of the workflow — every weight Iosevka draws is available,
and `shape` in the plan takes any advance between the two cuts as well.

## Reproducible

The workflow pins each face's `head.created` and `head.modified` to the
upstream commit's own date, pins `fonttools` and `brotli`, and installs with
`npm ci`, so the same commit and plan produce the same bytes. A bare run of
the workflow rebuilds exactly these (sha256, first 16 hex digits, as run 10's
`MANIFEST.txt` records them):

```
extended-200  bd9925e083473286      normal-200  b8a1ff10e6496668
extended-300  a6fd1b99a8c86e19      normal-300  cc895ebb83089b13
extended-500  9aa8b4990c41d125      normal-500  395fdbc032b0a2a3
```

Built with Iosevka's `term` spacing, so every glyph is one cell: arrows,
`…`, `‰` and the dashes take the same 0.576em (0.500em in Normal) as a
letter, and a line of code keeps its columns whatever it contains.
Ligatures still apply (`fixed` is the spacing that drops them).

Two earlier builds of the same commit were replaced before they shipped:
run 6 (Latin-1 only, five layout features kept) and run 9 (this subset, but
`normal` spacing, which draws those symbols two cells wide). The printable
ASCII outlines of all three are identical, so no wordmark measurement moved.

## Not these files: `../iosevka-4.5/`

That directory is a **third-party** custom build of Iosevka 4.5.0 from npm,
added when this session could not reach the Iosevka repository. It stays for
comparison. Its x-height is 530 against the 520 here, it carries no layout
features at all (so it cannot ligate), and its provenance is a package whose
metadata contradicts the licence in its own name table.

## Replacing these

`/picker/fonts/*` is served `immutable` for a year by the rule in
`public/_headers`, so a path must keep its bytes forever. A new build goes in
a **new sibling directory** named for it, and the `FAMILIES` paths in
`public/picker/index.html` point at that.
