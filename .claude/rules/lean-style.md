# Lean style

My style for Lean code, collected while building this site. The style
still changes: add each new decision here, with what I want and what I
don't want.

So far only `Blog/Posts/VericodingExercise.lean` follows it.
Converting the other Lean files is on the To do list in `private/BUILD-LOG.md`;
don't convert them unless I ask.

## Lean code

### Comments

- Want: every comment is a block comment, `/- … -/`. Docstrings,
  `/-- … -/`, use the same layout.
- A one-line comment stays on one line:

  ```lean
  /- `h` proves q < a.size, which `a[q]` needs. -/
  /-- A causal function maps each finite sequence of inputs to an output. -/
  ```

- A comment of two or more lines starts its text right after `/-` (or
  `/--`), continuation lines keep the indentation of `/-`, and `-/` ends
  the last line of text. A comment that starts with a label, such as
  "First pass:", breaks the line after the label.

  ```lean
  /- First pass:
  for each prefix sum, find the length of the longest prefix
  with that sum. -/
  ```

- Don't want: `--` comments, whether on their own line or after code.

  ```lean
  -- First pass: for each prefix sum, the length of the longest prefix
  -- with that sum.
  ```

- Don't want: `-/` on a line of its own.

  ```lean
  /- First pass:
  for each prefix sum, find the length of the longest prefix
  with that sum.
  -/
  ```

### Signatures

- Want: in every definition, theorem, `abbrev`, `example` and `where`
  function, the name alone on its first line; then each binder on its
  own line, including implicit (`{I O : Type}`) and instance (`[BEq O]`)
  binders; then the type on its own line, starting with `:`. Binders and
  type are indented two spaces more than the name's line. Parameters of
  the same type may share a binder, as in `(a sums : Array Int)`. This
  holds even without binders. Why: it is easier for me to read.

  ```lean
  def removeZeroSumSublists
    (s : List Int)
    : List Int :=

  theorem sum_rightCongruent
    : RightCongruent sum := by
  ```

- A type or statement too long for one line continues two spaces
  deeper than its `:` line.

  ```lean
  theorem firstPass_spec
    …
    (hm : ∀ k j, m[k]? = some j → f (s.take j) = k)
    : ∀ k j, (ps.foldl (fun m p => m.insert (f (s.take p)) p) m)[k]? = some j →
      f (s.take j) = k := by
  ```

- An `abbrev` without a type ends with `:=` and its body on their own
  line:

  ```lean
  abbrev CausalFunction
    (I O : Type)
    := List I → O
  ```

- Don't want: binders or the type on the name's line.

  ```lean
  def removeZeroSumSublists (s : List Int) : List Int :=
  ```

### Line length

- Want: lines of at most 80 characters.
- Don't want: longer lines. Code must never wrap, because wrapped code
  is hard to read; short lines are the fix.

## Lean in posts

- Want: expressions and formulas as Lean code, in the style of the Lean
  documentation. Don't want: LaTeX.
- Want: every `#eval` output shown in a `leanOutput` block, so the build
  checks it. Don't want: outputs typed in by hand.
