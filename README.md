# ericrothsteinmorris.github.io

Source of my personal website, https://ericrothsteinmorris.github.io.

The site is written in [Lean 4](https://lean-lang.org) with
[Verso](https://github.com/leanprover/verso), so every Lean snippet on it is
type-checked when the site is built. It started from the `basic-blog`
template in [leanprover/verso-templates](https://github.com/leanprover/verso-templates),
version v4.34.0.

I develop it together with [Claude Code](https://claude.com/claude-code).

## Layout

- `Main.lean`: the site's pages and their URLs.
- `Blog/`: one Lean file per page and per post, and the theme
  (`Blog/Theme.lean`).
- `static/`: the site's CSS, published at `/static/`.
- `PLAN.md`: the plan for building this site.
- `BUILD-LOG.md`: problems I ran into while building the site, and how I
  solved them.

## License

Copyright 2026 Eric Rothstein Morris.

- Lean code, including the code in blog posts, and CSS are licensed under
  the [Apache License 2.0](LICENSE).
- Everything else, including the text of pages and posts, images and the CV,
  is all rights reserved.
