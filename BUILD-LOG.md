# Build log

I keep this build log public so that anyone building webpages with Verso who faces similar problems can refer to it and hopefully find a solution.

Entries are dated, oldest first. Each records what happened, why, and what
I decided.

## To do

- M4: add "Built with Verso" to the footer, linking to Verso's license.
  Every page includes CSS and a script from Verso, which is Apache-2.0.

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

- Initialised the repository with `git init -b main`, because M6 deploys
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
