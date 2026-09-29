/-
The site's theme: Verso's default theme with our own `primary` template.

`primary` is copied from Verso's `src/verso-blog/VersoBlog/Theme.lean`
(v4.34.0), which carries this notice:

  Copyright (c) 2023-2024 Lean FRO LLC. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Author: David Thrane Christiansen

Changes from Verso's version: `primary` uses our navigation (`nav`) instead of
`topNav`, the category list says "None yet." when there are no categories,
the CSS comes from `static/style.css` instead of Verso's private
`defaultBlogStyle`, the page declares the colour scheme "light" only, the
tab title ends in " — Eric Rothstein Morris", and a footer gives the site's
terms and credits Verso.
-/
import VersoBlog

open Verso Genre Blog Template Output Html

namespace Blog

-- The navigation decided in M3: my name (home link), Research, Blog, CV,
-- LinkedIn. Verso's `topNav` builds the whole `<nav>` and can't take the
-- external links, so we build it here with Verso's public `dirLinks`.
def nav : Template := do
  pure {{
    <nav class="top" role="navigation">
      -- The name sits outside the list, so the CSS can place it on the left
      -- and the list on the right, and move the list as a whole to its own
      -- line when both don't fit (static/style.css, `nav.top`).
      -- Every page has `<base href>` pointing at the site root, so "." is
      -- the front page and "cv.pdf" is /cv.pdf from any page.
      <a class="home" href=".">"Eric Rothstein Morris"</a>
      <ol>
        -- Research and Blog: the top-level pages declared in Main.lean.
        {{ ← Theme.dirLinks (← read).site }}
        -- The PDF is added in M8; until then this link returns 404.
        <li><a href="cv.pdf">"CV"</a></li>
        -- The same URL as the link on About (Blog/About.lean).
        <li><a href="https://www.linkedin.com/in/dr-eric-rothstein-morris/">"LinkedIn"</a></li>
      </ol>
    </nav>
  }}

def primary : Template := do
  let postList :=
    match (← param? "posts") with
    | none => Html.empty
    | some html => {{ <h2> "Posts" </h2> }} ++ html
  let catList :=
    match (← param? (α := Post.Categories) "categories") with
    | none => Html.empty
    | some ⟨cats⟩ => {{
        <div class="categories">
          <h2> "Categories" </h2>
          -- Verso shows the heading over an empty list when no post has a
          -- category; say so instead.
          {{ if cats.isEmpty then {{ <p> "None yet." </p> }}
             else {{
               <ul>
               {{ cats.map fun (target, cat) =>
                 {{<li><a href={{target}}>{{Post.Category.name cat}}</a></li>}}
               }}
               </ul>
             }}
          }}
        </div>
      }}
  return {{
    <html>
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        -- Light only. Verso's default says "light dark", which lets browsers
        -- draw scrollbars and form controls dark on our white page. Dark mode
        -- is planned for after M9 (PLAN.md, "After launch").
        <meta name="color-scheme" content="light"/>
        <!-- Stop favicon requests -->
        <link rel="icon" href="data:," />
        <style>":root { --justify-important: left; }"</style>
        -- The page's title plus my name, so browser tabs, bookmarks and search
        -- results name the site; the page heading stays the title alone.
        <title>{{← param (α := String) "title"}} " — Eric Rothstein Morris"</title>
        {{← builtinHeader}}
        -- After `builtinHeader`, which inlines Verso's `--verso-*` variables,
        -- so the values in our CSS win. `static/` is copied to the site by the
        -- `static` entry in Main.lean; `<base href>` makes the path work from
        -- every page.
        <link rel="stylesheet" href="static/style.css"/>
      </head>
      <body>
        <header>
        {{← nav}}
        </header>
        <main>
          {{← param "content"}}
          {{postList}}
          {{catList}}
        </main>
        -- The site's terms, decided in M3 instead of per-file license notices
        -- (README's License section has the full statement), and credit to
        -- Verso, whose Apache-2.0 CSS and scripts every page includes. The
        -- Verso license link is pinned to the version in lakefile.toml.
        <footer>
          <p>
            "© 2026 Eric Rothstein Morris. Lean code and CSS are licensed under the "
            <a href="https://github.com/EricRothsteinMorris/ericrothsteinmorris.github.io/blob/main/LICENSE">"Apache License 2.0"</a>
            "; everything else, including the text, is all rights reserved. Built with "
            <a href="https://github.com/leanprover/verso">"Verso"</a>
            " ("
            <a href="https://github.com/leanprover/verso/blob/v4.34.0/LICENSE">"Apache License 2.0"</a>
            ")."
          </p>
        </footer>
      </body>
    </html>
  }}

-- Only `primary` differs from Verso's default theme; pages, posts and the
-- blog index entries use Verso's templates.
def theme : Theme := { Theme.default with primaryTemplate := primary }

end Blog
