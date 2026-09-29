/-
The site's theme: Verso's default theme with our own `primary` template.

`css` and `primary` are copied from Verso's `src/verso-blog/VersoBlog/Theme.lean`
(v4.34.0), which carries this notice:

  Copyright (c) 2023-2024 Lean FRO LLC. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Author: David Thrane Christiansen

Changes from Verso's version: `primary` uses our navigation (`nav`) instead of
`topNav`, and the category list says "None yet." when there are no categories.
-/
import VersoBlog

open Verso Genre Blog Template Output Html

namespace Blog

-- Verso's default CSS (`defaultBlogStyle`), unchanged. Verso declares it
-- `private`, so a theme with its own `primary` must bring its own copy.
def css := r#"
:root {
  --max-width: 70ch;
  --spacing: 1.5rem;
  --color-accent: #0066cc;
  --color-border: #ddd;
}

* {
  box-sizing: border-box;
}

body {
  font-family: var(--verso-text-font-family);
  line-height: 1.6;
  color: var(--verso-text-color);
  background: #fff;
  margin: 0;
  padding: var(--spacing);
  max-width: var(--max-width);
  margin-inline: auto;
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--verso-structure-font-family);
  color: var(--verso-structure-color);
  line-height: 1.2;
  margin: 2em 0 0.5em;
}

h1 { font-size: 2rem; }
h2 { font-size: 1.5rem; }
h3 { font-size: 1.25rem; }

p, ul, ol, pre {
  margin: 0 0 1em;
}

a {
  color: var(--color-accent);
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

code {
  font-family: var(--verso-code-font-family);
  color: var(--verso-code-color);
  background: #f4f4f4;
  padding: 0.2em 0.4em;
  border-radius: 3px;
  font-size: 0.9em;
}

pre {
  background: #f4f4f4;
  padding: 1em;
  border-radius: 5px;
  overflow-x: auto;
}

pre code {
  background: none;
  padding: 0;
}

blockquote {
  margin: 1em 0;
  padding-left: 1em;
  border-left: 3px solid var(--color-border);
  color: #666;
}

img {
  max-width: 100%;
  height: auto;
}

table {
  border-collapse: collapse;
  width: 100%;
  margin: 1em 0;
}

th, td {
  text-align: left;
  padding: 0.5em;
  border-bottom: 1px solid var(--color-border);
}

th {
  font-weight: 600;
  font-family: var(--verso-structure-font-family);
  color: var(--verso-structure-color);
}

nav.top {
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--color-border);
}

nav.top ol {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
}

nav.top li {
  margin: 0;
}

nav.top a {
  font-family: var(--verso-structure-font-family);
  color: var(--verso-structure-color);
  text-decoration: none;
  font-weight: 500;
}

nav.top a:hover {
  color: var(--color-accent);
  text-decoration: none;
}
"#

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
        <style>{{css}}</style>
        <style>":root { --justify-important: left; }"</style>
        <title>{{← param (α := String) "title"}}</title>
        {{← builtinHeader}}
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
