#import "lib/lib.typ": *
#import "@preview/lilaq:0.5.0" as lq


#show: article.with(
  title: "Finding all disarium numbers in 12 seconds",
  date: datetime(year: 2025, month: 12, day: 19),
  description: "Explanation of how I wrote a Rust program to find all disarium numbers in 12 seconds.",
  tags: ("rust", "multithread", "benchmark"),
)

A disarium numbers is an integer where the sum of the digits powered to their position in the number equals the original number. For example, 135 is a disarium number, because $1^1 + 3^2 + 5^3 = 135$.

As a way to learn more about benchmarking and writing code that go fast, I wrote a #link("https://github.com/Ashwagandhae/disarium/")[Rust program] to find all the disarium numbers as quickly as possible. I got the program to check all 18446744073709551616 `u64`s in just over 12 seconds on my MacBook Pro M4.

= Problem scope

To understand the scope of this problem, I did some preliminary research and realized that there are a finite number of disarium numbers, because once you reach 23 digits, the largest possible digit-power-sum only has 22 digits:

```
99999999999999999999999 <- 23 digit number with max digit sizes
9960805384609063732919  <- digit-power-sum of 99999999999999999999999
```

This digit difference means that there cannot exist any disarium numbers with more than 22 digits because all digit-power-sums after that will be too small.

In reality, there are only 20 disarium numbers, and all of them fit into a `u64`. To make implementation easier, I decided to benchmark checking all `u64`s instead of using `u128`s and going to 22 digits, although I also checked the runtime with `u128`s in the end as well.

= Basic approach

The easiest way to find all disarium numbers is to loop through every integer, break it into digits, and check if the digit-power-sum equals the original number to see it's a disarium number.

A small optimization is to store and increment the digits separately so that you don't have to repeatedly extract digits.#footnote[
  I have tragically prematurely optimized without benchmarking, fertilizing the roots of #link("https://en.wikipedia.org/wiki/Program_optimization#When_to_optimize")[the tree of all evil].
] I implemented this version as a starting point.

#file-display("src/lib.rs")[
  ```rust
  fn add_one(digits: &mut [u8], number: &mut u64) {
      *number += 1;
      for i in (0..digits.len()).rev() {
          if digits[i] < 9 {
              digits[i] += 1;
              return;
          }
          digits[i] = 0;
      }
  }

  fn check_disarium(digits: &[u8], number: u64) -> bool {
      let number_cmp: u64 = digits
          .iter()
          .skip_while(|&n| *n == 0)
          .enumerate()
          .map(|(i, n)| (*n as u64).pow(i as u32 + 1))
          .sum();
      number_cmp == number
  }

  pub fn find_disarium(bound: u64) -> impl Iterator<Item = u64> {
      let mut digits = [0; 10];
      let mut number: u64 = 0;
      std::iter::from_fn(move || {
          while number < bound {
              add_one(&mut digits, &mut number);
              if check_disarium(&digits, number) {
                  return Some(number);
              }
          }
          None
      })
  }
  ```
]
Checking the first 100 million integers gives

```
1
2
3
4
5
6
7
8
9
89
135
175
518
598
1306
1676
2427
2646798
```

This approach gives us 18 out of 20 numbers in about 1 second. Unfortunately, the final two are slightly larger, and will take some more optimization to reveal in a reasonable amount of time.

= Benchmarking

To properly measure performance improvements, I installed the benchmarking library #link("https://docs.rs/criterion/latest/criterion/")[criterion]. This library makes measuring benchmark differences easier and more reliable. I wrote a simple benchmark on the first 1 million numbers:
#file-display("benches/benchmark.rs")[
  ```rs
  pub fn criterion_benchmark(c: &mut Criterion) {
      c.bench_function("disarium 1 mil", |b| {
          b.iter(|| find_disarium(black_box(1_000_000)).collect::<Vec<_>>())
      });
  }
  ```
]

= Table of powers

Because there are only 10 possible digits and 20 possible digit places, we can precalculate all possible powers for each digit and store them in a table at compile time.

#file-display("src/lib.rs")[
  ```rs
  const DIGIT_POWERS: [[u64; 20]; 10] = {
      let mut table = [[0u64; 20]; 10];
      let mut d = 0;
      while d < 10 {
          let mut p = 0;
          while p < 20 {
              table[d][p] = (d as u64).pow((p + 1) as u32);
              p += 1;
          }
          d += 1;
      }
      table
  };
  fn exp_digit(digit: usize, position: usize) -> u64 {
      DIGIT_POWERS[digit][position]
  }
  ```
]

In addition to helping "improve code", using a benchmarking library like criterion has a very good benefit of gamifying optimization. The dopamine-rich green dripping off of improving benchmarks provides great motivation to continue coding.

