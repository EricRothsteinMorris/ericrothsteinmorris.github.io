# Plan: rebuild this website in Lean with Verso

Started 2026-09-28. Target: about one week of work sessions. The target is
flexible; the milestones are not tied to calendar days.

## Goal

Replace my old Jekyll site with a new site written in Lean using
[Verso](https://github.com/leanprover/verso), so that the site itself shows
Lean work and every Lean snippet on it is type-checked. Then submit my job
application with a link to the new site.

The new repository is public and set up for working with Claude Code: shared
instructions, shared settings, and checks that run on every change.

## Decisions made

- Rebuild from scratch with Verso. Retire the old site and its repository,
  which was a fork of a Jekyll theme.
- Start a new public repository with the same name, not a fork.
- Remove the Twitter link and add LinkedIn.
- Publish the English CV only.
- Keep the `DhMitm` repository private for now.
- Start from the `basic-blog` template (verso-templates v4.34.0).
- Deploy the unchanged template as a working prototype (M2) before
  writing content.
- Until launch (M8), every merge to `main` deploys unfinished pages. That
  is acceptable: I don't expect anyone to look at the site before then.

## Milestones

- [x] **M0. Retire the old site.** Copy the blog post, the About text and
  the avatar into the new project folder. Delete the old GitHub repository,
  which takes the old site offline, and then the old local folder. Don't
  share the CV until M8, because it links to the website.
  *Done when:* the old site no longer loads.
- [x] **M1. New repository and co-development setup.** In a new local
  folder, set up the official Verso blog template, pinned to v4.34.0. Add
  `README.md`, `LICENSE`, `.gitignore`, `CLAUDE.md` (project rules for
  Claude), `.claude/settings.json` (shared permissions), this plan, and a
  build log. Create the public GitHub repository, push to it, and record
  what GitHub Pages does before any deploy workflow exists.
  *Done when:* the repository is on GitHub and the template builds locally.
- [x] **M2. Working prototype.** Deploy the template site unchanged to
  GitHub Pages. A GitHub Actions workflow runs `lake build` and
  `lake exe generate-blog` and deploys `_site/` on every push to `main`.
  This shows what fails on GitHub before any content exists.
  *Done when:* the template site loads at
  https://ericrothsteinmorris.github.io.
- [ ] **M3. Structure.** Decide the pages, navigation and URLs. Also decide
  whether Lean files carry the per-file license notice from the appendix of
  `LICENSE`. Posts mix Apache-licensed code with reserved prose, so a notice
  at the top of a post would misstate what it covers.
  *Done when:* all pages exist (empty) and the site builds.
- [ ] **M4. Content.** Write About and Research (projects, plus publications
  with DOI links), reusing the old About text. Link the CV and LinkedIn.
  *Done when:* all text is in place.
- [ ] **M5. Design.** Theme and CSS, including the navigation decided in
  M3: a home link, and links to the CV and LinkedIn.
  *Done when:* the site looks finished on desktop and phone.
- [ ] **M6. First Lean post.** Port "On Generalising Algorithms", with the
  definitions and `#eval` examples written in Lean.
  *Done when:* the post builds and its Lean code type-checks.
- [ ] **M7. CI checks.** Extend the M2 workflow to build the site on every
  pull request. Add a check that fails when personal data is committed.
  *Done when:* a pull request that breaks the build or commits personal
  data fails its checks.
- [ ] **M8. Launch.** I review the site, check it live, and submit the
  application with the site's URL.
  *Done when:* the site is live and the application is sent.

## After launch

- Prove in Lean that compression preserves the causal function's value
  (follow-up post to M6).
- Translate the remaining math into Lean.
- Turn the build log into Verso tutorial posts.
- Make `DhMitm` public when it is ready.

## Reference (checked 2026-09-28)

- Templates: [leanprover/verso-templates](https://github.com/leanprover/verso-templates).
  `basic-blog` is minimal; `blog-features` shows a custom theme. Chose `basic-blog` in M1.
- Latest stable release of Verso and the templates: v4.34.0. The v4.35
  releases are release candidates.
- Build command: `lake exe generate-blog`. Output: `_site/`.
- Example build workflow:
  [leanprover/verso-website `ci.yml`](https://github.com/leanprover/verso-website/blob/main/.github/workflows/ci.yml).
  It deploys to Netlify; M2 adapts it for GitHub Pages.
- Local toolchain: Lean 4.34.1 through elan. The template pins its own
  version in `lean-toolchain`, and elan installs it automatically.
- Claude Code settings: `.claude/settings.json` is shared and committed;
  `.claude/settings.local.json` is personal and stays out of git.
