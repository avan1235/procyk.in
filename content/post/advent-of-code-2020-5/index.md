---
title: Advent of Code 2020 in Kotlin - Day 5
description: Discuss functional programming approach in the context of numbers representation in binary system

date: "2021-10-11T00:00:00Z"

image: featured.jpg

tags:
- kotlin
- advent-of-code-2020
- puzzle

categories:
- Code sample
- Advent of Code
---

## Introduction

We can look at the [Day 5](https://adventofcode.com/2020/day/5) problem as on the binary definition of
seats numbers with predefined letters instead of `0`s and `1`s.

## Solution

By going through given seat definition as an iterable of characters, we can divide our predefined space range
into halves and that's what we start with by using `String.findPlace(): Int?`. The function returns `null` if
is impossible to define the place - the range of matching places has more than single element. It uses a helper
function `String.select` which is its actual implementation - it goes through the characters of given `String`
and selects the proper part of range, based on its arguments `low` and `high`.

```kotlin
object Day5 : AdventDay() {
  override fun solve() {
    val lines = reads<String>() ?: return
    val places = lines.mapNotNull { it.findPlace() }
    places.maxOrNull().printIt()
    places.findGap().printIt()
  }
}

fun String.findPlace(): Int? {
  val row = select(0, 127, 'F', 'B') ?: return null
  val col = select(0, 7, 'L', 'R') ?: return null
  return row * 8 + col
}

fun String.select(from: Int, to: Int, low: Char, high: Char): Int? = fold(Pair(from, to)) { (f, t), c ->
  when (c) {
    low -> Pair(f, (f + t) / 2)
    high -> Pair((f + t) / 2 + 1, t)
    else -> Pair(f, t)
  }
}.run { if (first == second) first else null }

fun List<Int>.findGap(): Int? = sorted().windowed(3)
  .firstOrNull { it[0] + 1 != it[1] || it[1] + 1 != it[2] }
  ?.let { if (it[0] + 1 != it[1]) it[0] + 1 else it[1] + 1 }
```

The first part is as easy as finding the biggest number of seat, which can easily by done with Kotlin extension function
`fun <T : Comparable<T>> Iterable<T>.maxOrNull(): T?`.

In the second part we need to find the gap in the seats numbering. In such problems it's usually a good idea to sort the
items that we are processing, as this costs only $O(n \log n)$ time, so it's not so much compared to $O(n)$ which is
required for input data processing. Having the seats sorted, finding a gap is as easy as finding a 3 elements window slice
for which elements $(x, y, z)$ it's not true that $x + 1 = y$ and $y + 1 = z$.

## Extra code comments

There are two things in the task solution that are worth mentioning:
1. We should remember of using the sequences when making multiple operations on iterables in Kotlin. In this example it
   isn't crucial but let's notice that this can be easily achieved with single call of extension function `fun <T> Iterable<T>.asSequence(): Sequence<T>`
   as most of the functions available for collections are also available for sequences.
2. It's worth mentioning how the `fold` function works and why it's used here. When we think about processing some data
   in a loop by iterating over it and holding accumulated value during that process, `fold` is usually the best way to
   express our intention. It can be simply defined for `Iterable<T>` as we find it in standard library
    ```kotlin
    fun <T, R> Iterable<T>.fold(init: R, process: (acc: R, T) -> R): R {
      var acc = init
      for (element in this) acc = process(acc, element)
      return acc
    }
    ```
    which originally it's defined as `inline` function, so this approach doesn't bring extra cost but
    makes our code more readable.

