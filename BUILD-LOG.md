# Build log

I keep this build log public so that anyone building webpages with Verso who faces similar problems can refer to it and hopefully find a solution.

Entries are dated, oldest first. Each records what happened, why, and what
I decided.

## To do

- M5: add "Built with Verso" to the footer, linking to Verso's license.
  Every page includes CSS and a script from Verso, which is Apache-2.0.
- M5: add a footer line with the site's terms: Lean code Apache-2.0, text
  all rights reserved. Decided in M3 instead of per-file license notices.
- M5: home link. Verso's `topNav` takes an optional home link
  (`topNav (homeLink := some "…")`, `VersoBlog/Theme.lean`), but the
  default theme's `primary` template calls it without one. Our theme's
  copy of `primary` passes it; the copy also needs the default CSS, which
  is `private` in Verso.
- M8: add the CV PDF and its `static` entry in `Main.lean` (see the M4
  entry "content sources and publications").
- Check whether `draft := true` hides a post from the /blog/ index.
  Reading `Generate.lean` suggests that Verso skips the post's own page but
  still lists it, linking to a page that doesn't exist.

## 2026-09-28 — M1: template, toolchain and repository files

- Started from the `basic-blog` template in leanprover/verso-templates at
  v4.34.0 (commit 78e93c0). Renamed the package to `website` in
  `lakefile.toml` and `lake-manifest.json`.
- The native Windows build fails. Linking the DLL for
  `VersoBlog.LiterateLeanPage` gives "undefined symbol:
  lean_md4c_markdown_parse": MD4Lean's C code isn't linked into the DLL.
  I found no upstream issue. Verso's CI runs only on Ubuntu, and
  leanprover/verso#724 (Windows CI) is open. Decision: build in WSL.
- A fresh Ubuntu needs `build-essential`, because MD4Lean compiles md4c
  with the system `cc`.
- `lake exe generate-blog` reports that `verso-sources.json` doesn't exist.
  That file is optional: it configures links into other Verso documents.
- verso-templates states no license. Verso is Apache-2.0; its dependencies
  are MIT or Apache-2.0. Decision: Lean code under Apache-2.0; text, images
  and the CV all rights reserved.

## 2026-09-28 — M1: git repository

- Initialised the repository with `git init -b main`, because M2 deploys
  `main`.
- Set git's name and email globally in Ubuntu (`~/.gitconfig`). The email
  is my GitHub noreply address, so commits don't publish a private one.
  Without a configured identity, git makes one up from the Linux username
  and hostname and commits with only a warning, which would publish both.
- The files copied from Windows had mode 755. Files under `/mnt/c` carry
  no Linux permissions, so WSL shows them as 755, and git
  (`core.filemode = true`) would commit them as executable. Fix: `chmod 644`
  on the files git would add, leaving directories at 755. `.lake/` keeps
  its modes, because the programs Lake builds need the executable bit.

## 2026-09-28 — Plan: a working prototype first

- Added M2, "Working prototype": deploy the unchanged template to GitHub
  Pages now, to find out what fails on GitHub before any content exists.
  The old M2–M7 became M3–M8. M7 (formerly M6) keeps only the
  pull-request build and the personal-data check.

## 2026-09-28 — M1: GitHub repository and Pages source

- Created the public repository with `gh repo create <name> --public`.
  Without `--add-readme`, `--gitignore` or `--license`, it starts empty.

## 2026-09-28 — M2: deploy workflow

- Added `.github/workflows/pages.yml`, adapted from leanprover/verso-website's
  `ci.yml` (which deploys to Netlify) and GitHub's Pages starter workflow.
  On every push to `main` it runs `lake build` and `lake exe generate-blog`
  and deploys `_site/` with `actions/upload-pages-artifact` and
  `actions/deploy-pages`.