```ansi
]10;rgb:ab/b2/bf\]11;rgb:21/25/2b\[0m[38;2;152;195;121mdisarium 1 mil          [0mtime:   [[0m[2m2.0033 ms [0m[1m2.0059 ms [0m[2m2.0086 ms[0m]
                        change: [[0m[2m−71.564% [0m[1m[38;2;152;195;121m−71.299% [0m[2m−71.063%[0m] (p = 0.00 < 0.05)
                        Performance has [0m[38;2;152;195;121mimproved[0m.
```

Our optimization seems to have worked. So good!


= Freezing digits

Tragically, reducing the work we do to check each number will still end up slow if we do that work on all 18,446,744,073,709,551,616 `u64`s. I decided to look for ways to exclude ranges of numbers and save time.

To help look for patterns, I used a quick python script to create a graph of the differences between each number and its digit-power-sum. I've recreated this graph:

#let disarium(num) = {
  let digit-str = str(num)
  let digits = range(0, digit-str.len()).map(i => digit-str.at(i)).map(int)
  digits.enumerate().map(((i, d)) => calc.pow(d, i + 1)).sum()
}
#let xs = range(0, 100)

#show: lq.theme.moon
#figure[
  #lq.diagram(
    xlabel: [natural numbers],
    ylabel: [$"digit-power-sum"(n) - n$],
    xaxis: (exponent: 0),
    yaxis: (exponent: 0),
    width: 350pt,
    height: 200pt,

    lq.stem(
      xs,
      x => disarium(x) - x,
      mark: none,
    ),
  )
]

This graph helped me realize was that *lower-place digits have the largest impact on the digit-power-sum* because they are powered to the highest number. In the graph, we can see distinct groups of 10 numbers, each abruptly ending with a jump downwards when the 9 digit turns into a 0. We can explain these groups by remembering the digit-power-sum formula; the last digit will always be powered to the highest power, so it has the biggest impact.

Because lower-place digits have the biggest impact, I decided to see how isolating numbers ending in the same digit—for example, digit 8—would look.

#figure[
  #lq.diagram(
    xlabel: [natural numbers],
    ylabel: [$"digit-power-sum"(n) - n$],
    xaxis: (exponent: 0),
    yaxis: (exponent: 0),
    width: 350pt,
    height: 200pt,

    lq.stem(
      xs,
      x => disarium(x) - x,
      mark: none,
    ),

    lq.stem(xs, x => if calc.rem(x, 10) == 8 { disarium(x) - x } else { 0 }, mark: none),
  )
]

This isolation reveals a pattern: it looks like for two-digit numbers ending with 8, there's only a small window between about 60 and 80 where finding a disarium number is possible. Going backwards from the window, the difference seems to get larger and larger. We see a similar pattern going forwards, where the difference seems to get larger in the negative direction.

We can justify this intuition mathematically. For two-digit numbers ending with 8, we can calculate the minimum possible digit-power-sum by minimizing the unknown first digit. The minimum possible first digit that doesn't make the number a one-digit number is 1.
$ "digit-power-sum"(18) = 1^1 + 8^2 = 65 $
Because the minimum possible number we can make is 65, there's no reason to check 58, 48, or any other number below 65 that has two digits and ends with 8.

We can also find an upper bound by maximizing the first digit, setting it to 9 instead of 1.
$ "digit-power-sum"(98) = 9^1 + 8^2 = 73 $
By the same logic as before, it makes no sense to check 78, 88, or any other number larger than 73 (that has two digits and ends with 8).

Thus, we have mathematically proven that the only possible disarium candidates for two-digit numbers ending in eight must be in the range $[65, 73]$. The only number we have to check is 68, reducing our work from checking 9 different numbers to just checking 1.

We can generalize this approach to work on multiple low-place digits. Whenever we want to check all $n$-digit numbers,
+ *We choose some integer $m$, where $m <= n$, for the number of low-place digits we want to "freeze".*
  For example, for 5-digit numbers, we could choose to "freeze" 2 digits.
