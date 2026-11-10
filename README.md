# Rebuilt client sites

Every website we build for a redesign lead, one folder per site, published to a
single Cloudflare Pages project.

```
sites/
  acme-dental-co/index.html
  bright-smile/index.html
```

Each folder is served at `https://preview.vocsotech.com/<folder>`.

**The folder name is the slug PROSPECTS generated for that lead.** It's printed
on the project's card, under the "Rebuilt site URL" field. If it doesn't match,
the deploy webhook can't tell which lead the site belongs to and the project sits
in Building forever.

## Building a site

```bash
./scripts/new-site.sh acme-dental-co   # copies the example as a starting point
# build it with Claude, or by hand
git add sites/acme-dental-co && git commit -m "Acme Dental" && git push
```

That's the whole loop. The push deploys the site and tells PROSPECTS, which moves
the project to **Built — review**. Someone then looks at it and clicks send.

## One-time setup

Cloudflare Pages watches this repository directly and publishes on every push,
the same way the stackroom site works. That means **no API token, no Cloudflare
credentials in GitHub, and no build step in CI.**

1. **Create the Pages project from Git.** Cloudflare → Workers & Pages → Create
   → Pages → **Connect to Git** → pick `vocso-com/website-previews`.
   - Framework preset: **None**
   - Build command: *(leave empty)*
   - Build output directory: **`sites`**
2. **Point the domain at it.** On that project → Custom domains → add
   `preview.vocsotech.com`. DNS is set up automatically when the zone is on the
   same Cloudflare account.
3. **Add one repository secret** (Settings → Secrets and variables → Actions):

   | Secret | Where it comes from |
   |---|---|
   | `DEPLOY_WEBHOOK_SECRET` | Must match PROSPECTS → Settings → Playbooks → Deploy webhook secret |

4. **Add the repository variables** (same screen, Variables tab):

   | Variable | Example |
   |---|---|
   | `PROSPECTS_URL` | `https://go.vocsotech.com` — no trailing slash |
   | `WEBSITES_BASE_URL` | `https://preview.vocsotech.com` — no trailing slash |

> A Pages project is fixed at creation as either **direct upload** or
> **Git-connected** — Cloudflare will not convert one into the other. If a
> direct-upload project is already using the name you want, delete it first.

## What the workflow does

Cloudflare does the publishing. The workflow only tells PROSPECTS about it.

On every push to `main` it works out which site folders changed, waits until
each one is actually reachable at its public URL, and only then reports it. The
wait matters: Cloudflare builds asynchronously after the push, so reporting
straight away would tell a lead their site is ready slightly before it is.

A slug with no matching project returns 404 and is skipped rather than failing
the run — that's a hand-built site or a rename, not a broken deploy. A site that
never becomes reachable is reported as a failed deploy, which alerts the team
rather than leaving the lead's project stuck in Building.
