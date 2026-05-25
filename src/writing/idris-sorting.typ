#import "lib/lib.typ": *


#show: article.with(
  title: "Formally verifying insertion sort in Idris",
  date: datetime(year: 2026, month: 5, day: 24),
  description: "Using the dependently-typed programming language Idris to verify insertion sort.",
  tags: ("idris", "dependent-type"),
)

The programming language #link("https://www.idris-lang.org/")[Idris] allows you to write programs and prove theorems about them with dependent types, types that depend on values. Idris can achieve this through the #link("https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence")[Curry-Howard correspondence]—the idea that types correspond to propositions and programs correspond to proofs.

As part of a project for discrete math, I formally verified that insertion sort actually sorts lists of natural numbers. I wanted to write a thorough walkthrough of each part of the code to provide a resource on how to prove things with dependently typed languages.

Many of the guides I saw either only showed extremely basic functionality or glossed over the specifics of their proofs, making the relationship between proof and program harder to understand.

Additionally, Idris' large feature set made much of the code I saw online difficult to understand. For this guide, I used only basic features language features#footnote[
  More specifically, I did not use:
  - function application `$` operator or function composition `.` operator
  - shorthand constructors like ```idris data Nat = S Nat | Z```
  - #link("https://idris2.readthedocs.io/en/latest/proofs/propositional.html#rewrite")[implicit arguments]
  - #link("https://idris2.readthedocs.io/en/latest/proofs/propositional.html#rewrite")[`rewrite`], instead always manually using `replace`
  - #link("https://idris2.readthedocs.io/en/latest/tutorial/views.html#the-with-rule-matching-intermediate-values")[`with` rule]
] to make each function implementation as consistent and comprehensible as possible.

For those new to dependently-typed languages, I would recommend looking at the #link("https://idris2.readthedocs.io/en/latest/tutorial/index.html")[Idris 2 Crash Course] and the #link("https://adam.math.hhu.de/")[Lean Natural Number Game] (the concepts apply to Idris as well).

= Definitions

== Standard library
First, to refresh our knowledge of Idris's basic types, we look at the definition of natural numbers and lists provided by the standard library.
```idris
data Nat : Type where
  Z : Nat
  S: Nat -> Nat
```
We define natural numbers as an enum with two variants: the zero base case value `Z` and the successor `S` that wraps another natural number. Thus, we represent 0 as `Z`, 1 as `S Z`, 3 as `S (S (S Z))`, continually incrementing numbers by wrapping them in layers of successors.
```idris
data Vect : Nat -> Type -> Type where
  Nil : Vect 0 elem
  (::) : elem -> Vect len elem -> Vect (S len) elem
```
Looking at the first line of code, ```idris data Vect : Nat -> Type -> Type where```, we parameterize our definition of `Vect` over the list's length and the type of the contained items. Then, we have a base case constructor of an empty list, and a constructor that adds an element to an already existing list while keeping the type's length information correct.

We also need a way to order our natural numbers.
```idris
data LTE : (n, m : Nat) -> Type where
  LTEZero : LTE Z    right
  LTESucc : LTE left right -> LTE (S left) (S right)
```

We define evidence `LTE`, parameterized over two natural numbers. Constructing an element of type `LTE x y` proves that `x <= y`. Our base case, `LTEZero`, simply states that zero is less than or equal to any other natural number, because it's the smallest number. `LTESucc` allows us to increment both of the numbers on each side of the inequality, allowing us to express any possible `LTE` relationship between two natural numbers.

== `Sorted`
In order to prove that our insertion sort algorithm sorts, we need a definition of sortedness.
```idris
data Sorted : (xs : Vect n Nat) -> Type where
  SortedZero: Sorted Nil
  SortedOne: (x : Nat) -> Sorted (x::Nil)
  SortedMany: (x : Nat) -> (y : Nat) -> (ys : Vect n Nat) ->
    (LTE x y) -> Sorted (y :: ys) ->
    Sorted (x :: (y :: ys))
```
We parameterize our definition of `Sorted` over a given list of natural numbers. Thus, if we can construct a value of type `Sorted xs`, then we have proven that the list `xs` is sorted.

In this definition, we have two base cases `SortedZero` and `SortedOne`: if our list contains zero or one items, we already know that it is sorted.

Our recursive `SortedMany` definition is more complicated, but becomes easier to understand if you read it backwards. The basic idea is that, given a list containing at least two elements $[x, y, ...]$, represented as `(x :: (y :: ys))` in the above proof, you know it is sorted if both
1. $[y, ...]$ is sorted
2. $x <= y$