+ *We go through all possible frozen digits.* Continuing our example, all possible pairs of 2 digits are $(0, 0), (0, 1), (0, 2), ... , (9, 9)$.
+ *For each frozen digit set...*
  #let min-digits = 10089
  #let max-digits = 99989
  + *We calculate the minimum and maximum digit-power-sums.* If our digits are $(8, 9)$, then our minimum is $"digit-power-sum"(#min-digits) = #disarium(min-digits)$ and our maximum is $"digit-power-sum"(#max-digits) = #disarium(max-digits)$.
  + *We check only numbers in [minimum, maximum]*. For our example, we would only have to check numbers in the range $[#disarium(min-digits), #disarium(max-digits)]$. This reduces the number of numbers we need to check from 900 to just #range(disarium(min-digits), disarium(max-digits) + 1).filter(x => str(x).ends-with("89")).len().

You can see how many checks we save for different digit amounts and frozen digits with the calculator below.

#embed("disarium-bounds-calculator")

Implementing this algorithm was the most significant optimization in the project. The actual implementation was cumbersome, requiring splitting the numbers into different digit count buckets and dealing with correctly handling maximum and minimum bounds. To simplify the code, I created a `Digit` struct that encapsulated some of the number methods.

Here's the most important snippet, the function that calculates the maximum and minimum bounds given some frozen digits and searches that range for disarium numbers.

#file-display("src/lib.rs")[
  ```rs
  fn disarium_for_digit_count_with_frozen(
      digit_count_unfrozen: u32,
      bound: u64,
      frozen_digits: [Digit; NUM_FROZEN],
  ) -> Vec<u64> {
      let digit_count = digit_count_unfrozen + NUM_FROZEN as u32;

      let min_digits =
          Digits::from_number(10u64.pow(digit_count - 1)).with_overwritten(&frozen_digits);

      let max_digits =
          Digits::from_number(10u64.pow(digit_count) - 1).with_overwritten(&frozen_digits);

      let start_digits =
          Digits::from_number(min_digits.exp_by_index()).with_overwritten(&frozen_digits);
      let end_digits =
          Digits::from_number(max_digits.exp_by_index()).with_overwritten(&frozen_digits);

      let start = start_digits.to_number().max(min_digits.to_number());
      let end = end_digits
          .to_number()
          .min(max_digits.to_number())
          .min(bound);

      search_range(start, end, NUM_FROZEN as u32)
  }
  ```
]

Our cumbersome implementing is rewarded by criterion with more beautiful green numbers!

```ansi
]10;rgb:ab/b2/bf\]11;rgb:21/25/2b\[0m[38;2;152;195;121mdisarium 1 mil          [0mtime:   [[0m[2m33.079 µs [0m[1m33.174 µs [0m[2m33.260 µs[0m]
                        change: [[0m[2m−98.354% [0m[1m[38;2;152;195;121m−98.350% [0m[2m−98.346%[0m] (p = 0.00 < 0.05)
                        Performance has [0m[38;2;152;195;121mimproved[0m.
```

= Parallel processing

After implementing the more optimized algorithm, I decided to improve performance by splitting my work across multiple threads. For every digit length $n$, I split the $m^3$ frozen digits into 10 different buckets by deciding the first frozen digit in a parallelized outer loop.#footnote[I eventually switched to 100 buckets because it performed better, likely because smaller units of work improved load balancing.]
#file-display("src/lib.rs")[
  ```rs
  use rayon::prelude::*;
  // ...
  let mut res: Vec<_> = (0..(10 as Number))
      .into_par_iter()
      .flat_map(|i| {
          (0..(10 as Number).pow(NUM_FROZEN as u32 - 1))
              .flat_map(|frozen_number_lower| {
                  let frozen_number =
                      frozen_number_lower + i * (10 as Number).pow(NUM_FROZEN as u32 - 1);
                  let frozen_digits = num_to_digits(frozen_number);
                  disarium_for_digit_count_with_frozen(
                      digit_count_unfrozen,
                      bound,
                      frozen_digits,
                  )
              })
              .collect::<Vec<_>>()
      })
      .collect();
  res.sort();
  res
  ```
]

Using the wonderful #link("https://docs.rs/rayon/latest/rayon/")[rayon] library made this code trivial to write. Because of the nondeterministic order introduced by multithreading, I also sorted the result `Vec` to make the output look nice.#footnote[Although sorting might techically reduce the program's speed without adding any crucial functionality, the guarantee of $<=$ 20 items in the `Vec` makes the slowdown very small and worth the nicer output.]

= Optimizing digit-freezing amounts

When I initially implemented digit freezing, I chose $m$,the number of digits to freeze, arbitrarily. Increasing $m$ would eventually converge to just checking each number slowly, and decreasing $m$ would also converge to just checking all numbers, so I knew that the approach needed to be somewhere in the middle. Thus, I decided to benchmark what value of $m$ was fastest for each digit count, hoping to find some kind of pattern.

Previously, `NUM_FROZEN` had been a constant. I decided to preserve this behavior by using Rust's const generics to create an array of different variants of the `freeze_and_split` functions, each with different constant `NUM_FROZEN` sizes, allowing the frozen digits array to be perfectly sized for all variants of the function.#footnote[(Ab)using generics like this might make compile times slower because you create many copies of the `freeze_and_split` function. However, it theoretically also has the benefit of allowing the compiler to optimize for each individual array size.]

