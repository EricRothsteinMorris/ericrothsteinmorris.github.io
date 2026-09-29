# Build log

I keep this build log public so that anyone building webpages with Verso who faces similar problems can refer to it and hopefully find a solution.

Entries are dated, oldest first. Each records what happened, why, and what
I decided.

## To do

- M6: choose the code font, tested on the ported "On Generalising
  Algorithms". The browser's default monospace font may lack some of
  Lean's symbols (→, ℕ, ⟨⟩), which the browser then takes from another
  font with different widths. A font stored in `static/` may be needed;
  check its license first.
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
- The deploy run for the merge passed: build 3 min 48 s, deploy 10 s.
  The live pages are identical to the local build, and `/cv.pdf` returns
  404 until M8.

## 2026-09-29 — M5: theme and navigation

- A Verso theme (`Theme` in `VersoBlog/Theme.lean`) has five templates:
  `primary` (the whole HTML page), `page`, `post`, `archiveEntry` (one
  entry in the blog index) and `category`. It also has `cssFiles`,
  `jsFiles`, and `adHocTemplates` for giving one path its own template.
  `{ Theme.default with primaryTemplate := … }` replaces only `primary`;
  Verso's demo site (`test-projects/website/DemoSiteMain.lean`) does the
  same.
- Verso's `topNav` builds the whole `<nav>` and can't take external links,
  but `Theme.dirLinks`, which lists the top-level pages, is public.
  `Blog/Theme.lean` builds its own navigation from it: my name (home
  link), Research, Blog, CV, LinkedIn. Every page has a `<base href>`
  pointing at the site root, so `href="."` is the front page and
  `cv.pdf` resolves to /cv.pdf from any page.
- Verso's default CSS is `private`, so `Blog/Theme.lean` copies it along
  with `primary`. The copy keeps Verso's copyright notice, as Apache-2.0
  requires; Verso has no NOTICE file.
- Verso's blog index shows a "Categories" heading over an empty list when
  no post has a category. Our `primary` shows "None yet." instead.
- About keeps its line of links (CV, LinkedIn, GitHub, email): the
  navigation has no GitHub or email link, and the line keeps all contact
  links in one place.
- Moved the CSS out of `Blog/Theme.lean` into `static/style.css`, with
  Verso's notice. The CSS started as a Lean string only because Verso's
  default theme keeps its CSS that way (`defaultBlogStyle`, `private`),
  so copying `primary` meant copying the string too. Reasons for a
  separate file:
  - Edit loop. A Lean string is compiled into the `generate-blog`
    executable, so every CSS edit needs `lake build` before
    `lake exe generate-blog`. A `static "static" ← "static"` entry in
    `Main.lean` instead copies the folder to `_site/static/` each time
    the site is generated, so a CSS edit needs only
    `lake exe generate-blog`.
  - Editor support. Inside a `.lean` file the CSS is a raw string, so
    the editor gives no CSS highlighting or checking. In a `.css` file
    it does.
  - One copy. An inline `<style>` repeats the whole CSS in every page's
    HTML. A linked stylesheet is one file, which the browser can cache
    and reuse across pages.
  - Separation. `Blog/Theme.lean` holds the page structure (templates);
    `static/style.css` holds the appearance.

  Verso's demo site (`test-projects/website/DemoSiteMain.lean`) does the
  same. The rejected alternative, `Theme.cssFiles` with `include_str`,
  keeps a `.css` file but still compiles its contents into the
  executable, so each edit still needs `lake build`. The cost of the
  move: the `<link>` must come after `builtinHeader` (next bullet), and
  README had to state the CSS's license, since a `.css` file isn't Lean
  code.
- Our stylesheet's `<link>` comes after `builtinHeader`, which inlines
  Verso's `--verso-*` variables (fonts, Lean code colours). Placed before
  it, as Verso's default theme places its CSS, our values for those
  variables would be overridden.
- README's License section now covers CSS: Lean code and CSS are
  Apache-2.0, which also covers the part copied from Verso.