Reading the `SortedMany` constructor forwards gives a more constructive view of the theorem it represents. Instead of proving that a given list is sorted, we can think of this constructor as taking an element `x`, `y`, a list `ys`, a proof that `y::ys` is sorted, and a proof that `x <= y`, and outputting a proof that a new list `x::(y::ys)` is sorted.

== `Permutation`
In addition to proving that our insertion sort algorithm sorts, we also need to prove that the elements in the outputted list are the same as those in the inputted list; in other words, we must prove that the output is a permutation of the input. Thus, we create a definition of permutation.
```idris
data Permutation : (xs: Vect n Nat) -> (ys: Vect n Nat) -> Type where
  PermutationZero: Permutation [] []
  PermutationGrow: (as, bs: Vect n Nat) -> (x : Nat) ->
    Permutation as bs -> Permutation (x::as) (x::bs)
  PermutationSwap: (as, bs : Vect n Nat) -> (a, b : Nat) -> Permutation as bs ->
    Permutation (a::(b::as)) (b::(a::bs))
  PermutationTrans: (as, bs, cs : Vect n Nat) ->
    Permutation as bs -> Permutation bs cs -> Permutation as cs
```
Here, we parameterize our definition of `Permutation` over two lists, claiming that a construction of a value of type `Permutation xs ys` proves that `ys` permutes `xs`.

Our base case `PermutationZero` simply states that empty lists permute each other. Both `PermutationGrow` and `PermutationSwap` claim that larger lists permute each other given that smaller lists do as well; `PermutationGrow` claims that two permutations with the same element added to the front permute each other, and `PermutationSwap` claims that two permutations with the same two elements added to the front in different orders permute each other. `PermutationTrans` just states that permutation is transitive, meaning that if $x$ permutes $y$ and $y$ permutes $z$ then $x$ permutes $z$.

== `Elem`

To make some of our proofs easier, we need a way to state that `x` is an element of a list.
```idris
data Elem : (x : a) -> (xs : Vect n a) -> Type where
  Here  : Elem x (x :: xs)
  There : Elem x xs -> Elem x (y :: xs)
```
Our definition has a base case of `Here` if `x` is the first element of the list, and `There` if it is a later element of the list. So to construct a proof that `x` is in `xs = [x, ...]`, we would simply write `Here`, and to construct a proof that `x` is in `xs = [z, y, x, ...]` we would write `There (There Here)`.


= Theorems

When thinking through how to prove our theorem, I found it easiest to start from high-level functions and create smaller functions with the correct type declarations but with #link("https://docs.idris-lang.org/en/latest/tutorial/typesfuns.html#holes")[holes] as placeholders for their bodies.

== `insertionSort`

The highest-level theorem is, of course, our `insertionSort` function. First, let's create the functions type declaration. Note that this type declaration corresponds to the theorem that we are stating by the Curry-Howard isomorphism:
```idris
insertionSort : (inList : Vect n Nat)
  -> (outList : Vect n Nat ** (Sorted outList, Permutation inList outList))
```
Here, we take in some list `inList`, and output an `outList` #link("https://docs.idris-lang.org/en/latest/tutorial/typesfuns.html#dependent-pairs")[dependently-paired] with a proof that `outList` is sorted and that `outList` permutes `inList`. Stating this function as a theorem, we are saying that
#quote(block: true)[Let `inList` be a list. There exists a sorted list `outList` that is a permutation of `inList`.]


Now, let's look at our function implementation. By the Curry-Howard isomorphism, the implementation corresponds to the proof of our theorem. First, we handle the case of an empty list:
```idris
insertionSort [] = ([] ** (SortedZero, PermutationZero))
```
The `SortedZero` constructor proves that an empty list is sorted, and `PermutationZero` proves that both empty lists permute each other.

The more interesting case comes when the list contains at least one element.
```idris
insertionSort (x::xs) =
  let
    recursiveCase : (xsSorted : Vect _ Nat ** (Sorted xsSorted, Permutation xs xsSorted)) = insertionSort xs
    (xsSorted ** (sor1, perm1)) = recursiveCase
    insertRet : (xsSortedInserted : Vect _ Nat ** (Sorted xsSortedInserted, Permutation (x::xsSorted) xsSortedInserted))
      = insert xsSorted sor1 x
    (xsSortedInserted ** (sor2, perm2)) = insertRet
    perm3 : Permutation (x :: xs) (x :: xsSorted) =
      PermutationGrow xs xsSorted x perm1
    permRet : Permutation (x::xs) (xsSortedInserted) =
      PermutationTrans (x::xs) (x::xsSorted) xsSortedInserted perm3 perm2
  in (xsSortedInserted ** (sor2, permRet))
```
First, we recursively sort the tail of our list, `xs`, storing the result in `xsSorted`. Then, we use a new function, `insert`, to insert our head into the `xsSorted`. Our `insert` function outputs a new list we call `xsSortedInserted`, and conveniently provides proof that `xsSortedInserted` is sorted and that `xsSortedInserted` permutes `x::xsSorted` (another way of saying that `xsSortedInserted` consists of all elements from `xsSorted` and `x`).

