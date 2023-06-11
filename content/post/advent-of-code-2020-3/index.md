---
title: Advent of Code 2020 in Kotlin - Day 3
description: Revisit Kotlin sequences concepts and `infix` functions again

date: "2021-10-07T00:00:00Z"

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

The [Day 3](https://adventofcode.com/2020/day/3) presents a problem of traversing in some regular way through the given
data structure. In our case it's just an ordered collections of `String`s that can be seen as a matrix of `char`s which
are traversed in 2 dimensions.

We have to check how many of the "trees" would we encounter during the walk over given structure.

## Solution

Traditionally, we begin with a code solution and the approach to problem becomes pretty straightforward - we simulate
all the steps of the walk and verify what's on our current position.

```kotlin
object Day3 : AdventDay() {
  override fun solve() {
    val lines = reads<String>() ?: return
    (3 to 1 steppedIn lines).printIt()
    listOf(
      1 to 1,
      3 to 1,
      5 to 1,
      7 to 1,
      1 to 2,
    )
      .map { it steppedIn lines }
      .fold(1L, Long::times)
      .printIt()
  }
}

infix fun Pair<Int, Int>.steppedIn(lines: List<String>): Int {
  val (x, y) = this
  return generateSequence(0, Int::inc)
    .takeWhile { it * y < lines.size }
    .count {
      val line = lines[it * y]
      line[(it * x) % line.length] == '#'
    }
}
```

## Personal thoughts

We can notice a few small features of Kotlin code that make it more pleasant to be read in this task's code snippet.

Notice first the usage of the created `infix fun` that was created with this approach only for the readability of the
code. It allowed us to write `3 to 1 steppedIn lines` which can be understood as
"make (3, 1) steps on the given map representation". It's even more readable when defined for the collection of different
steps that we execute for the second task.

More interesting part is the concept of `Sequence<T>` in programming languages. We should remember, that the sequence
is somehow different from collection, because it's processed lazily. It brings extra cost which is noticeable only when
the sequence is pretty small. Let's visit the [Kotlin sequences documentation](https://kotlinlang.org/docs/sequences.html)
to see great illustration of the approach to collections processing by sequences.

We should notice the possibility to work with sequences every time we process some more regular collection of data that
requires some modifications of its elements in separate steps. In this task, approach that uses sequences really simplifies
the solution code and allows us to express our intentions directly - simulate stepping down through the map **while** we
are still on the map and **count** the number of fields on which we see the `'#''`.

And finally, notice how the pair is destructured to its elements - it's quite common to use this feature for `Pair<T, U>`
or `Triple<T, U, V>` but we can use it for any class that has the proper `operator` implementation (see full description
in [Kotlin documentation](https://kotlinlang.org/docs/destructuring-declarations.html)) and the `data class`es offer
implementation to its components for free 🕶.