- Installed elan from its v4.2.4 release file, checked against a SHA-256 in
  the workflow. The reference workflow uses v3.0.0 without a checksum.
  Decided against `leanprover/lean-action`: v1.6.0 downloads `elan-init.sh`
  from elan's `master` branch, so pinning the action doesn't pin elan.
- Pinned every action by commit SHA, because a tag can be moved to other
  code.
- Runner: `ubuntu-24.04` rather than `ubuntu-latest`, so the image doesn't
  change when `ubuntu-latest` moves on. It ships gcc, which MD4Lean needs.
- Decided not to cache `.lake/` (506 MB locally). The site won't change
  often, and a clean build shows what fails on a fresh machine.
- `actions/upload-pages-artifact` v4 and later leaves out files and
  directories whose names start with `.`.

## 2026-09-28 — M2: first deploy

- The first run on `main` passed with no warnings. On a clean runner the
  build job took 3 min 58 s, including the Lean toolchain download and
  compiling Verso; the deploy job took 9 s. The deployed `index.html` is
  identical to the local build's.
- A clean build takes about four minutes, so the decision not to cache
  `.lake/` stands.

## 2026-09-28 — M3: pages, navigation and URLs

- Verso's blog genre publishes each page at `/<name>/`, as declared with
  `site` in `Main.lean`. A post's URL is
  `<blog>/{year}-{month}-{day}-{slug}/`, with month and day not
  zero-padded. `Config.postName` can change this, but `blogMain` builds its
  configuration only from the command-line options `--output` and
  `--drafts`, so changing it means writing our own `main`.
- The default theme's navigation lists only top-level pages, by title. It
  has no home link and can't hold external links. Its CSS is `private` in
  Verso, so changing the navigation means copying the whole default
  template.
- Decisions: the front page is About, titled with my name. Research is one
  page with Projects and Publications sections. The blog stays at `/blog/`,
  titled "Blog". The template's sample post goes.
- Navigation: my name (home link), Research, Blog, CV, LinkedIn. It is
  built in M5 with the theme; until then the default theme shows only
  Research and Blog.
- `lake exe generate-blog` writes pages but never deletes old ones, so
  pages removed from the site stay in `_site/` and in the local preview.
  Run `rm -rf _site` before generating to check the output exactly. The
  deploy workflow builds from a clean checkout, so the live site is
  unaffected.
- The deploy run for the merge passed: build 3 min 49 s, deploy 12 s.
  The live site serves the four pages, and the template's `/about/` and
  sample post return 404.

## 2026-09-28 — M4: content sources and publications

- A CV mock-up, kept in `private/`, is the single source for the content
  of About, Research and the CV.
- Added a tutorial post: after each milestone's work, a post documents how
  the site was built, for people who do maths and want a Verso website on
  GitHub. It starts on the M4 branch and may go live unfinished.
- The CV lists publications without DOIs. Looked them up on Crossref by
  title (`api.crossref.org/works?query.bibliographic=...`). Each top match
  agreed on title, venue, year and co-authors, and each DOI resolves at
  doi.org. Crossref answers HTTP 429 (too many requests) when queried
  quickly; pausing 5 s between queries and waiting as its `Retry-After`
  header asks fixed it.
- Crossref's author records don't always match the CV: two of them store
  "Rothstein" as a given name and "Morris" as the family name. Having two
  last names complicates things. The site keeps the author names as the CV
  writes them.
- Decision after previewing: Research lists only publications. The
  Projects section planned in M3 is dropped.
- The tutorial post is titled "Building This Site with Verso and GitHub
  Pages". M4 publishes only its introduction; the new milestone M9
  finishes it.
- The CV PDF is added at launch (M8), not in M4. About already links to
  `cv.pdf`, which returns 404 until then. To publish the PDF, add a
  `static "cv.pdf" ← "<path to the PDF>"` entry to `site` in `Main.lean`:
  Verso then copies it to `_site/cv.pdf` on every generation. A PDF that
  is only committed, without that entry, isn't published.
