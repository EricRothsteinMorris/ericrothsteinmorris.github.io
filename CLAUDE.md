# Project rules for Claude

This repository is the source of my personal website, written in Lean 4 with
Verso's blog genre. It started from the `basic-blog` template
(verso-templates v4.34.0). `PLAN.md` holds the milestones; don't edit it
unless I ask.

## Build

- Build on Linux only (here: Ubuntu under WSL). The native Windows build
  fails when linking `VersoBlog.LiterateLeanPage` with "undefined symbol:
  lean_md4c_markdown_parse".
- A fresh machine needs a C compiler (`build-essential` on Ubuntu), because
  MD4Lean compiles md4c with the system `cc`.
- Build with `lake build`, then `lake exe generate-blog`. The site goes to
  `_site/`. Run both before reporting a change as done.
- `generate-blog` reports that `verso-sources.json` doesn't exist. That file
  is optional: it configures links into other Verso documents.
- Preview with `python3 -m http.server 8000 --bind 127.0.0.1 --directory _site`
  and open http://localhost:8000.
- Record problems, their causes, fixes and decisions in `BUILD-LOG.md` as
  they happen, under a dated entry. Put to-dos found along the way in its
  To do section. The personal-data rule below applies to it. Keep
  security-relevant details out of it too, such as how git or `gh`
  authenticates, token scopes, where credentials are stored, and access
  or permission rules.

## Versions

- Lean and Verso are pinned to v4.34.0 in `lean-toolchain`, `lakefile.toml`
  (`rev`) and `lake-manifest.json`. Keep them in agreement, and don't change
  them without asking.
- Look up Verso's API in `.lake/packages/verso/src/` instead of guessing.

## Public repository and licensing

- Everything committed is public. Never write personal data into any file
  outside `private/`: no phone numbers, postal addresses, private email addresses,
  usernames, machine names, or paths that contain them (write `~/` instead
  of a home directory). The exceptions are my name and the contact details
  or profile links I approve for the site.
- `private/` is gitignored and holds material that must not be published.
  Copy from it into tracked files only what I approve.
- Lean code is Apache-2.0; text, images and the CV are all rights reserved
  (see the License section of `README.md`).
- Before adding third-party code, fonts or images, check their license and
  tell me what it is.

## GitHub Pages limits

The site is hosted on GitHub Pages. Keep it within
[GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)
(checked 2026-09-28):

- Content must follow the GitHub Terms of Service.
- `actions/upload-pages-artifact` v4 and later leaves out files and
  directories whose names start with `.`, so they never reach the site.
