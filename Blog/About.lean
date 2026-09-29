import VersoBlog
open Verso Genre Blog

-- The site's root page (see Main.lean). Its title is the page's heading and,
-- followed by " — Eric Rothstein Morris", the browser tab's title. It is
-- "About" rather than my name, because the navigation already shows my name
-- directly above the heading.
--
-- The text is the Summary of my CV, word for word, so the site and the CV
-- say the same thing. The CV, LinkedIn, GitHub and email links at the end
-- keep all contact links in one place, even though the navigation
-- (Blog/Theme.lean) also links the CV and LinkedIn.
--
-- `cv.pdf` is relative on purpose: every page has `<base href>` pointing at
-- the site root, so it resolves to /cv.pdf from any page, both on GitHub
-- Pages and in the local preview. The PDF is added at launch (M8), with a
-- `static` entry in Main.lean; until then the link returns 404.
#doc (Page) "About" =>
%%%
%%%

I am a computer scientist with a Ph.D. in Information Systems. My research applied formal methods to diverse security domains: I used bounded model checking to generate and classify attackers, built LLVM compiler passes that reduce timing side-channel leakage, and defined metrics for integrity in cyber-physical systems security. Since 2022, I have worked in industry, most recently running Elastic SIEM clusters for German healthcare institutions with Ansible, Docker Swarm, and CI/CD. I am learning Lean 4 and want to build tools that make formally verified code the default when AI writes software.

[CV](cv.pdf) · [LinkedIn](https://www.linkedin.com/in/dr-eric-rothstein-morris/) · [GitHub](https://github.com/EricRothsteinMorris) · [eric.rothstein.contact@gmail.com](mailto:eric.rothstein.contact@gmail.com)
