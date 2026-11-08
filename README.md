# emergency.sora.org

This repository publishes the SORA bridge emergency halt page at
<https://emergency.sora.org>. Guardians use it to halt every SORA bridge during an
attack.

GitHub Pages serves the `docs/` folder of `main` exactly as committed; nothing is
built.

## Source

The page is developed in sora2-network, in
[`misc/bridge-halt-web`](https://github.com/sora-xor/sora2-network/tree/4.8.13/misc/bridge-halt-web)
on the 4.8.13 branch. That folder's README explains what a halt does, how guardians
use the page and how devops reopen the bridges. Make changes there first.

`docs/` is a byte-for-byte copy of that folder at the commit in `SOURCE_COMMIT`,
without its `README.md` and `fetch-vendor.sh`. Only `docs/CNAME` and
`docs/.nojekyll` belong to this repository.

## Update the site

```sh
./sync.sh <path to a sora2-network clone> <commit>
git add -A && git diff --cached
```

Review the diff, then commit and push to `main`. Pages publishes it within a few
minutes.

## Check the published copy

```sh
./sync.sh <path to a sora2-network clone> "$(cat SOURCE_COMMIT)"
git status --short
```

`git status` prints nothing when `docs/` matches the source.

## Hosting

- DNS: `emergency.sora.org` is a CNAME to `sora-xor.github.io` in the `sora.org`
  Route 53 zone. The custom domain is set in this repository's Pages settings; keep
  Enforce HTTPS on there.
- GitHub Pages cannot send response headers such as
  `Content-Security-Policy: frame-ancestors 'none'`. The page carries its policy in a
  meta tag and refuses to run inside a frame.
- The node list lives in `config.js` and in the `connect-src` list of `index.html`.
  Change both together, in sora2-network.