The final part of the proof consists of proving that the input list, `x::xs`, permutes the output list `xsSorted`. First, we use the fact that we know that `xs` permutes `xsSorted` to prove that `x::xs` permutes `x::xsSorted` with `PermutationGrow`, storing this proof in perm3. That gives us two permutation proofs
1. `x::xs` permutes `x::xsSorted`
2. `x::xsSorted` permutes `xsSortedInserted`
These two permutations perfectly match our `PermutationTrans` constructor, allowing us to construct a proof that `x::xs` permutes `xsSortedInserted`, completing our function.

Now we've completed our proof! All we need to do is finish that `insert` function we assumed existed.

== `insert`

We again start with the type declaration:
```idris
insert : (inList : Vect n Nat) -> (Sorted inList) -> (x : Nat)
  -> (outList : Vect (S n) Nat ** (Sorted outList, Permutation (x::inList) outList))
```
Here, we take some sorted list `inList` and some element `x`, and output a sorted list that permutes `x::inList`.

We again have an easy base case if the list is empty:

```idris
insert [] sor x = ([x] ** (SortedOne x, permutationId [x]))
```
Here, we use a utility theorem, `permutationId`, that proves that two identical lists permute each other by repeatedly applying `PermutationGrow`.
```idris
permutationId : (xs : Vect n Nat) -> Permutation xs xs
permutationId [] = PermutationZero
permutationId (x::xs) = PermutationGrow xs xs x (permutationId xs)
```

This theorem may seem obvious, but Idris' type system requires that we prove it.

Unfortunately, the case where the list contains more than one element becomes more complicated.

First, we define a new function `lteTotal` that proves an obvious fact: for two natural numbers $x$ and $y$, either $x <= y$ or $y <= x$.
```idris
lteTotal : (x, y : Nat) -> Either (LTE x y) (LTE y x)
lteTotal Z Z = Left LTEZero
lteTotal Z (S m) = Left LTEZero
lteTotal (S n) Z = Right LTEZero
lteTotal (S n) (S m) =
  case lteTotal n m of
    Left p => Left (LTESucc p)
    Right p => Right (LTESucc p)
```
Here we have a bunch of base cases whenever one of the natural numbers is zero, and a recursive case that uses `LTESucc` if both numbers are nonzero.

Going back to our `insert` function, we apply `lteTotal` to compare the element we want to insert, `x`, and the first element `y` of our input list `y::ys`.
```idris
insert (y::ys) sor x =
  case lteTotal x y of
    Left prf =>
      let
        retSor = SortedMany x y ys prf sor
        ret = (x::(y::ys) ** (retSor, permutationId (x::(y::ys)) ))
      in ret
    Right prf =>
      let
        ysSorted = sortedImpliesSortedSmaller y ys sor
        recursiveCase = insert ys ysSorted x
        (x_ys ** (sor1, perm1)) = recursiveCase
        y_x_ysSorted = yLtXAndYsImpliesYLtXYs x y ys x_ys prf sor sor1 perm1
        intermediatePerm: Permutation (y::(x::ys)) (y::x_ys) = PermutationGrow (x::ys) (x_ys) y perm1
        retPerm: Permutation (x::(y::ys)) (y::x_ys) =
          PermutationTrans
            (x::(y::ys)) (y::(x::ys)) (y::x_ys)
            (PermutationSwap ys ys x y (permutationId ys)) intermediatePerm
        ret = (y::x_ys ** (y_x_ysSorted, retPerm))
      in ret
```

If `x` is smaller than or equal to `y`, then putting `x` at the start of our list will keep it sorted. We handle this possibility in the `Left` case, where we use the `SortedMany` constructor to prove that `x::(y::ys)` is sorted given that `x` $<=$ `y`.

