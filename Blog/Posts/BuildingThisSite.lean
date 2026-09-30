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

This post documents how I built it, milestone by milestone, as a practical guide for people who do mathematics and want a website like it. For now it is only this introduction; the sections follow as the site is finished.

I built the site with Claude Code, Anthropic's coding assistant. The source and the plan are public in the [site's repository](https://github.com/EricRothsteinMorris/ericrothsteinmorris.github.io).
