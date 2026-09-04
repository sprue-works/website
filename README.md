# sprue.works website

Source for https://sprue.works: a single static page, plain HTML and CSS, no
build step. The site lives in `public/`.

## Run locally

Open `public/index.html` in a browser, or serve it the way production does:

```sh
npx wrangler dev
```

## Deploy

The site is a **Cloudflare Worker with static assets** (assets only, no
script), configured in `wrangler.jsonc` and deployed by **Workers Builds** from
this GitHub repo.

- **Production:** every push to `main` runs `npx wrangler deploy` and serves
  https://sprue.works.
- **Previews:** every other branch runs `npx wrangler versions upload`, which
  publishes a preview version aliased by branch name at
  `https://<alias>-website.igneus-fdc.workers.dev`, where
  `<alias>` is the branch name lowercased with `/` replaced by `-`. PRs get the
  URL as a comment.
- **Custom domains and DNS:** declared as `custom_domain` routes in
  `wrangler.jsonc`; the first deploy creates the DNS records and certificates in
  the existing zone.
- **www redirect:** a zone-level Redirect Rule ("www to apex") sends
  `www.sprue.works/*` to `https://sprue.works/*` with a 301. It is declared
  in `terraform/` (Workers static-asset `_redirects` files accept only
  relative source paths, so a host-based redirect has to live at the zone).
  Apply with `CLOUDFLARE_API_TOKEN` set; the header comment in
  `terraform/main.tf` has the one-time `terraform import` for the ruleset
  that already exists.
- **Build settings:** no build command. Deploy commands are the Workers Builds
  defaults.

### Cloudflare setup (one-time)

1. Cloudflare dashboard → Workers & Pages → Create → **Continue with GitHub** →
   authorise the Cloudflare GitHub App for the `sprue-works` org if prompted,
   then select `sprue-works/website`.
2. Worker name `website` (must match `name` in `wrangler.jsonc`),
   production branch `main`, no build command, deploy command left at the
   default. Create and deploy.
3. In the Worker: Settings → Build → enable **non-production branch builds**
   and **pull request comments**. Settings → Domains & Routes should already
   show `sprue.works`, `www.sprue.works`, the `workers.dev` route, and preview
   URLs enabled, all from `wrangler.jsonc`.

You can also deploy from a laptop with `npx wrangler login && npx wrangler
deploy`; Workers Builds is what keeps `main` and the branch previews in sync.

## Wordmark, typefaces, and colours

The wordmark is plain text until the logo (#1) lands: three spans (`sprue`, the
dot, `works`) so each can be styled on its own; swapping in the SVG is a
one-line change described in the comment above the `<h1>` in
`public/index.html`.

Typefaces and colours were chosen with the interactive picker, which now lives
at `public/picker/index.html`, served unlinked and `noindex`ed at
https://sprue.works/picker (a tool, not a page of the site; it loads extra
Google Fonts families from the same host the home page already uses). Below
the wordmark it renders sample body copy and a code snippet in separately
chosen Body and Code faces, so candidates can be judged as running text and
not only as display type. They are
set in one place: the "Typefaces" block at the
top of `public/style.css`, together with the Google Fonts `<link>` in
`public/index.html`. The page follows the OS colour scheme: Floral White
background with Coffee Bean / Pine Teal / Rust Brown text in light mode, Coffee
Bean background with Floral White / Muted Teal / Pumpkin Spice in dark mode.
