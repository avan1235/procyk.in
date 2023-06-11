---
title: Advent of Code 2020 in Kotlin - Day 1
description: Make a small warmup with reading input data and transforming it properly and consider different approaches to Day 1.

date: "2021-10-05T00:00:00Z"

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

We start with [Day 1](https://adventofcode.com/2020/day/1) for which we can show two really different approaches and the final decision which one could be used
in production code should be made depending on the expected inputs for our program and the expected readability of the code
in our codebase.

## Brute force approach

We start with naive approach to solve the task and see that it's enough for our input data to get the proper answer in really short time.

```kotlin
object Day1 : AdventDay() {
    override fun solve() {
        val numbers = reads<Long>() ?: return
        numbers.solveFor2(2020).printIt()
        numbers.solveFor3(2020).printIt()
    }
}

fun List<Long>.solveFor2(sum: Long): Long {
    for (i in indices) for (j in indices)
        if (i != j && this[i] + this[j] == sum) return this[i] * this[j]
    throw IllegalStateException("Solution not found")
}

fun List<Long>.solveFor3(sum: Long): Long {
    for (i in indices) for (j in indices) for (k in indices)
        if (i != j && j != k && k != i && this[i] + this[j] + this[k] == sum) return this[i] * this[j] * this[k]
    throw IllegalStateException("Solution not found")
}
```
The problem is that the complexity of these approaches is $O(n^2)$ and $O(n^3)$. From my point of view this approach seems
to be the most readable despite maybe not being Kotlin idiomatic. We just wrote really concise and readable code that simply
solves our problem and get the answer.

## Smarter approach

Let's think about rephrasing our problem statement - maybe we should check if for any of input number $n$ there is some
other number that equals $2020 - n$. We can express this approach also with just a few lines of Kotlin code for the first
part of the task

```kotlin
fun List<Long>.solveFasterFor2(sum: Long): Long {
    val count = countOccurrences()
    return toSet().firstOrNull { n ->
        val rest = sum - n
        (rest != n && count[rest]!! > 0) || (rest == n && count[rest]!! > 1)
    }
        ?.let { it * (sum - it) }
        ?: throw IllegalStateException("Solution not found")
}
```

But what is needed for it to work we need to define `countOccurrences` function  with some pretty simple but really useful `DefaultMap` class
which could be used for future tasks too.

```kotlin
fun <T> Iterable<T>.countOccurrences(): DefaultMap<T, Long> = mutableMapOf<T, Long>().also { map ->
  forEach { map[it] = map.getOrDefault(it, 0) + 1 }
}.let { DefaultMap(0, it) }

class DefaultMap<K, V>(private val default: V, private val delegate: Map<K, V>) : Map<K, V> by delegate {
    override fun get(key: K): V? = delegate.getOrDefault(key, default)
}
```

Some similar but less readable approach can also be used to find the solution for 3 numbers - we will skip it anyway as
we already got our advent stars, and it's definitely enough advent coding for today.
