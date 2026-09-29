/-
The site's theme: Verso's default theme with our own `primary` template.

`primary` is copied from Verso's `src/verso-blog/VersoBlog/Theme.lean`
(v4.34.0), which carries this notice:

  Copyright (c) 2023-2024 Lean FRO LLC. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Author: David Thrane Christiansen

Changes from Verso's version: `primary` uses our navigation (`nav`) instead of
`topNav`, the category list says "None yet." when there are no categories,
and the CSS comes from `static/style.css` instead of Verso's private
`defaultBlogStyle`.
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
      <ol>
        -- Every page has `<base href>` pointing at the site root, so "." is
        -- the front page and "cv.pdf" is /cv.pdf from any page.
        <li class="home"><a href=".">"Eric Rothstein Morris"</a></li>
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
        <meta name="color-scheme" content="light dark"/>
        <!-- Stop favicon requests -->
        <link rel="icon" href="data:," />
        <style>":root { --justify-important: left; }"</style>
        <title>{{← param (α := String) "title"}}</title>
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
      </body>
    </html>
  }}

-- Only `primary` differs from Verso's default theme; pages, posts and the
-- blog index entries use Verso's templates.
def theme : Theme := { Theme.default with primaryTemplate := primary }

end Blog
