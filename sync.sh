#!/bin/sh
# Refresh docs/ (the published site) from the halt page in sora2-network.
#
#   ./sync.sh <path to a sora2-network clone> <commit>
#
# Copies misc/bridge-halt-web exactly as committed at <commit>, not as it is in
# the clone's working tree. It leaves out that folder's README.md and
# fetch-vendor.sh, checks the vendored bundles against vendor/SHA256SUMS and
# records the commit in SOURCE_COMMIT. docs/CNAME and docs/.nojekyll belong to
# this repository and are kept.
#
# To check the published copy, run it with the commit already in SOURCE_COMMIT;
# `git status --short` then prints nothing.
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <path to a sora2-network clone> <commit>" >&2
  exit 2
fi

clone=$1
commit=$(git -C "$clone" rev-parse --verify --quiet "$2^{commit}") || {
  echo "$2 is not a commit in $clone (fetch it first)" >&2
  exit 1
}
root=$(cd "$(dirname "$0")" && pwd)
site=$root/docs
prefix=misc/bridge-halt-web/

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

git -C "$clone" ls-tree -r --name-only "$commit" -- "$prefix" > "$tmp/list"
grep -qx "${prefix}index.html" "$tmp/list" || {
  echo "$commit has no ${prefix}index.html" >&2
  exit 1
}

mkdir -p "$tmp/site"
while IFS= read -r path; do
  rel=${path#"$prefix"}
  case $rel in
    README.md | fetch-vendor.sh) continue ;;
  esac
  mkdir -p "$tmp/site/$(dirname "$rel")"
  git -C "$clone" cat-file blob "$commit:$path" > "$tmp/site/$rel"
done < "$tmp/list"

(cd "$tmp/site/vendor" && shasum -a 256 -c SHA256SUMS)

mkdir -p "$site"
find "$site" -type f ! -path "$site/CNAME" ! -path "$site/.nojekyll" -exec rm -f {} +
find "$site" -mindepth 1 -type d -empty -delete
cp -R "$tmp/site/." "$site/"
echo "$commit" > "$root/SOURCE_COMMIT"
echo "docs/ now holds ${prefix} from $commit"
