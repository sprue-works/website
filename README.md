# sprue.works website

Source for https://sprue.works: a single static page, plain HTML and CSS, no
build step. The site lives in `public/`, which also serves the hosted brand
theme (`public/brand/`, documented in `brand/README.md`).

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
  relative source paths, so a host-based redirect has to live at the zone)
  and applied from `main` by GitHub Actions; see [Terraform](#terraform).
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

## Terraform

`terraform/` holds the zone-level Cloudflare configuration that cannot live in
`wrangler.jsonc` (today, the www redirect ruleset). Nothing in it is applied by
hand.

- **State** lives in the GCS bucket `sprue-works-website-tfstate` under the
  prefix `terraform/website/cloudflare`, provisioned by
  sprue-works/infrastructure#3. `terraform/backend.tf` declares an empty `gcs`
  backend; the bucket and prefix are passed at `init` from the repository
  variables `TF_STATE_BUCKET` and `TF_STATE_PREFIX`.
- **Identity.** The workflow authenticates to Google with GitHub OIDC through
  the workload identity provider named in the repository variable
  `GCP_WORKLOAD_IDENTITY_PROVIDER`. The provider trusts exactly this
  repository's `refs/heads/main` ref subject, so only the apply job on a push
  to `main` (or a `workflow_dispatch` run on `main`) can reach the bucket. The
  job must not name a GitHub Environment, which would change the subject.
  There is no routine local access: a laptop cannot `init` against the bucket
  without the temporary break-glass binding described under "Migrating
  state". To confirm the isolation, dispatch the separate "OIDC isolation
  check" workflow (`.github/workflows/oidc-isolation-check.yml`) from a branch
  other than `main`. It references no secrets, exchanges that branch's OIDC
  token with Google's STS endpoint directly, and passes only when the 400 or
  403 response body says "rejected by the attribute condition"; an accepted
  token fails as an incident, and any other response fails as a configuration
  error.
- **Workflow.** `.github/workflows/terraform.yml` runs on changes under
  `terraform/`. Pull requests get `fmt -check`, `init -backend=false`, and
  `validate` only; a push to `main` that touches those paths, or a manual
  dispatch on `main`, additionally plans and applies. The apply job is the
  only place the Cloudflare token appears. Repository secrets are readable by
  any branch's workflow definition in GitHub's model; an environment secret
  would be stronger, but naming an environment changes the OIDC subject the
  provider trusts, so the boundary here is the protected `main` branch and
  who may push branches to this repository at all. The
  Cloudflare provider reads the repository secret `CLOUDFLARE_API_TOKEN`,
  which needs `Zone:Read` and `Zone → Dynamic Redirect:Edit` on the
  sprue.works zone.
- **Import.** The redirect ruleset was created through the Cloudflare API
  before the Terraform existed. An `import` block in `terraform/main.tf`
  adopts it on the first apply from `main`. That first plan is expected to
  read `1 to import, 0 to add, 0 to change, 0 to destroy`; an in-place change
  there means the live rule and the HCL have drifted, so stop and reconcile.
  Every later plan should report no changes. The block is a no-op once the
  resource is in state and stays as a record of where it came from.
- **Local loop.** `terraform -chdir=terraform fmt -recursive`, then
  `terraform -chdir=terraform init -backend=false && terraform -chdir=terraform
  validate`. Plans need the bucket, so run them from `main` via the workflow.
- **Migrating state.** This repository never had local state to migrate (the
  ruleset was left unimported until the bucket existed). If a local
  `terraform.tfstate` ever needs moving, an operator with a temporary
  break-glass binding on the bucket runs, from a checkout of `main`:

  ```sh
  terraform -chdir=terraform init -migrate-state \
    -backend-config="bucket=sprue-works-website-tfstate" \
    -backend-config="prefix=terraform/website/cloudflare"
  ```

  and deletes the local file afterwards. The consumer onboarding runbook in
  sprue-works/infrastructure (`docs/consumers.md`) covers the break-glass
  binding and the isolation checks.

## Wordmark, typefaces, and colours

The wordmark is plain text until the logo (#1) lands: three spans (`sprue`, the
dot, `works`) so each can be styled on its own; swapping in the SVG is a
one-line change described in the comment above the `<h1>` in
`public/index.html`.

Typefaces and colours were chosen with the interactive picker, which now lives
at `public/picker/index.html`, served unlinked and `noindex`ed at
https://sprue.works/picker (a tool, not a page of the site; it loads extra
Google Fonts families from the same host the theme already uses). Below
the wordmark it renders sample body copy and a code snippet in separately
chosen Body and Code faces, so candidates can be judged as running text and
not only as display type. They are
defined once, as `--sw-*` custom properties in the hosted brand theme
`public/brand/v1/theme.css` (served at https://sprue.works/brand/v1/theme.css
with a long immutable cache via `public/_headers`); `public/style.css` only
composes those variables. Other sprue.works properties link the same file; see
`brand/README.md` for the consumer snippet, the variable list, and the
versioning rule. The page follows the OS colour scheme: Floral White
background with Coffee Bean / Pine Teal / Rust Brown text in light mode, Coffee
Bean background with Floral White / Muted Teal / Pumpkin Spice in dark mode.