#file-display("lib.rs")[
  ```rs
  fn freeze_and_split<const NUM_FROZEN: usize>(digit_count: u32, bound: Number) -> Vec<Number> { // [!code ++]
  fn freeze_and_split(digit_count: u32, bound: Number) -> Vec<Number> { // [!code --]
      // ...
  }
  // ...
  // [!code ++:8]
  pub const FREEZE_AND_SPLIT_VARIANTS: [fn(u32, Number) -> Vec<Number>; 18] = [
      freeze_and_split::<2>,
      freeze_and_split::<3>,
      freeze_and_split::<4>,
      freeze_and_split::<5>,
      freeze_and_split::<6>,
      // ...
  ];
  ```
]

Then, I wrote some code to manually benchmark each of these variants, improperly writing my own warm-up code instead of using criterion because I just wanted to see if I could find any patterns in what `NUM_FROZEN` value resulted in the fastest performance.

#file-display("main.rs")[
  ```rs
  fn time_digit_count(digit_count: u32) {
      let max = (10 as u128).pow(digit_count) - 1;
      println!("warming up...");
      let start = Instant::now();
      for _ in 0..1000 {
          FREEZE_AND_SPLIT_VARIANTS[5](digit_count, max);
      }
      let duration = start.elapsed();
      println!("warm up for: {}", duration.as_nanos());
      println!("testing digit count: {}", digit_count);
      for i in (0..FREEZE_AND_SPLIT_VARIANTS.len()) {
          let variant = FREEZE_AND_SPLIT_VARIANTS[i];
          let start = Instant::now();
          for _ in 0..100 {
              variant(digit_count, max);
          }
          let duration = start.elapsed();
          println!(
              "duration of variant {i} (number {}): {} nanosecs",
              i + 2,
              duration.as_nanos()
          );
      }
  }
  ```
]

After manually trying digit counts 1 to 15, I found that beyond very low digit counts, the best `NUM_FROZEN` value seemed to consistently be
$ floor(("digit_count" - 2) / 2) $
The differences in times consistently stayed above 2 or 3x slower for increasing or decreasing the `NUM_FROZEN` value by 1, whittling away doubts about my improper benchmarking methods and giving me reasonable confidence in this pattern.

Using my knowledge, I created an array indexed by `digit_count` of `freeze_and_split` functions with optimal `FROZEN_DIGIT`s.

#file-display("lib.rs")[
  ```rust
  const FREEZE_AND_SPLIT_FUNCS: [fn(u32, Number) -> Vec<Number>; 26] = [
      // ... (low digit counts)
      freeze_and_split::<2>,  // 6
      freeze_and_split::<2>,  // 7
      freeze_and_split::<3>,  // 8
      freeze_and_split::<3>,  // 9
      freeze_and_split::<4>,  // 10
      freeze_and_split::<4>,  // 11
      freeze_and_split::<5>,  // 12
      freeze_and_split::<5>,  // 13
      freeze_and_split::<6>,  // 14
      freeze_and_split::<6>,  // 15
      freeze_and_split::<7>,  // 16
      freeze_and_split::<7>,  // 17
      // ...
  ]
  ```
]

A reasonable next step would be to find a mathematical explanation for this pattern. I did not do this because that would be hard.

= Other optimizations

Besides these important speed-ups, I also fiddled around with smaller optimizations that improved speed slighly, such as
- making all `digit_count` inputs const generics, to allow for perfectly-sized arrays at compile time
- improving the digit to integer algorithm by copying ideas from #link("https://crates.io/crates/itoa")[itoa]
- turning off parallel processing for smaller `digit_count`s to reduce unecessary overhead
- minimizing integer-to-digit and digit-to-integer conversions

= Results

The program can check all `u64`s in 12423617458 ns, or 12423 ms, or 12 secs! Here's the terminal output:

```
0
1
2
3
4
5
6
7
8
9
89
135
175
518
598
1306
1676
2427
2646798
12157692622039623539
found numbers in 12423617458 ns, or 12423 ms, or 12 secs
```

I've also run the program on `u128`s, checking up to an upper bound of 9999999999999999999999 to check all numbers up to 22 digits if you want to be really sure, achieving a much more tragic time of 377064379625 ns, or 377064 ms, or 377 secs.

This project helped me learn about the importance of
- benchmarking: many optimizations that I was sure would lead to speedups made no difference or made the program slower
- just looking at a dataset and using your brain to try and find patterns

The code, with somewhat reasonable commit messages, lives #link("https://github.com/Ashwagandhae/disarium/")[on Github].
