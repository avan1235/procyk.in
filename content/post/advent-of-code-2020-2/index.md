---
title: Advent of Code 2020 in Kotlin - Day 2
description: Recall a few useful functions that you might not use for a long time.

date: "2021-10-06T00:00:00Z"

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

The [Day 2](https://adventofcode.com/2020/day/2) tasks seems to be pretty straightforward - we only need to check the
defined rules for given passwords according to task description. We will try to express the solution in pretty straightforward
way by recalling some less known Kotlin functions.

## Solution

We can present the whole solution in a few lines of code which use already defined `inline fun <reified T> String.value(): T`
in order to neatly convert input parts to actual numbers.

```kotlin
object Day2 : AdventDay() {
  override fun solve() {
    val defines = reads<String>() ?: return
    defines.count { it.isValidOld() }.printIt()
    defines.count { it.isValidNew() }.printIt()
  }
}

fun String.isValidOld(): Boolean {
  val parts = split(" ")
  val letter = parts[1][0]
  val range = parts[0].split('-').map { it.value<Int>() }
  return parts[2].count { it == letter } in range[0]..range[1]
}

fun String.isValidNew(): Boolean {
  val parts = split(" ")
  val letter = parts[1][0]
  val positions = parts[0].split('-').map { it.value<Int>() }
  val onFst = parts[2][positions[0] - 1] == letter
  val onSnd = parts[2][positions[1] - 1] == letter
  return onFst xor onSnd
}

```

## Worth noting

Let's deep dive into two snippets of this solution to improve our familiarity with Kotlin:

  1. Keyword `in` can be used not only to iterate over a loop, but also to check if the value belongs to something.
  Basically, we need to have `operator fun T.contains(element: U): Boolean` in order to be able to check if some
  value `u: U` belongs to some other value `t: T` by simply calling `u in t`. It's a great moment to remind the
  [Kotlin's documentation about operators](https://kotlinlang.org/docs/operator-overloading.html)
  and their usages - using them in our code can make it not only shorter
  but also more readable and easier to explain for non-programming people.
  2. Notice the usage of `xor` function in 2nd part of the solution. It's not common to see it in code from my perspective
  because it can be expressed e.g. as `(b1 && !b2) || (!b1 && b2)` with the standard operators, but we should remember
  the KISS rule and try to express our thoughts in the most readable way - it can be done with this pretty function
  in really neat way. Additionally, we can see some other functions predefined for `Boolean` like `and` or `not` and
  revisit the [Kotlin's documentation about infix notation](https://kotlinlang.org/docs/functions.html#infix-notation) -
  they allow creating really readable code with almost no extra overhead.


