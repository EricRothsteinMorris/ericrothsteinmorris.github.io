import VersoBlog
open Verso Genre Blog

-- A tutorial that grows with the site: how it was built, one milestone at a
-- time, for people who do maths and want a Verso website on GitHub. M4
-- publishes only the introduction; M9 in PLAN.md finishes it.
--
-- The title and date set the URL:
-- /blog/2026-9-28-building-this-site-with-verso-and-github-pages/.
-- Changing either after publishing breaks links to the post.
#doc (Post) "Building This Site with Verso and GitHub Pages" =>

%%%
authors := ["Eric Rothstein Morris"]
date := {year := 2026, month := 9, day := 28}
%%%

This site is written in Lean 4 with [Verso](https://github.com/leanprover/verso), an authoring tool for Lean. Every page is a Lean file, and Lean code on a page is type-checked when the site is built. GitHub builds the site and publishes it with GitHub Pages.

This post documents how I built it, milestone by milestone, as a practical guide for people who do mathematics and want a website like it. For now it has one section, on how GitHub builds and publishes the site; the others follow as the site is finished.

I built the site with Claude Code, Anthropic's coding assistant. The source and the plan are public in the [site's repository](https://github.com/EricRothsteinMorris/ericrothsteinmorris.github.io).

# Building and Publishing with GitHub Actions

GitHub builds the site and publishes it, with a workflow in the repository: [`.github/workflows/pages.yml`](https://github.com/EricRothsteinMorris/ericrothsteinmorris.github.io/blob/main/.github/workflows/pages.yml). On every push to `main`, it runs two jobs. The first builds the site:

1. Install [elan](https://github.com/leanprover/elan), Lean's version manager. The first time `lean` or `lake` runs in the repository, elan installs the Lean version named in `lean-toolchain`.
2. Run `lake build`. It compiles Verso and the site's Lean files, and type-checks the Lean code on every page. An error in a Lean block fails the build, so a page with broken Lean code is never published.
3. Run `lake exe generate-blog`, which writes the site's HTML to `_site/`.
4. Pack `_site/` for GitHub Pages with the action `actions/upload-pages-artifact`.

The second job publishes it with `actions/deploy-pages`. For that, the repository's settings must let a workflow publish: under Settings, Pages, "Build and deployment", select GitHub Actions as the Source.

The workflow runs on GitHub's `ubuntu-24.04` machines, which come with a C compiler. Verso needs one: one of its dependencies, MD4Lean, compiles the C library md4c.

Each build starts from scratch. Installing Lean takes about 12 seconds, and `lake build` two to four minutes, most of it compiling Verso. Caching the compiled files would be faster, but a clean build shows what fails on a fresh machine, and the site doesn't change often.

## Checking Pull Requests

The same workflow also builds every pull request into `main`, without publishing it. A pull request with broken Lean code then shows a failed check before it is merged. Two changes do this. The workflow also starts on pull requests:

```
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

and the deploy job runs only on a push:

```
  deploy:
    needs: build
    if: github.event_name == 'push'
```

Because of `needs: build`, the deploy job also runs only when the build has passed. A pull request runs the workflow as it will be after the merge, so a pull request that changes the workflow tests its own change.