The more interesting case happens when `x` is larger than `y`, which we handle in the `Right` case.#footnote[Technically, we only have a proof that `y` is less than or equal to `x`, which is all we need to complete our proof. However, based on how our `lteTotal` function is defined, we will only reach the `Right` branch of `x` $>$ `y`.] First, we use a utility function `sortedImpliesSortedSmaller` to show that `ys` is sorted, which is obviously true because `y::ys` is sorted.
```idris
sortedImpliesSortedSmaller : (x: Nat) -> (xs : Vect n Nat) -> (Sorted (x::xs)) -> Sorted xs
sortedImpliesSortedSmaller x [] _ = SortedZero
sortedImpliesSortedSmaller x (y::ys) (SortedMany x y ys _ sor) = sor
```
Because `x` is greater than `y`, we insert `x` somewhere in the part after `y` using our `insert` function. We call the list resulting from that insertion  `x_ys`. Finally, we attach `y` to the front of `x_ys`, creating our final list `y::x_ys`. The only remaining task is constructing the proofs that `y::x_ys` is sorted and is a permutation of `x::(y::ys)`.

To prove permutation, we use `PermutationGrow` to prove that `y::(x::ys)` permutes `y::x_ys` given that we know that `x::ys` permutes `x_ys` from our insertion. Then, we directly apply the `PermutationSwap` constructor to see that `x::(y::ys)` permutes `y::(x::ys)`, and finally use `PermutationTrans` to combine those two permutations and create our final permutation.

To prove sortedness, we use a magical theorem `yLtXAndYsImpliesYLtXYs` to show that `y::x_ys`, a theorem complex enough to deserve its own section!

== `yLtXAndYsImpliesYLtXYs`

As the theorems got more complex, naming them also became harder, leading to the mess of characters heading this section. The type declaration this function shares the complexity of its name:
```idris
yLtXAndYsImpliesYLtXYs:
  (x, y: Nat) -> (ys: Vect n Nat) -> (x_ys : Vect (S n) Nat) ->
  (LTE y x) -> (Sorted (y::ys)) -> (Sorted x_ys) -> (Permutation (x::ys) x_ys) -> (Sorted (y::x_ys))
```
I think the best way to understand this function is to read it as a theorem
#quote(block: true)[
  Theorem: Let `x`, `y` be elements and `ys` be a list. Let `x_ys` be a list that contains `x` and
  all elements in `ys` in some order. If `y` $<=$ `x` and `y::ys` is sorted (which means that `y` $<=$
  all elements in `ys`), then the list `y::x_ys` is sorted.
]
Due to the use of magical functions that abstract away details, the implementation of this function remains quite small.
```idris
yLtXAndYsImpliesYLtXYs:
  (x, y: Nat) -> (ys: Vect n Nat) -> (x_ys : Vect (S n) Nat) ->
  (LTE y x) -> (Sorted (y::ys)) -> (Sorted x_ys) -> (Permutation (x::ys) x_ys) -> (Sorted (y::x_ys))
yLtXAndYsImpliesYLtXYs x y ys (f::x_ysTail) yLteX y'ysSor x_ysTailSor x'ysPermX_ys =
  let
    yLteF =
    case elOfListIsInPermOfList f (permutationRev x'ysPermX_ys) Here of
      Here => replace {p=(\k => LTE y k)} Refl yLteX
      There elem => yAfterXInSortedListImpliesXLtY y f ys y'ysSor elem
    in SortedMany y f x_ysTail yLteF x_ysTailSor
```
Here, we are trying to prove that adding `y` to the front of the sorted list `f::x_ysTail` (also know as `x_ys` in the type declaration) will create another sorted list.

Before getting to the main idea of our proof, we have to reverse the permutation `x'ysPermX_ys` constructing `Permutation x_ys (x::ys)` from `Permutation (x::ys) x_ys`. To prove this obvious fact, we have create a tiny utility theorem:
```idris
permutationRev : Permutation xs ys -> Permutation ys xs
permutationRev (PermutationZero) = PermutationZero
permutationRev (PermutationGrow as bs x p) =
  (PermutationGrow bs as x (permutationRev p))
permutationRev (PermutationSwap as bs a b p) =
  PermutationSwap bs as b a (permutationRev p)
permutationRev (PermutationTrans as bs cs perm1 perm2) =
  PermutationTrans cs bs as (permutationRev perm2) (permutationRev perm1)
```

First, we use the theorem `elOfListIsInPermOfList` to show that, because `f::x_ysTail` is a permutation of `x::ys`, then `f` must be an element of the list `x::ys`. That means `f` must either:
1. Be equal to the head `x` of `x::ys`
2. Be an element of the tail `ys` of `x::ys`

