# sprue.works website

Source for https://sprue.works: a single static page, plain HTML and CSS, no
build step. The site lives in `public/`.

## Run locally

Open `public/index.html` in a browser, or serve it the way production does
(this also exercises `_redirects`):

```sh
npx wrangler dev
```

## Deploy

The site is a **Cloudflare Worker with static assets** (assets only, no
script), configured in `wrangler.jsonc` and deployed by **Workers Builds** from
this GitHub repo.

- **Production:** every push to `main` runs `npx wrangler deploy` and serves
  https://sprue.works. `www.sprue.works` redirects to the apex via
  `public/_redirects`.
- **Previews:** every other branch runs `npx wrangler versions upload`, which
  publishes a preview version aliased by branch name at
  `https://<alias>-sprue-works-website.<account-subdomain>.workers.dev`, where
  `<alias>` is the branch name lowercased with `/` replaced by `-`. PRs get the
  URL as a comment.
- **Custom domains and DNS:** declared as `custom_domain` routes in
  `wrangler.jsonc`; the first deploy creates the DNS records and certificates in
  the existing zone, so nothing is managed by hand or in Terraform.
- **Build settings:** no build command. Deploy commands are the Workers Builds
  defaults.

### Cloudflare setup (one-time)

1. Cloudflare dashboard → Workers & Pages → Create → **Continue with GitHub** →
   authorise the Cloudflare GitHub App for the `sprue-works` org if prompted,
   then select `sprue-works/website`.
2. Project name `sprue-works-website` (must match `name` in `wrangler.jsonc`),
   production branch `main`, no build command, deploy command left at the
   default. Create and deploy.
3. In the Worker: Settings → Build → enable **non-production branch builds**
   and **pull request comments**. Settings → Domains & Routes should already
   show `sprue.works`, `www.sprue.works`, the `workers.dev` route, and preview
   URLs enabled, all from `wrangler.jsonc`.

You can also deploy from a laptop with `npx wrangler login && npx wrangler
deploy`; Workers Builds is what keeps `main` and the branch previews in sync.

## Wordmark and typeface

The wordmark is plain text until the logo (#1) lands. `sprue` and `.works` are
separate spans so they can be styled independently; swapping in the SVG is a
one-line change described in the comment above the `<h1>` in
`public/index.html`.

The typeface is set in one place: the `--wordmark-font` block at the top of
`public/style.css`, together with the Google Fonts `<link>` in
`public/index.html`.
