---
title: Advent of Code 2021 in Kotlin - Day 10
description: Revisit `foldRight` function applied in modified version of _Brackets Pairing_ problem.

date: "2021-12-10T00:00:00Z"

image: featured.jpg

featured: false
# Featured image

# Place an image named `featured.jpg/png` in this page's folder and customize its options here.

# image:
# caption: 'Image credit: [**Unsplash**](https://unsplash.com/photos/CpkOjOcXdUY)'
# focal_point: ""
# placement: 2
# preview_only: false

tags:
- kotlin
- advent-of-code-2021
- puzzle

categories:
- Code sample
- Advent of Code

---

## Introduction

The [Day 10](https://adventofcode.com/2021/day/10) problem is some modification of well known at Computer Science
studies problem called _Brackets Pairing_ for which we have to verify the given brackets expression.
It's valid if every type of parenthesis is closed after opening and the closing brackets matches the
opening brackets as in standard math expressions.

## Solution

We can easily solve this problem in linear memory using `Stack<Char>` structure to keep the characters
representing opened brackets in already processed expression. So we need to
1. Read current character
2. Check if it's opening or closing bracket
   - If it's an opening bracket, then push it to `stack` of history of characters
   - If it's a closing bracket, then pop the latest bracket from `stack`, find its `closed` alternative and check if
     it matches the current closing bracket

It's worth noticing that in `stack` we will always have only opening brackets as we push values to memory
only for them (so our `closed` property of `Char` will never fail here).

In the first part we want to process the characters from every line until we find a corruption in data
so not matching closed bracket. The `firstOrNull` seems to be the best choice here as it will stop searching
for character as soon as it finds first.

In the second part we need to find the lines that are partially invalid i.e. there is no corrupted data but
the data is unfinished. That means in our stack structure there will be left some brackets that were not matched
during the process. We need to go through them and from the end and calculate the score, according to given rules.
The simplest and most straightforward approach here is to use the `foldRight` extension function that
allows us to accumulate some value and update it when iterating over some data from **right to left** (so
from end to beginning).

It's worth noting here that in case of Kotlin, `foldRight` is almost identical to `fold` (i.e. `foldLeft`) function
because lists in Kotlin (and stacks too) are implemented as arrays, so we can iterate over them in any
direction with the same constant cost in memory. In functional programming languages lists are represented
usually as the head and the reference to the tail of the list - in such case processing lists from left to right
is also cheap, but from right to left needs from us to build the whole stack of calls on list elements
to get to the last element first and then to process the next elements in the reversed order.

### [Day10.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day10.kt)
```kotlin
import java.util.*

object Day10 : AdventDay() {
  override fun solve() {
    val lines = reads<String>() ?: return

    lines.sumOf { it.corruptedScore() }.printIt()
    lines.mapNotNull { it.completionScore() }.sorted().let { it[it.size / 2] }.printIt()
  }
}

private val OPEN = setOf('[', '{', '(', '<')
private val CLOSE = setOf(']', '}', ')', '>')

private val Char.closed: Char?
  get() = when (this) {
    '{' -> '}'
    '(' -> ')'
    '[' -> ']'
    '<' -> '>'
    else -> null
  }

private fun String.corruptedScore(): Int {
  val stack = Stack<Char>()
  val firstCorrupted = firstOrNull { c ->
    when (c) {
      in OPEN -> stack.push(c).let { false }
      in CLOSE -> stack.pop().closed != c
      else -> unknownBracket(c)
    }
  }
  return when (firstCorrupted) {
    ')' -> 3
    ']' -> 57
    '}' -> 1197
    '>' -> 25137
    else -> 0
  }
}

private fun String.completionScore(): Long? {
  val stack = Stack<Char>()
  for (c in this) {
    when (c) {
      in OPEN -> stack.push(c)
      in CLOSE -> if (stack.pop().closed != c) return null
      else -> unknownBracket(c)
    }
  }
  return stack.foldRight(0L) { c, sum ->
    5 * sum + when (c.closed) {
      ')' -> 1
      ']' -> 2
      '}' -> 3
      '>' -> 4
      else -> unknownBracket(c)
    }
  }
}

private fun unknownBracket(c: Char): Nothing =
  throw IllegalArgumentException("Unknown bracket: $c")
```

## Extra notes

It's worth noting how the `unknownBracket` function is implemented - it's return type is `Nothing` what
means in Kotlin that the control will never exit this function (function will return nothing) without
throwing an exception. It's the same way as the helper function `TODO` from standard library is defined.
```kotlin
inline fun TODO(): Nothing = throw NotImplementedError()
```
The purpose of such definition is to give the compiler the hint that it doesn't have to
take care of the value returned from the function (so also about the type of the value returned and
doesn't care about it when analyzing e.g. `when` expressions).
