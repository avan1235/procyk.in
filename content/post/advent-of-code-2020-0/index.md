---
title: Advent of Code 2020 in Kotlin - Introduction
description: Let's make the preparation to the 2021 Advent of Code by solving the last year puzzles and creating proper event in calendar for this year not to forget about this event

date: "2021-10-04T00:00:00Z"

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

Last year I realized about the existence of great initiative that is the Advent of Code - but it was too late to do it on time.
So I left the event only looking for the defined tasks (also hearing about them at great YouTube channel
[Tsoding Daily](https://www.youtube.com/channel/UCrqM0Ym_NbK1fqeQG2VIohg) - look and subscribe, this guy does the job).

This year has to be different and I will do my best not to forget about it 😋.

But to be well-prepared for this event it's always a good strategy to look into the previous editions and try to
analyze some old tasks. I'd like to solve all of them as a part of this series of posts and try to do it in the most
Kotlin idiomatic approach but taking also performance into account.

The solutions will be published as a git repository after solving full series in order to simplify the
process of running them but for now focus on the ideas that can be presented with these small pieces of code.

## Solution template

One of the main rules in programming is **DRY** - don't repeat yourself. We try to rewrite our code to remove the repeated
parts and abstract its parts that can be reused. The main repeatable part of our solutions will be definitely the `AdventDay`
which will contains our solutions

```kotlin
sealed class AdventDay(private val readFromStdIn: Boolean = false) {

    abstract fun solve()

    inline fun <reified T> reads() = getInputLines()?.map { it.value<T>() }

    fun getInputLines() =
        if (readFromStdIn) generateSequence { readLine() }.toList()
        else this::class.java.getResource("/input/${this::class.java.simpleName}.in")
            ?.openStream()?.bufferedReader()?.readLines()
}

inline fun <reified T> String.value(): T = when (T::class) {
  String::class -> this as T
  Long::class -> toLongOrNull() as T
  Int::class -> toIntOrNull() as T
  else -> TODO("Add support to read ${T::class.java.simpleName}")
}
```

We use `sealed class` which can have subclasses definitions in the same compilation module and same package
as the sealed class. Using a few lines of code we can define the main entrypoint of our solutions which will
be capable of running all `AdventDay`s without explicitly specifying them - it'll be enough to inherit from our
`AdventDay` class and implement `solve` to see the solution on console output.

```kotlin
fun main() = AdventDay::class.sealedSubclasses
    .mapNotNull { it.objectInstance }
    .sortedBy { it::class.java.simpleName.removePrefix("Day").toInt() }
    .forEach {
        println("--- ${it::class.java.simpleName}")
        it.solve()
    }
```

Using this template we can create `object`s as the subclasses of the `AdventDay` in order to have the instance
of them always available and simply run our solution.
