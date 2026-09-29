import VersoBlog
-- The post's Lean code uses hash maps. Lean blocks in a post can't import
-- modules themselves, so the post's own file imports them.
import Std.Data.HashMap
open Verso Genre Blog

-- The title and date set the URL: /blog/2024-3-28-on-generalising-algorithms/.
-- The old title's " - A LeetCode Example" would put a double hyphen in the
-- slug, so the subtitle goes into the text instead.
#doc (Post) "On Generalising Algorithms" =>

%%%
authors := ["Eric Rothstein Morris"]
-- The date the post was first published on the old site.
date := {year := 2024, month := 3, day := 28}
%%%

```leanInit post
-- Starts the Lean context `post`. Every Lean block below runs in it, in
-- order, so later blocks see earlier definitions. This block isn't shown.
```

_A LeetCode example: finding higher-order functions._

Maybe some of you have tried to solve
[LeetCode 1171: Remove Zero Sum Consecutive Nodes from Linked List](https://leetcode.com/problems/remove-zero-sum-consecutive-nodes-from-linked-list/).
For those of you who have not, the problem is the following: given the `head`
of a linked list of integer numbers, delete all consecutive sequences of
numbers that add up to zero until no such sequences remain. So, for example,
the list `[1, 2, -3, 3, 1]` can reduce to either `[3, 1]` or to `[1, 2, 1]`.

Let us review one of the best solutions for this problem, written in Lean
(*SPOILER ALERT*: if you have not solved it, try it yourself; it is quite a
fun problem!). The LeetCode version walks the linked list with pointers.
Lean's `List` is also a linked list, but reaching position `q` takes `q` steps
from its start. So this version copies the list into an array, where every
position takes one step, and computes all the running sums in one pass:

```lean post
def removeZeroSumSublists (s : List Int) : List Int :=
  let a := s.toArray
  -- The running sums: `sums[p]` is the sum of the first `p` elements.
  let sums := (s.scanl (· + ·) 0).toArray
  -- First pass: for each prefix sum, the length of the longest prefix
  -- with that sum.
  let last := (List.range sums.size).foldl
    (fun m p => m.insert sums[p]! p) (∅ : Std.HashMap Int Nat)
  -- Second pass: from position p, jump to the last position with the
  -- same prefix sum.
  go a sums last 0
where
  go (a sums : Array Int) (last : Std.HashMap Int Nat) (p : Nat) : List Int :=
    -- `sums[p]!` panics if p is out of range; here p ≤ a.size < sums.size.
    -- `max p` makes q ≥ p, so Lean can see that the recursion ends.
    let q := max p (last.getD sums[p]! p)
    -- `h` proves q < a.size, which `a[q]` needs.
    if h : q < a.size then a[q] :: go a sums last (q + 1) else []
  termination_by a.size - p
```

On the list above, it gives:

```lean post (name := leetcode)
#eval removeZeroSumSublists [1, 2, -3, 3, 1]
```

```leanOutput leetcode
[3, 1]
```

So, why does this blog post mention higher-order functions? To get to that
point, we first need to talk about _causal functions_. Given a type of inputs
`I` and a type of outputs `O`, a _causal function_ is a function of type
`List I → O`, i.e., it receives a sequence of inputs and produces some output.

```lean post
/-- A causal function maps each finite sequence of inputs to an output. -/
abbrev CausalFunction (I O : Type) := List I → O
```

For this problem, we consider the sum causal function:

```lean post
def sum : CausalFunction Int Int
  | [] => 0
  | i :: s => i + sum s
```

Note that for a list `s = x ++ y ++ z` where `sum y = 0`, we know that
`sum s = sum (x ++ z)`, so we could remove `y`, but the key point here is that
if we apply `sum` to all the prefixes of `s`, we would "repeat" the value of
`sum x` twice: for the prefix `x` and for `x ++ y`. We formalise this concept
of "repeating" with the _trace_. Given a causal function `f` and a list `s`,
the _trace of `s` under `f`_ is the list of values of `f` on the prefixes of
`s`, from `[]` to `s` itself:

```lean post
def trace {I O : Type} (f : CausalFunction I O) (s : List I) : List O :=
  (List.range (s.length + 1)).map fun p => f (s.take p)
```

The running sums in the solution above are exactly the trace of `sum`:

```lean post
-- Stated for any start value `c`, so that induction on `s` works.
theorem trace_sum_aux (s : List Int) (c : Int) :
    (List.range (s.length + 1)).map (fun p => c + sum (s.take p)) =
      s.scanl (· + ·) c := by
  induction s generalizing c with
  | nil => simp [sum]
  | cons i s ih =>
    -- Split off position 0 on both sides; the rest is the induction
    -- hypothesis with start value `c + i`.
    rw [List.length_cons, List.range_succ_eq_map, List.scanl_cons, ← ih]
    simp [sum, Int.add_assoc]

theorem trace_sum (s : List Int) : trace sum s = s.scanl (· + ·) 0 := by
  simpa [trace] using trace_sum_aux s 0
```

The trace starts with `f []`, the value on the empty prefix. The solution above
needs it: `[1, 2, -3]` sums to `0`, repeating the `0` of the empty prefix,
which is how `[1, 2, -3, 3, 1]` became `[3, 1]`.

Intuitively, we say that there is a repeated value in the trace iff there are
positions `i < j` such that `(trace f s)[i] = (trace f s)[j]`. For example, the
list `[1, 2, 3, -3, 1]` compresses to `[1, 2, 1]` because its trace under `sum`
is

```lean post (name := traceLong)
#eval trace sum [1, 2, 3, -3, 1]
```

```leanOutput traceLong
[0, 1, 3, 6, 3, 4]
```

and the value `3` is repeated, meaning that `[3, 6, 3]` can be compressed to
`[3]`, yielding the trace of `[1, 2, 1]`:

```lean post (name := traceShort)
#eval trace sum [1, 2, 1]
```

```leanOutput traceShort
[0, 1, 3, 4]
```

Consider now the following generalisation of the algorithm above that now
takes a causal function as an input parameter. It follows the same two passes,
with the running sums replaced by the values of `f` on the prefixes of `s`.
Unlike a sum, an arbitrary `f` can't be updated one element at a time, so
`compress` calls `f` on each prefix separately. Arrays wouldn't make that
linear, so `compress` keeps lists, which are simpler and easier to prove
things about:

```lean post
def compress {I O : Type} [BEq O] [Hashable O]
    (f : CausalFunction I O) (s : List I) : List I :=
  -- First pass: for each value in the trace, the length of the longest
  -- prefix with that value.
  let last := (List.range (s.length + 1)).foldl
    (fun m p => m.insert (f (s.take p)) p) (∅ : Std.HashMap O Nat)
  -- Second pass: from position p, jump to the last position with the
  -- same value.
  go last 0
where
  go (last : Std.HashMap O Nat) (p : Nat) : List I :=
    -- `max p` makes q ≥ p, so Lean can see that the recursion ends.
    let q := max p (last.getD (f (s.take p)) p)
    -- `h` proves q < s.length, which `s[q]` needs.
    if h : q < s.length then s[q] :: go last (q + 1) else []
  termination_by s.length - p
```

where `f` is a causal function whose outputs can be compared and hashed
(`[BEq O] [Hashable O]`). This algorithm is able to compress a list `s` to a
sublist `l`, and when `f` meets a condition that we prove below, `f l = f s`;
but note that compression only happens if there is a repeated element in the
trace of `s` under `f`. With `sum`, we get the solution above back:

```lean post (name := compressSum)
#eval compress sum [1, 2, -3, 3, 1]
```

```leanOutput compressSum
[3, 1]
```

For example, consider the `median` function, which returns `none` for the
empty list:

```lean post
/-- Inserts `a` into the sorted list `l`, keeping it sorted. -/
def insertSorted (a : Int) : List Int → List Int
  | [] => [a]
  | b :: l => if a ≤ b then a :: b :: l else b :: insertSorted a l

/-- Sorts a list by insertion. Unlike `List.mergeSort`, it can be evaluated
by `decide`, which `median_not_rightCongruent` below uses. -/
def insertionSort : List Int → List Int
  | [] => []
  | a :: l => insertSorted a (insertionSort l)

/-- The median of a list of integers, or `none` for the empty list. -/
def median (s : List Int) : Option Rat :=
  let sorted := insertionSort s
  let n := sorted.length
  if n = 0 then none
  -- `sorted[i]!` panics if `i` is out of range; here `i < n`.
  else if n % 2 = 1 then some sorted[n / 2]!
  else some ((sorted[n / 2 - 1]! + sorted[n / 2]! : Rat) / 2)
```

We obtain the following compressions:

```lean post (name := medianTable)
#eval do
  for s in [[1, 2, 3, -3, 4], [1, 2, 3, -3, -3], [1, 2, 3, -6, 4], [0],
            [1, 2, 2, -2, -6], [1, 2, 3, 4, 6]] do
    IO.println s!"{s} => {compress median s}  (median is {repr (median s)})"
```

```leanOutput medianTable
[1, 2, 3, -3, 4] => [1, 2, 4]  (median is some 2)
[1, 2, 3, -3, -3] => [1]  (median is some 1)
[1, 2, 3, -6, 4] => [1, 2, 4]  (median is some 2)
[0] => [0]  (median is some 0)
[1, 2, 2, -2, -6] => [1]  (median is some 1)
[1, 2, 3, 4, 6] => [1, 2, 3, 4, 6]  (median is some 3)
```

The list `[1, 2, 3, -3, -3]` compresses to `[1]` because its trace under
`median` is

```lean post (name := traceMedian)
#eval trace median [1, 2, 3, -3, -3]
```

```leanOutput traceMedian
[none, some 1, some (3 / 2), some 2, some (3 / 2), some 1]
```

and `some 1` repeats, so the trace compresses to `[none, some 1]`, the trace of
`[1]`. The reason why `[1, 2, 3, 4, 6]` does not compress to `[3]` is because
its trace

```lean post (name := traceNoRepeat)
#eval trace median [1, 2, 3, 4, 6]
```

```leanOutput traceNoRepeat
[none, some 1, some (3 / 2), some 2, some (5 / 2), some 3]
```

has no repeated elements. Pretty neat, huh?

In all six examples, compression kept the median. That is not guaranteed.
Compression jumps from a position in the trace to a later position with the
same value, and continues with the rest of the list. That is only safe when
lists with equal values stay equal after both are extended by the same element.
We call such causal functions _right congruent_, because the lists are extended
on the right:

```lean post
/-- `f` is right congruent if lists with equal values stay equal when both are
extended on the right by the same element. -/
def RightCongruent {I O : Type} (f : CausalFunction I O) : Prop :=
  ∀ x y a, f x = f y → f (x ++ [a]) = f (y ++ [a])
```

`sum` is right congruent, because the sum of `x ++ [a]` depends only on the sum
of `x` and on `a`:

```lean post
theorem sum_append (x y : List Int) : sum (x ++ y) = sum x + sum y := by
  induction x with
  | nil => simp [sum]
  -- `sum (i :: x ++ y) = i + sum (x ++ y)`; the induction hypothesis and
  -- associativity of `+` (`omega`) finish it.
  | cons i x ih => simp [sum, ih]; omega

theorem sum_rightCongruent : RightCongruent sum := by
  intro x y a h
  -- `sum (x ++ [a]) = sum x + sum [a]`, and `sum x = sum y` by `h`.
  simp [sum_append, h]
```

`median` is not: `[-3, -3, -2]` and `[-3]` both have median `-3`, but
appending `-1` gives `-5/2` and `-2`. `decide` checks this by evaluating both
sides:

```lean post
theorem median_not_rightCongruent : ¬ RightCongruent median := by
  intro h
  -- `[-3, -3, -2]` and `[-3]` both have median `-3` …
  have := h [-3, -3, -2] [-3] (-1) (by decide +kernel)
  -- … but appending `-1` gives medians `-5/2` and `-2`.
  revert this
  decide +kernel
```

So compression can change the median. The list `[-3, -3, -2, -1]` compresses
to

```lean post (name := compressMedian)
#eval compress median [-3, -3, -2, -1]
```

```leanOutput compressMedian
[-3, -1]
```

and the two medians differ:

```lean post (name := medians)
#eval (median [-3, -3, -2, -1], median [-3, -1])
```

```leanOutput medians
(some (-5 / 2), some (-2))
```

For right congruent functions, however, compression always keeps the value.
The proof follows the two passes. The first pass stores, for each value of
`f`, a position whose prefix has that value:

```lean post
/-- Every entry of the first pass's map points to a prefix with that value.
Stated for any list of positions `ps` and any starting map `m`, so that it
can be proved by induction on `ps`. -/
theorem firstPass_spec {I O : Type} [BEq O] [LawfulBEq O] [Hashable O]
    (f : CausalFunction I O) (s : List I) (ps : List Nat)
    (m : Std.HashMap O Nat)
    (hm : ∀ k j, m[k]? = some j → f (s.take j) = k) :
    ∀ k j, (ps.foldl (fun m p => m.insert (f (s.take p)) p) m)[k]? = some j →
      f (s.take j) = k := by
  induction ps generalizing m with
  | nil => simpa using hm
  | cons p ps ih =>
    apply ih
    intro k j hkj
    -- Looking up `k` after inserting `f (s.take p) ↦ p`: either `k` is the
    -- inserted key and `j = p`, or the lookup falls through to `m`.
    rw [Std.HashMap.getElem?_insert] at hkj
    split at hkj
    · simp_all
    · exact hm k j hkj
```

so each jump of the second pass lands on a position with the same value:

```lean post
/-- A jump lands on a position whose prefix has the same value. -/
theorem jump_spec {I O : Type} [BEq O] [LawfulBEq O] [Hashable O]
    (f : CausalFunction I O) (s : List I) (last : Std.HashMap O Nat)
    (hlast : ∀ k j, last[k]? = some j → f (s.take j) = k) (p : Nat) :
    f (s.take (max p (last.getD (f (s.take p)) p))) = f (s.take p) := by
  rw [Std.HashMap.getD_eq_getD_getElem?]
  cases hj : last[f (s.take p)]? with
  -- No entry: the jump goes to `max p p = p` itself.
  | none => simp
  | some j =>
    simp only [Option.getD_some]
    -- The entry `j` has the same value, and `max p j` is either `j` or `p`.
    by_cases hpj : p ≤ j
    · rw [Nat.max_eq_right hpj, hlast _ j hj]
    · rw [Nat.max_eq_left (by omega)]
```

The second pass keeps an invariant: the output so far has the same value under
`f` as the prefix of `s` up to the current position. Right congruence carries
this equality past each element that `go` outputs, and when `go` stops, that
prefix is `s` itself:

```lean post
/-- The invariant of the second pass: if the output so far, `acc`, has the
same value as the prefix of `s` up to position `p`, then so does `acc`
followed by the rest of the output, and that value is `f s`. -/
theorem go_correct {I O : Type} [BEq O] [LawfulBEq O] [Hashable O]
    (f : CausalFunction I O) (hf : RightCongruent f) (s : List I)
    (last : Std.HashMap O Nat)
    (hlast : ∀ k j, last[k]? = some j → f (s.take j) = k)
    (p : Nat) (acc : List I) (hacc : f acc = f (s.take p)) :
    f (acc ++ compress.go f s last p) = f s := by
  -- Induction that follows the recursion of `go`.
  fun_induction compress.go f s last p generalizing acc with
  | case1 p q h ih =>
    -- `go` outputs `s[q]` and continues at `q + 1`.
    have hq : f (s.take q) = f (s.take p) := jump_spec f s last hlast p
    rw [List.append_cons]
    apply ih
    -- `s.take (q + 1) = s.take q ++ [s[q]]`, and right congruence extends
    -- `f acc = f (s.take q)` by `s[q]`.
    rw [List.take_add_one, List.getElem?_eq_getElem h, Option.toList_some]
    exact hf _ _ _ (hacc.trans hq.symm)
  | case2 p q h =>
    -- `go` stops: `q` is past the end, so `s.take q = s`.
    have hq : f (s.take q) = f (s.take p) := jump_spec f s last hlast p
    rw [List.append_nil, hacc, ← hq, List.take_of_length_le (by omega)]
```

Starting with the empty output at position 0 gives the theorem:

```lean post
theorem compress_correct {I O : Type} [BEq O] [LawfulBEq O] [Hashable O]
    (f : CausalFunction I O) (hf : RightCongruent f) (s : List I) :
    f (compress f s) = f s := by
  -- Start the invariant with `acc = []` at position 0, where the first
  -- pass's map starts empty.
  simpa [compress] using
    go_correct f hf s _ (firstPass_spec f s _ ∅ (by simp)) 0 [] rfl
```

The result is also a sublist of `s`: its elements appear in `s`, in the same
order.

```lean post
theorem go_sublist {I O : Type} [BEq O] [Hashable O]
    (f : CausalFunction I O) (s : List I) (last : Std.HashMap O Nat) (p : Nat) :
    (compress.go f s last p).Sublist (s.drop p) := by
  fun_induction compress.go f s last p with
  | case1 p q h ih =>
    have hpq : p ≤ q := Nat.le_max_left _ _
    -- Split `s.drop p` into the part before `q` and `s.drop q`.
    have : s.drop p = (s.drop p).take (q - p) ++ s.drop q := by
      conv => lhs; rw [← List.take_append_drop (q - p) (s.drop p)]
      rw [List.drop_drop, Nat.add_sub_cancel' hpq]
    -- `s.drop q = s[q] :: s.drop (q + 1)`; skip the part before `q`.
    rw [this, List.drop_eq_getElem_cons h]
    exact (ih.cons_cons _).trans (List.sublist_append_right _ _)
  | case2 => exact List.nil_sublist _

theorem compress_sublist {I O : Type} [BEq O] [Hashable O]
    (f : CausalFunction I O) (s : List I) : (compress f s).Sublist s := by
  simpa [compress] using go_sublist f s _ 0
```

In particular, compressing with `sum` never changes the sum:

```lean post
example (s : List Int) : sum (compress sum s) = sum s :=
  compress_correct sum sum_rightCongruent s
```

The solution above runs in `O(n)` time and uses `O(n)` space, for a list of
length `n`. `compress` calls `f` on a whole prefix of `s` at most `2 * (n + 1)`
times, so for a function like `sum`, which reads its whole input, it takes
`O(n²)` time; it still uses `O(n)` space. Right congruent functions are exactly
those that could be updated one element at a time, like the running sum: their
next value depends only on their previous value and the new element. So for
them, given a step function that takes constant time, a version of `compress`
could run in linear time. The algorithm only requires the modification of the
causal function for it to change its behaviour, hence its higher-order nature.
These (latent) behaviours that appear when we change a parameter are what I
studied very closely during my doctorate. Maybe I will write about those in the
near future.

Thanks for reading!
