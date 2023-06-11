---
title: Advent of Code 2021 in Kotlin - Day 1
description: Let's begin a 2021 Advent of Code and solve problems day by day - today start with small warmup.

date: "2021-12-01T00:00:00Z"

image: featured.jpg

tags:
- kotlin
- advent-of-code-2021
- puzzle

categories:
- Code sample
- Advent of Code
---

## Introduction

We start with [Day 1](https://adventofcode.com/2021/day/1) problem for which the solution is based on [the template
from the last year Advent of Code](https://kotlin-dev.ml/post/advent-of-code-2020-0/). Let's begin to
see some cool features of modern language - Kotlin 😎.

## Solution

We solve the problem in pretty straightforward way - we analyze the input data in windows of different sizes.
In the first part it's enough to analyze the windows of `size = 2` and count how many of them contains increase.

In the second part, we add extra step before counting the difference - we need to calculate the sums of windows
of `size = 3`. Then, the solution is the same as in the first part.


### [Day1.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day1.kt)
```kotlin
object Day1 : AdventDay() {
  override fun solve() {
    val depths = reads<Int>() ?: return
    depths.asSequence().countIncreases().printIt()
    depths.asSequence().countSumIncreases().printIt()
  }

  private fun Sequence<Int>.countIncreases() = windowed(size = 2)
    .count { (prev, curr) -> curr > prev }

  private fun Sequence<Int>.countSumIncreases(size: Int = 3) = windowed(size)
    .map { it.sum() }
    .countIncreases()
}
```

## Extra notes

Let's see that we used `Sequence<T>` when solving the problem. It's worth recalling that multiple operations
on items in iterables should be implemented with usage of sequences because only in this way we can use the
functional programming style and not cause the quadratic complexity of our solutions.

Also in `countIncreases` we could use the `zipWithNext` function, but it's not required because of the feature
of lists in Kotlin standard library. I want to recall that they can be destructured with `componentN()` functions as
`Pair<K, V>` and that's what we do in `(prev, curr) -> curr > prev` lambda definition. It's worth mentioning
that these `componentN()` functions can be defined also in our classes, so keep this in your mind when designing
some Kotlin library API that could benefit from using these constructs 😉.