- Verso's default theme declares `<meta name="color-scheme" content="light
  dark">` but hard-codes a white background and black text, and
  `verso-vars.css` has no dark values. Decision: light only for now
  (`content="light"`); dark mode that follows the device setting is in
  PLAN.md's "After launch", after M9.
- Header layout: my name on the left in bold, the links on the right. The
  name is a link outside the `<ol>`, and `nav.top` is a wrapping flex
  row, so when both don't fit (on a phone) the list moves as a whole to
  its own line under the name. With the name inside the list, items would
  wrap one by one and could split the links across two lines.
- About's title changed from my name (decided in M3) to "About", because
  the navigation now shows my name directly above the page heading. So
  that the front page's browser tab, bookmarks and search results still
  name me, every tab title is now "<page title> — Eric Rothstein Morris",
  set in `primary`. Page headings stay the title alone.
- Width and spacing stay Verso's: a text column of at most 70 characters,
  1.5rem side padding, line height 1.6. The gap between the header and the
  page heading was about 4rem: the heading's top margin (2em at 2rem font
  size) collapses with the header's 2rem bottom margin into the larger of
  the two. `main h1:first-child { margin-top: 0 }` cuts it to 2rem.
- Blog list: no bullets, and more space between posts. Each title is bold
  and a bit larger. The line under it ("2026-09-28 · Eric Rothstein
  Morris") is small, grey and on one line, also on the post's own page.
  Verso's templates put the author first; CSS `order` shows the date
  first without changing the HTML. The date stays in ISO format
  (2026-09-28), which reads the same in every country. This is CSS only;
  the list still uses Verso's templates.
- Fonts stay Verso's: the system's sans-serif for text and headings, and
  the browser's monospace for code. There are no font files to download
  or license. The code font is chosen in M6 (see To do).
- Colours stay Verso's: black text on white, blue links (`#0066cc`), and
  grey (`#666`) for the date line under post titles and for quotes.
  Against white they have contrast ratios of 21:1, 5.6:1 and 5.7:1, all
  above the 4.5:1 that WCAG AA asks for normal text. Links in the text
  aren't underlined until hovered, so only their colour sets them apart;
  blue against black is 3.8:1, above the 3:1 WCAG asks for that case.
- Footer on every page, small and grey under a rule: "© 2026 Eric
  Rothstein Morris. Lean code and CSS are licensed under the Apache
  License 2.0; everything else, including the text, is all rights
  reserved. Built with Verso (Apache License 2.0)." The first license
  link goes to this repository's `LICENSE`, the second to Verso's
  `LICENSE` at v4.34.0, the version the site is built with. Every page
  includes Verso's CSS and scripts, so crediting Verso and linking its
  license belongs on every page. README's License section stays the full
  statement of the terms.
- On desktop the text column felt narrow: about 575 px, because Verso's
  `max-width: 70ch` includes the side padding. First try: 18 px text on
  wide screens, which makes the column grow with the text (it is in
  `ch`) while lines keep about 75 characters. It made everything bigger,
  but not wider in the way I wanted.
- Decision: the text column of the Lean language reference, 47rem
  (752 px) at 16 px text, measured from its `book.css`. Lines are longer,
  about 100 characters, beyond the usual 45–75, but there is more room
  for Lean code. `--max-width` is now `calc(47rem + 2 * var(--spacing))`,
  since the padding counts towards it. Phones are unchanged.
- Phone check in Firefox's Responsive Design Mode (F12, then
  Ctrl+Shift+M; Ctrl+Shift+R reloads the CSS) at 320 px, the narrowest
  common phone width. The longest unbreakable words, a DOI on Research
  (34 characters) and the email address on About (32), fit without a
  horizontal scrollbar, so no `overflow-wrap` rule is needed.
- The deploy run for the merge passed: build 3 min 45 s, deploy 10 s.
  The live pages and `static/style.css` are identical to the local
  build, and `/cv.pdf` returns 404 until M8.