In both cases, we create evidence `yLteF` of type `idris LTE y f` to show that `y` is less than or equal to the first element of `f::x_ysTail`, which is enough to construct a `SortedMany` that completes the proof.

In the case that `f` equals `x`, we can use the fact that we know that `y` $<=$ `x` to show that `y` $<=$ `f` by substitution. We do this substitution with Idris' built in #link("https://idris2.readthedocs.io/en/latest/proofs/propositional.html#replace")[`replace` function].

In the case that `f` is in `ys`, we use another theorem `yAfterXInSortedListImpliesXLtY` to show that `y` $<=$ `f`.


== `elOfListIsInPermOfList`

This theorem tells us that given some list containing element `x`, any permutation of that list will also contain `x`.

```idris
elOfListIsInPermOfList: (a : Nat) -> Permutation as cs -> Elem a as
  -> Elem a cs
elOfListIsInPermOfList c (PermutationSwap xs ys a b p) elem = case elem of
  Here => There (Here)
  There (Here) => Here
  There (There pos) => There (There (elOfListIsInPermOfList c p pos))
elOfListIsInPermOfList l (PermutationGrow xs ys x p1) elem = case elem of
  Here => Here
  There elem => There (elOfListIsInPermOfList l p1 elem)
elOfListIsInPermOfList a (PermutationTrans as bs cs p1 p2) aElemAs = let
  aElemBs : (Elem a bs) = elOfListIsInPermOfList a p1 aElemAs
  in elOfListIsInPermOfList a p2 aElemBs
```

Here, we simply look at every possible `Permutation` constructor, recursively finding out where the element is. Note that we don't need to handle `PermutationZero` because idris has statically determined that passing in `PermutationZero` would be impossible for lists that contain elements.

== `yAfterXInSortedListImpliesXLtY`

We've arrived at our final theorem, another heap of messy characters. The idea of this theorem, however, is simple: if an element `y` is in a list `xs`, and the list `x::xs` is sorted, then `x <= y`. In other words, if an element `y` comes after `x` in a sorted list, then `x <= y`.

```idris
yAfterXInSortedListImpliesXLtY: (x, y : Nat) -> (xs : Vect n Nat) -> (Sorted (x::xs)) -> (Elem y xs)
  -> (LTE x y)
yAfterXInSortedListImpliesXLtY x y (y::xs) (SortedMany x y xs prfLte sor) Here = prfLte
yAfterXInSortedListImpliesXLtY x y (f::xs) (SortedMany x f xs prfLte sor) (There n) = let
  fLteY : LTE f y = yAfterXInSortedListImpliesXLtY f y xs sor n
  xLteF : LTE x f = prfLte
  in transitive xLteF fLteY
```
First, note that because we have at least two elements in our list (`x` and `y`), Idris can statically guarantee that we only need to handle the `SortedMany` constructor.

Our proof splits on two cases:
1. If `y` happens to be the first element in `xs`, then we can just return the `LTE` evidence embedded in our proof of sortedness.
2. If `y` is not the first element in `xs`, then we call the first element `f`, and recursively prove that `f <= y`. Then we use the `LTE` in our proof of sortedness to show that `x <= f`, and use the standard-library-defined `transitive`#footnote[The #link("https://idris-lang.org/Idris2/base/source/Data.Nat.html")[implementation] is pretty simple, although it uses the `Transitive` interface which makes it a bit confusing. Ignoring interfaces, we could prove this property by writing
    ```idris
    transitive: LTE x y -> LTE y z -> LTE x z
    transitive LTEZero _ = LTEZero
    transitive (LTESucc xy) (LTESucc yz) =
      LTESucc $ transitive xy yz
    ```
  ] property of inequality to show that `x <= f`.

= Conclusion

With all these theorems in place, our program finally compiles, which—by the guarantees of Idris' type system—proves that our sorting algorithm works correctly. Creating an actual proof is a powerful statement: assuming Idris has no bugs, our program will sort _any_ list of natural numbers, no matter the size of the list or the size of the numbers. We know this without any testing, fuzzing, or manual inspection—as long as we trust our definitions, the fact that the program compiles provides total assurance. You can find the complete #link("https://github.com/Ashwagandhae/cs-2051-dependent-types/blob/main/src/MainPrez.idr")[source code on GitHub].

Throughout this guide, I paired thorough proof explanations and programs that express those proofs. I intended for these pairings to help clarify the main idea of the Curry-Howard correspondence:
#quote(block: true)[Types correspond to propositions, programs correspond to proofs]

I hope it helps aspiring dependent typers learn!

