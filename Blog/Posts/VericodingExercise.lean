import VersoBlog
open Verso Genre Blog

/- The title and date set the URL: /blog/2026-10-1-a-vericoding-exercise/. -/
#doc (Post) "A Vericoding Exercise" =>

%%%
authors := ["Eric Rothstein Morris"]
date := {year := 2026, month := 10, day := 01}
%%%

```leanInit post
/- Starts the Lean context `post`. Every Lean block below runs in it, in
order, so later blocks see earlier definitions. This block isn't shown. -/
```

_LeetCode 1171, with a specification and a proof in Lean._

In September 2026, OpenAI reported that about 10,000 of its AI agents had
found a singularity in the three-dimensional Navier–Stokes equations, the
subject of one of the Millennium Prize Problems, and that another AI model had
formalised the proof in Lean, which checked it
([Quanta Magazine](https://www.quantamagazine.org/ai-has-solved-one-of-maths-1-million-millennium-prize-problems-20260908/)).
Mathematicians are still examining the result, and who deserves credit is
disputed. I wondered: if AI is this capable, why does vibe coding still
produce buggy code?

Most of the advice I found was to review the code that AI writes more
carefully and to test it better. Given my background in formal methods, I
asked a different question: why not have the AI go the extra mile and prove
that its code is correct? This idea already has a name, _vericoding_: an AI
writes code from a formal specification, together with a proof that the code
meets it, and a machine checks the proof
([Bursuc et al., 2025](https://arxiv.org/abs/2509.22908)). Lean is both a
programming language and a theorem prover, so it can play both parts.

This post is a small experiment in that spirit. Together with Claude Code,
Anthropic's coding assistant, I wrote a specification for a LeetCode problem
in Lean. Claude then wrote a solution and a proof that it meets the
specification, and Lean checked the proof.

# An Exercise in Vericoding

The problem we study is [LeetCode 1171: Remove Zero Sum Consecutive Nodes from Linked List](https://leetcode.com/problems/remove-zero-sum-consecutive-nodes-from-linked-list/): given the `head`
of a linked list of integers, we must repeatedly delete a consecutive sequence
of numbers that adds up to zero, until no such sequence remains. For example,
the list `[1, 2, -3, 3, 1]` can reduce either to `[3, 1]` or to `[1, 2, 1]`.

A small simplification for this blog entry: LeetCode's input is a linked list whose nodes can be
changed, and solutions relink the nodes to cut runs out. We use Lean's `List`
instead.

## The Specification
Since we are vericoding, we should first try to capture the specification formally.

```lean post
/-- `t` results from `s` by deleting runs that sum to zero. Read `s` from
the left: each element is either kept, or starts a run that sums to zero
and is deleted. Core Lean's `List.Sublist` is defined the same way, except
that it may delete any element. -/
inductive DeletesZeroSumRuns : List Int → List Int → Prop
  | nil : DeletesZeroSumRuns [] []
  | keep (a : Int) (s t : List Int) : DeletesZeroSumRuns s t → DeletesZeroSumRuns (a :: s) (a :: t)
  | delete (w s t : List Int) : w.sum = 0 → DeletesZeroSumRuns s t → DeletesZeroSumRuns (w ++ s) t

/-- LeetCode 1171 for one input `s` and output `t`: `t` has the sum of
`s`, results from `s` by deleting runs that sum to zero, and has no run
other than `[]` that sums to zero. `w <:+: t` says that `w` is a run of
`t`: `t = u ++ w ++ v` for some `u` and `v`. -/
def RemoveZeroSumSpec
  (s t : List Int)
  : Prop :=
  t.sum = s.sum ∧
  DeletesZeroSumRuns s t ∧
  ∀ w, w <:+: t → w ≠ [] → w.sum ≠ 0

/-- A function solves LeetCode 1171 if it meets the spec on every input. -/
def SolvesLeetCode1171
  (f : List Int → List Int)
  : Prop :=
  ∀ s, RemoveZeroSumSpec s (f s)
```
We had several back-and-forth interactions with Claude Code to find a proper specification.
This is probably the hardest of the tasks: simpler conditions are too weak; conditions on sums alone
would allow a function to turn `[1, 2]` into `[3]`; it must support several deletions of zero-sum runs,
and the output must have no zero-sum run of its own.

From that specification, it was relatively easy for Claude to find a candidate function:

```lean post
def removeZeroSumSublists
  (s : List Int)
  : List Int :=
  match s with
  | [] => []
  | a :: rest =>
    /- `rest.scanl (· + ·) a` lists the sums of the nonempty prefixes of
    `a :: rest`; `j` is the position of the first that is zero. -/
    match (rest.scanl (· + ·) a).findIdx? (· == 0) with
    /- The first `j + 1` elements sum to zero: delete them. -/
    | some j => removeZeroSumSublists (rest.drop j)
    /- No nonempty prefix sums to zero: keep `a`. -/
    | none => a :: removeZeroSumSublists rest
  /- Lean accepts a recursive function only if it can see that the
  recursion ends. `termination_by` names a number that decreases at each
  call: both calls are on lists shorter than `s`. -/
  termination_by s.length
```
Lean accepts the solution only with `termination_by s.length`, which tells
it why the recursion ends: on its own, it can't see that `rest.drop j` is
shorter than `s`.

We can run a quick test,

```lean post (name := leetcode)
#eval removeZeroSumSublists [1, 2, -3, 3, 1]
```

```leanOutput leetcode
[3, 1]
```

but we should focus our efforts on proving the goal `SolvesLeetCode1171 removeZeroSumSublists`. To do so, Claude suggested proving
a couple of facts before. These facts are related to the expressions used in the implementation of `removeZeroSumSublists`.

One of the most fascinating advantages about doing vericoding for the average developer is that they don't need to be too careful about the proofs generated by AI;
as long as those proofs "don't cheat" (i.e., they don't say `sorry` or use "cheating axioms"), they are valid, and any valid proof of the specification suffices!
In that spirit, I invite you to skip the next section and continue at section {ref theGoal}[The Goal]; unless you are curious about the lemmas that Claude proposed.

## Lemmas

`sum_cons_eq_foldl` says that the sum of `a :: l` is `l` folded with `+`,
starting from `a`, which is how `scanl` computes it. The proofs below
need it to read the sums that `removeZeroSumSublists` checks as sums of
prefixes.

```lean post
/-- The sum of `a :: l` is `l` folded with `+`, starting from `a`: the
form in which `scanl` gives the sums of prefixes. -/
theorem sum_cons_eq_foldl
  (a : Int)
  (l : List Int)
  : (a :: l).sum = l.foldl (· + ·) a := by
  rw [List.sum_eq_foldl]
  simp
```

`DeletesZeroSumRuns.sum_eq` says that deleting runs that sum to zero
keeps the sum of a list. It gives the sum part of the specification.

```lean post
/-- Deleting runs that sum to zero keeps the sum. -/
theorem DeletesZeroSumRuns.sum_eq
  {s t : List Int}
  (h : DeletesZeroSumRuns s t)
  : t.sum = s.sum := by
  induction h with
  | nil => rfl
  | keep a s t _ ih => simp [ih]
  | delete w s t hw _ ih => simp [List.sum_append, hw, ih]
```

`DeletesZeroSumRuns.prefix_sum` says that after deleting runs that sum to
zero, every prefix of the output has the sum of some prefix of the input.
`removeZeroSumSublists_noZeroRun` uses it to show that a kept element
can't start a run that sums to zero.

```lean post
/-- Every prefix of the output has the sum of some prefix of the input. -/
theorem DeletesZeroSumRuns.prefix_sum
  {s t : List Int}
  (h : DeletesZeroSumRuns s t)
  : ∀ u, u <+: t → ∃ u', u' <+: s ∧ u.sum = u'.sum := by
  induction h with
  | nil =>
    /- The only prefix of `[]` is `[]`. -/
    intro u hu
    rw [List.prefix_nil] at hu
    exact ⟨[], List.nil_prefix, by simp [hu]⟩
  | keep a s t _ ih =>
    /- A prefix of `a :: t` is `[]`, or `a` followed by a prefix of `t`. -/
    intro u hu
    rcases List.prefix_cons_iff.mp hu with rfl | ⟨u₁, rfl, hu₁⟩
    · exact ⟨[], List.nil_prefix, rfl⟩
    · obtain ⟨u', hu', hsum⟩ := ih u₁ hu₁
      exact ⟨a :: u', List.cons_prefix_cons.mpr ⟨rfl, hu'⟩, by simp [hsum]⟩
  | delete w s t hw _ ih =>
    /- Put the deleted run `w` in front: it adds zero to the sum. -/
    intro u hu
    obtain ⟨u', hu', hsum⟩ := ih u hu
    exact ⟨w ++ u', (List.prefix_append_right_inj w).mpr hu',
      by simp [List.sum_append, hw, hsum]⟩
```

`removeZeroSumSublists_deletes` says that `removeZeroSumSublists` only
deletes runs that sum to zero. Each case of the function is one case of
`DeletesZeroSumRuns`, so the proof follows the function's recursion.

```lean post
/-- `removeZeroSumSublists` deletes only runs that sum to zero. -/
theorem removeZeroSumSublists_deletes
  (s : List Int)
  : DeletesZeroSumRuns s (removeZeroSumSublists s) := by
  /- Induction that follows the recursion of `removeZeroSumSublists`: each case
  of the function is one case of `DeletesZeroSumRuns`. -/
  fun_induction removeZeroSumSublists s with
  | case1 => exact .nil
  | case2 a rest j h ih =>
    /- The `j`-th sum in the list is zero, and it is the sum of the first
    `j + 1` elements. -/
    obtain ⟨hj, hzero, _⟩ := List.findIdx?_eq_some_iff_getElem.mp h
    have hsum : (a :: rest.take j).sum = 0 := by
      rw [sum_cons_eq_foldl, ← List.getElem_scanl hj]
      simpa using hzero
    have e : a :: rest = (a :: rest.take j) ++ rest.drop j := by simp
    rw [e]
    exact .delete _ _ _ hsum ih
  | case3 a rest h ih => exact .keep a _ _ ih
```

`removeZeroSumSublists_noZeroRun` says that no run of the output, other
than `[]`, sums to zero. A run that starts with a kept element `a` has the
sum of a nonempty prefix of `a :: rest`, and the function keeps `a` only
when none of those sums to zero.

```lean post
/-- No run of the output of `removeZeroSumSublists`, other than `[]`, sums to
zero. -/
theorem removeZeroSumSublists_noZeroRun
  (s : List Int)
  : ∀ w, w <:+: removeZeroSumSublists s → w ≠ [] → w.sum ≠ 0 := by
  /- Induction that follows the recursion of `removeZeroSumSublists`. -/
  fun_induction removeZeroSumSublists s with
  | case1 =>
    /- The only run of `[]` is `[]`. -/
    intro w hw hne
    simp_all
  | case2 a rest j h ih => exact ih
  | case3 a rest h ih =>
    /- A run of `a :: t` is a prefix of `a :: t`, or a run of `t`. -/
    intro w hw hne
    rcases List.infix_cons_iff.mp hw with hp | hi
    · rcases List.prefix_cons_iff.mp hp with rfl | ⟨w₁, rfl, hw₁⟩
      · exact absurd rfl hne
      · /- `w` is `a :: w₁`, and `w₁` has the sum of a prefix `u'` of
        `rest`. So `w` has the sum of `a :: u'`, a nonempty prefix of
        `a :: rest`, and none of those sums to zero. -/
        obtain ⟨u', hu', hsum⟩ :=
          (removeZeroSumSublists_deletes rest).prefix_sum w₁ hw₁
        have hlen : u'.length < (rest.scanl (· + ·) a).length := by
          have := hu'.length_le
          simp
          omega
        have hmem := List.getElem_mem hlen
        rw [List.getElem_scanl, ← List.prefix_iff_eq_take.mp hu',
          ← sum_cons_eq_foldl] at hmem
        have hne0 := List.findIdx?_eq_none_iff.mp h _ hmem
        simp at hne0
        simpa [hsum] using hne0
    · exact ih w hi hne
```
## {label theGoal}[The Goal]
We need a proof for the proposition `SolvesLeetCode1171 removeZeroSumSublists`.
That would prove that `removeZeroSumSublists` meets the specification on every input.

The following proof combines the lemmas above.

```lean post
/-- `removeZeroSumSublists` meets the specification of LeetCode 1171. -/
example
  : SolvesLeetCode1171 removeZeroSumSublists := by
  intro s
  /- Deleting runs that sum to zero keeps the sum. -/
  have hd := removeZeroSumSublists_deletes s
  exact ⟨hd.sum_eq, hd, removeZeroSumSublists_noZeroRun s⟩
```

That's the whole exercise: a specification, a solution, and a proof that the
solution meets the specification, all checked by Lean. The hardest part was
not the proof but the specification.

Thanks for reading!
