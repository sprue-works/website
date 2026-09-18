# sprue.works brand assets

Two hosted stylesheets, so any sprue.works property can use the brand with no
tooling:

    https://sprue.works/brand/v1/theme.css     colours and typefaces as tokens
    https://sprue.works/brand/v1/wordmark.css  the wordmark built from them

The sources are `public/brand/v1/theme.css` and `public/brand/v1/wordmark.css`
in this repo (the site has no build step, so the served files are the sources).
Other brand assets will sit next to them under `/brand/v1/`, e.g. the logo at
`/brand/v1/logo.svg` once #1 lands.

## Use the theme

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

Swapping a typeface is a two-part change in `theme.css`: the `--sw-font-*`
token and the family list in the `@import` at the top, since the token alone
does not load a webfont.

Spacing `--sw-space-1` … `--sw-space-8` (0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4 rem)
and radii `--sw-radius-sm` / `-md` / `-lg` / `-full` (2px, 4px, 8px, pill).

## Use the wordmark

`wordmark.css` holds the rules that turn the wordmark tokens into the mark, so
no property has to copy them. Link it after the theme, which is what loads the
webfonts, and write the three spans with **no whitespace between them**:

```html
<link rel="stylesheet" href="https://sprue.works/brand/v1/theme.css" />
<link rel="stylesheet" href="https://sprue.works/brand/v1/wordmark.css" />

<a class="sw-wordmark" href="https://sprue.works"><span class="sw-wordmark__sprue">sprue</span><span class="sw-wordmark__dot">.</span><span class="sw-wordmark__works">works</span></a>
```

The spans go inside any element you like — a link, a heading, a nav item.

**Colour and size are inherited.** The file sets no `color` and no
`font-size`, so the mark comes out in the surrounding text's `currentColor` at
the surrounding text's size; style the element around it as you would any other
text. Add `sw-wordmark--brand` for the coloured logo treatment, which sets each
span from `--sw-color-sprue` / `--sw-color-dot` / `--sw-color-works` and so
follows the light/dark scheme:

```html
<span class="sw-wordmark sw-wordmark--brand">… the same three spans …</span>
```

| Class | What it does |
|---|---|
| `.sw-wordmark` | keeps the mark on one line and resets inherited letter-spacing |
| `.sw-wordmark__sprue` | Quicksand 700 |
| `.sw-wordmark__dot` | Nunito 300, pulled `--sw-dot-gap-after` closer to "works" |
| `.sw-wordmark__works` | IBM Plex Mono 300, scaled and tracked to match "sprue", with the tracking's trailing edge given back |
| `.sw-wordmark--brand` | modifier: colours the three spans from the palette |

Every value comes from a `--sw-*` token with the token's own value as a literal
fallback, so the mark still sets if the theme is unreachable — on the
platform's own faces, since the webfonts come from the theme too, and on the
light-scheme colours, since the dark ones do as well.

The mark occupies its true width, so it sits in a line exactly as the same
words set in the same faces would — there is nothing to compensate for at your
end. (CSS applies `letter-spacing` after the last letter as well as between
them, and the tracking on "works" was measured across the four gaps between
the five letters, not five; `wordmark.css` gives the difference back as a
margin so it cannot eat space after the mark.)

## Versioning and caching

Everything under `/brand/v1/` is cached with `Cache-Control: public,
max-age=31536000, immutable` (see the `/brand/*` rule in `public/_headers`).
The rule, for both files:

- **Additive** changes (a new token or class, an adjusted value) stay in v1.
  Because of the immutable cache, repeat visitors of a consumer pick them up
  only when their cached copy expires, so treat value changes as slow to roll
  out.
- **Breaking** changes (renaming or removing a token or a class) ship as
  `/brand/v2/`; v1 keeps serving unchanged.

The home page at https://sprue.works is the first consumer of both:
`public/style.css` reads every colour and typeface from the theme's variables
and is left with nothing but the page's own display sizing of the mark, and
`public/index.html` carries the same `sw-wordmark` classes any other property
would. Neither file can drift from what is served.
