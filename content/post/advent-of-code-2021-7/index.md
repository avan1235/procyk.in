---
title: Advent of Code 2021 in Kotlin - Day 7
description: Let's see some cool properties of sets of numbers that may be useful to increase performance of your algorithms.

date: "2021-12-07T00:00:00Z"

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

The [Day 7](https://adventofcode.com/2021/day/7) problem can be solved using bruteforce solution and searching
in all possible numbers to find the minimal amount of fuel needed. However, we would like to present some known
properties from statistics that can make our solution faster 😎.

## Solution

We're given a list of positions $X = \lbrace x_1, x_2, \ldots, x_n \rbrace$ for which we have to find some position $y_c$
according to the specified cost function $c$ that will minimize

$$\sum_{i=1}^{n} c(x_i, y_c)$$

so we can write that

$$y_c = \underset{x}{\textnormal{argmin}} \sum_{i=1}^{n} c(x_i, x)$$

In the first part we have to find the position $y_m$ that minimizes

$$\sum_{i=1}^{n} |x_i - y_m|$$

which is known to be minimized **by median value from** $X$ 😮.

That's it - we don't need to check all values from range $[ 0, \textnormal{max }X]$.
It's enough if your remember that property as it can be useful, while
proving it cannot be presented easily.

In the second part we have to find the position $y_a$ that minimizes

$$\sum_{i=1}^{n} \sum_{j=1}^{|x_i - y_a|} j = \sum_{i=1}^{n} \frac{|x_i - y_a| (|x_i - y_a| + 1)}{2}$$

I don't know how to minimize that sum directly, but for the purpose of the task I tried to minimize just the sum


$$\sum_{i=1}^{n} \frac{|x_i - y_a|^2}{2}=\sum_{i=1}^{n} \frac{(x_i - y_a)^2}{2}$$

for which we can calculate the derivative directly and compare it to $0$ to notice that this function
have its minimum for $y_m = \frac{1}{n} \sum_{i=1}^{n} x_i$ i.e.
the average of numbers from $X$.

It's enough in case of this problem to find such approximation of the solution
as we deal with natural numbers so changing value some number by $1$ is pretty small change so
it shouldn't change the final result - that's only my intuition, but it seems to work in case
of this problem as I have tested the solution, and I haven't found bad cases yet.

I hope these properties of numbers may be useful for you at some day 🤞.

### [Day7.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day7.kt)
```kotlin
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.floor

object Day7 : AdventDay() {
    override fun solve() {
        val positions = reads<String>()?.singleOrNull()
            ?.separated<Int>(by = ",") ?: return

        positions.median()
            .let { positions.absCost(it) }
            .printIt()

        positions.average()
            .let { sequenceOf(floor(it), ceil(it)) }
            .map { it.toInt() }
            .minOf { positions.incrCost(it) }
            .printIt()
    }
}

private fun List<Int>.absCost(from: Int) =
    sumOf { to -> abs(from - to) }

private fun List<Int>.incrCost(from: Int) =
    sumOf { to -> abs(from - to) * (abs(from - to) + 1) / 2 }

private fun List<Int>.median() = sorted()
    .run { (this[(size - 1) / 2] + this[size / 2]) / 2 }
```

## Extra notes

We introduced pretty new function for dealing with input data when solving this day problem.
```kotlin
inline fun <reified T> String.separated(by: String): List<T> =
    split(by).map { it.value() }
```
It is intended to use with named parameter - that's the convention partially introduced to Kotlin
that is quite popular in Swift and allows us to read code directly, e.g.
```kotlin
"1,2,3".separated<Int>(by = ",")
```
is simply seen as "`List` of `Int` separated by `","`" - keep this in mind when designing your api
in Kotlin to make it more readable in many cases 😉.
