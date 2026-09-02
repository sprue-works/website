# sprue.works website

Source for https://sprue.works: a single static page, plain HTML and CSS, no
build step.

## Run locally

Open `index.html` in a browser. For a proper origin (so the Google Fonts
`preconnect` hints behave), serve the directory instead:

```sh
python3 -m http.server 8000
```

## Deploy

The site is hosted on **Cloudflare Pages**, connected to this GitHub repo.

- **Production:** every push to `main` deploys to https://sprue.works.
- **Previews:** every other branch (including PR branches) gets its own
  `https://<branch>.<project>.pages.dev` URL, with `/` in the branch name
  replaced by `-`.
- **Build settings:** none. No build command, output directory `/`.
- **Redirects:** `_redirects` sends `www.sprue.works` to the apex.

### Cloudflare setup (one-time)

1. Cloudflare dashboard → Workers & Pages → Create → Pages → Connect to Git →
   `sprue-works/website`. Name the project `sprue-works-website` (or pass
   `-var pages_hostname=<name>.pages.dev` in step 4). Production branch `main`,
   no framework preset, build command empty, output directory `/`.
2. Settings → Builds & deployments → Preview branches: **All non-production
   branches**.
3. Custom domains → add `sprue.works` and `www.sprue.works`.
4. DNS: apply `terraform/` (needs `CLOUDFLARE_API_TOKEN` and the zone ID), or
   create the two proxied `CNAME` records to `<project>.pages.dev` by hand.

## Wordmark and typeface

The wordmark is plain text until the logo (#1) lands. `sprue` and `.works` are
separate spans so they can be styled independently; swapping in the SVG is a
one-line change described in the comment above the `<h1>` in `index.html`.

The typeface is set in one place: the `--wordmark-font` block at the top of
`style.css`, together with the Google Fonts `<link>` in `index.html`.
