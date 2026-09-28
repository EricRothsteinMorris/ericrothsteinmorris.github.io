import VersoBlog
import Blog

open Verso Genre Blog Site Syntax

-- The root page is About, so the front page says who I am. Each subpage's
-- URL is its string: /research/, /blog/.
def blog : Site := site Blog.About /
  "research" Blog.Research
  -- A post's URL is /blog/{year}-{month}-{day}-{slug of its title}/, with
  -- month and day not zero-padded (Verso's `defaultPostName`).
  -- The /blog/ index lists posts in this order, not by date, so the newest
  -- goes first.
  "blog" Blog.Posts with
    Blog.Posts.BuildingThisSite
    Blog.Posts.OnGeneralisingAlgorithms

def main := blogMain .default blog
