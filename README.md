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

Everything except the GitHub App install is in `terraform/`.

1. Install the Cloudflare Pages GitHub App on the `sprue-works` org: Cloudflare
   dashboard → Workers & Pages → Create → Pages → Connect to Git → authorise
   GitHub and grant access to `sprue-works/website`. Stop there; do not create
   the project by hand.
2. Apply the Terraform. It creates the Pages project (production branch `main`,
   no build command, previews for all non-production branches), adds the
   `sprue.works` and `www.sprue.works` custom domains, and creates the two
   proxied CNAME records in the zone:

   ```sh
   export CLOUDFLARE_API_TOKEN=...   # Pages:Edit + DNS:Edit on the sprue.works zone
   export TF_VAR_account_id=...
   export TF_VAR_zone_id=...
   cd terraform && terraform init && terraform apply
   ```

   Commit the `.terraform.lock.hcl` that `init` writes.
3. The first production deploy happens on the next push to `main`; open
   deployments in the dashboard or push an empty commit to trigger one.

## Wordmark and typeface

The wordmark is plain text until the logo (#1) lands. `sprue` and `.works` are
separate spans so they can be styled independently; swapping in the SVG is a
one-line change described in the comment above the `<h1>` in `index.html`.

The typeface is set in one place: the `--wordmark-font` block at the top of
`style.css`, together with the Google Fonts `<link>` in `index.html`.
