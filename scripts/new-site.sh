#!/usr/bin/env bash
# Start a new site folder from a slug.
#
#   ./scripts/new-site.sh acme-dental-co
#
# The slug is the one printed on the project's card in PROSPECTS, under the
# "Rebuilt site URL" field. It has to match, or the deploy webhook won't know
# which lead the site belongs to.
set -euo pipefail

slug="${1:-}"
if [ -z "$slug" ]; then
  echo "usage: $0 <slug>   (copy it from the project card in PROSPECTS)" >&2
  exit 1
fi

if [ -d "sites/$slug" ]; then
  echo "sites/$slug already exists." >&2
  exit 1
fi

mkdir -p "sites/$slug"
cp sites/example-dental/index.html "sites/$slug/index.html"
echo "Created sites/$slug — build it, commit, push. The deploy reports itself."
