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

1. **Create the Cloudflare Pages project — as Direct Upload, not Connect to Git.**
   Dashboard → Workers & Pages → Create → Pages → Upload assets, named to match
   `CF_PAGES_PROJECT` below. The Action publishes with `wrangler pages deploy`,
   which is a direct upload; connecting the project to Git as well would give
   every push two competing deploys of the same commit.
2. **Point the domain at it.** Add `preview.vocsotech.com` as a custom domain on that
   Pages project.
3. **Add the repository secrets** (Settings → Secrets and variables → Actions):

   | Secret | Where it comes from |
   |---|---|
   | `CLOUDFLARE_API_TOKEN` | Cloudflare → My Profile → API Tokens, with the "Cloudflare Pages — Edit" template |
   | `CLOUDFLARE_ACCOUNT_ID` | Cloudflare dashboard URL, or the right-hand sidebar |
   | `DEPLOY_WEBHOOK_SECRET` | Must match PROSPECTS → Settings → Playbooks → Deploy webhook secret |

4. **Add the repository variables** (same screen, Variables tab):

   | Variable | Example |
   |---|---|
   | `CF_PAGES_PROJECT` | `vocso-websites` |
   | `PROSPECTS_URL` | `https://go.vocsotech.com` — no trailing slash |
   | `WEBSITES_BASE_URL` | `https://preview.vocsotech.com` — no trailing slash |

## What the Action does

On every push to `main` it publishes the whole `sites/` folder, then works out
which site folders that push touched and reports each one to PROSPECTS.

A slug with no matching project returns 404 and is skipped rather than failing
the run — that's a hand-built site or a rename, not a broken deploy. If the
publish itself fails, the Action reports `status: failed`, which alerts the team
instead of leaving the lead's project stuck in Building.
