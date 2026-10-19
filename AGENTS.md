# sprue.works website

Source for https://sprue.works: a single static page in `public/` (plain HTML
and CSS, no build step) that also serves the hosted brand theme (`public/brand/`,
documented in `brand/README.md`), deployed as a Cloudflare Worker with static
assets, plus zone-level Cloudflare config in `terraform/`. `README.md` covers
running it locally, deploys and branch previews, and the Terraform workflow.

## Repository instructions

This root `AGENTS.md` is the only project instruction file. Claude Code
(2.1.277 and later) reads it as a fallback when no `CLAUDE.md` exists in the
project hierarchy, so don't add a `CLAUDE.md`: its presence switches that
fallback off. Keep Claude-specific behavior in Claude-owned surfaces such as
`.claude/settings.json`.

## Ticket workflow

This repo uses the **`ticket-workflow`** plugin from the
[`maguerrieri-toolbox`](https://github.com/maguerrieri/claude-toolbox)
marketplace (`/make-ticket`, `/start-ticket`, `/finish-ticket`,
`/spawn-tickets`, `/start-epic`, `/spawn-epic`, each also available
plugin-qualified as `/ticket-workflow:<name>`): files an issue, takes it
through a reviewed PR, and lands it. The `Tracker:`/`Profile:` lines below
configure it for this repo, so a plain "fix this" or "add that" ask here
triggers it too: the skill files an issue, then starts it:

```
Tracker: github
Profile: default
```

Work is tracked in **GitHub Issues**. Commits follow the `conventions`
plugin's format: `[#<n>] (flags) scope: description` — the GitHub issue in
brackets, AI-assistance flags in the subject parens (e.g.
`[#17] (Claude Code) brand: Set the wordmark LTR`). PR titles follow its
`pr-conventions` skill: `scope: Description (#<n>)`, with no flags. Common
scopes: `site`, `brand`, `docs`, `ci`, `repo`.

## Plugins

`.claude/settings.json` registers the marketplace over GitHub and enables
`ticket-workflow`, its dependency `spawn`, and `conventions`. Interactive
sessions install them when the folder is trusted. List a plugin's
dependencies next to it there: the settings-triggered install doesn't resolve
them, so a plugin enabled without them loads nothing. Cloud sessions (Claude
Code on the web) skip repo-declared plugins, so the `SessionStart` hook in the
same file fetches and runs the toolbox's `.claude/hooks/session-start.sh`,
which installs every enabled plugin from that marketplace; the hook skips the
fetch unless `CLAUDE_CODE_REMOTE` is `true`, so it does nothing locally.
A cloud session with several repositories attached loads no repository's
hooks, so there the plugins arrive only from outside the repo: enable the
marketplace on your claude.ai account (Customize › Plugins › Add marketplace)
so its plugins sync into every cloud session, or run the same install from the
cloud environment's setup script. `/start-ticket` creates worktrees under
`.claude/worktrees/`, which `.gitignore` excludes. Headless runs (`claude -p`, the SDK) install
nothing from these settings.
