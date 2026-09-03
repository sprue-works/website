# sprue.works brand theme

The org's colours and typefaces as one hosted stylesheet of CSS custom
properties, so any sprue.works property can use them with no tooling:

    https://sprue.works/brand/v1/theme.css

The source is `public/brand/v1/theme.css` in this repo (the site has no build
step, so the served file is the source). Other brand assets will sit next to it
under `/brand/v1/`, e.g. the logo at `/brand/v1/logo.svg` once #1 lands.

## Use it

Paste into `<head>`, before your own stylesheet:

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://sprue.works/brand/v1/theme.css" />
<style>
  body {
    background: var(--sw-bg, #fff7ed);
    color: var(--sw-fg, #251818);
    font-family: var(--sw-font-body, system-ui, sans-serif);
  }
  a { color: var(--sw-accent, #904114); }
  code { font-family: var(--sw-font-mono, ui-monospace, monospace); }
</style>
```

The theme `@import`s the Google Fonts CSS it needs, so nothing else is
required. The two `preconnect` hints are optional but shave a round trip.

**Always give `var()` a fallback**, as above. The theme only defines variables;
if sprue.works is unreachable the page then degrades to your fallbacks
(unstyled but readable) rather than to invalid CSS. The theme also sets
`color-scheme` on `:root`, so form controls follow the OS light/dark setting.

## Variables

Everything is prefixed `--sw-` so it cannot collide with your own variables.

Semantic colours (switch automatically with `prefers-color-scheme`):

| Variable | Light | Dark |
|---|---|---|
| `--sw-bg` | Floral White | Coffee Bean |
| `--sw-fg` | Coffee Bean | Floral White |
| `--sw-muted` | Coffee Bean 60% over bg | Floral White 55% over bg |
| `--sw-accent` | Rust Brown | Pumpkin Spice |
| `--sw-color-sprue` / `--sw-color-dot` / `--sw-color-works` | Coffee Bean / Pine Teal / Rust Brown | Floral White / Muted Teal / Pumpkin Spice |

Raw palette (scheme-independent): `--sw-bronze-spice` `#c2571b`,
`--sw-pumpkin-spice` `#f97316`, `--sw-pine-teal` `#134e4a`, `--sw-royal-gold`
`#f9dc5c`, `--sw-floral-white` `#fff7ed`, `--sw-muted-teal` `#7fc6a4`,
`--sw-rust-brown` `#904114`, `--sw-coffee-bean` `#251818`.

Type:

| Variable | Value |
|---|---|
| `--sw-font-body` | system UI stack |
| `--sw-font-mono` | IBM Plex Mono, monospace fallbacks |
| `--sw-font-sprue` / `--sw-weight-sprue` | Quicksand / 700 |
| `--sw-font-dot` / `--sw-weight-dot` | Nunito / 300 |
| `--sw-font-works` / `--sw-weight-works` | IBM Plex Mono / 300 |
| `--sw-dot-gap-after`, `--sw-works-scale`, `--sw-works-tracking` | wordmark optical corrections |
| `--sw-text-xs` … `--sw-text-4xl` | 0.75 / 0.875 / 1 / 1.125 / 1.25 / 1.5 / 2 / 2.5 rem |
| `--sw-leading-tight` / `--sw-leading-normal` | 1.2 / 1.5 |

Spacing `--sw-space-1` … `--sw-space-8` (0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4 rem)
and radii `--sw-radius-sm` / `-md` / `-lg` / `-full` (2px, 4px, 8px, pill).

## Versioning and caching

`/brand/v1/` is cached with `Cache-Control: public, max-age=31536000,
immutable` (see `public/_headers`). The rule:

- **Additive** changes (a new token, an adjusted value) stay in v1. Because of
  the immutable cache, repeat visitors of a consumer pick them up only when
  their cached copy expires, so treat value changes as slow to roll out.
- **Breaking** changes (renaming or removing a token) ship as
  `/brand/v2/theme.css`; v1 keeps serving unchanged.

The home page at https://sprue.works is the first consumer: `public/style.css`
reads every colour and typeface from these variables, so the site cannot drift
from the theme.
