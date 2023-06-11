---
title: Advent of Code 2021 in Kotlin - Day 4
description: Let's create some generic helper functions for dealing with data that will help us with this and probably future Advent Days 😎.

date: "2021-12-04T00:00:00Z"

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

The [Day 4](https://adventofcode.com/2021/day/4) problem describes the simulation of [Bingo game](https://en.wikipedia.org/wiki/Bingo_(American_version)).
While the rules of the game are widely known and the simulation of the game is not so hard, it turns out
that the main point of the solution is to efficiently parse and represent the given data, to come up with
some nice solution for the problem. Let's begin then with some useful Kotlin concepts and helper functions 😊.

## Helper functions

We define two main helpers that seems to be useful in the future tasks as they solve some general problems
in pretty efficient way.

### Transpose `List<List<T>>`

Flipping rows with columns of 2D array of list requires equal sizes of each row of data. We need to check
that before processing the collection and then the transpose of `List<List<T>>` can be written
in Kotlin in one simple line of code with no extra performance overhead - just generate new collection of
collections with lambdas that use the original collection in pretty straightforward way - flipping $x$ and
$y$ axes of values from matrix (i.e. `List<List<T>>`).

```kotlin
fun <T> List<List<T>>.transpose(): List<List<T>> {
    val n = map { it.size }.toSet().singleOrNull()
        ?: throw IllegalArgumentException("Invalid data to transpose: $this")
    return List(n) { y -> List(size) { x -> this[x][y] } }
}
```

### Group data separated by value

This transformation is usually required when the data is separated with empty lines and single group of lines
should be processed together. In today's task we're given a list of strings that represents the board games, but
every board is represented with multiple lines and separated with empty line from other boards.

We can try to implement such functionality with `Sequence<V>` builder that is later collected to `List<V>` in single
call. We use it because it allows to yield the result only at certain moments - in our case when the description of the
board finishes, and we have accumulated the description of the last board, we yield our current result.

Notice that we use some `var` to keep the current value of accumulated value that is later `yield` after
some transformation. It's worth mentioning here how the variables caught by lambda scopes works in Kotlin
as it's quite different from other languages - when we deal with mutable `var` it remains mutable in the
captured scope of the lambda and the assignments executed in scope of the lambda are visible outside.
It's **really useful technique** when we define some nested functions and don't want to pass its state
in the variable - we can just define it before function definitions and use later as it'd be given as function's
parameter.

What I've learned when writing this helper function is the restriction for the `yield` function calls that have to
be defined directly inside the `SequenceScope<T>`, so we cannot define some helper function inside the `sequence { }`
builder and use `yield` in it. One may ask then, why using `forEach` is then allowed here if it defines some lambda
function too? The answer is somehow surprising but didactic - this function is defined with `inline` modifier, so it's
translated to direct call of the code of the `for` loop (as stated in its definition). Remember then, that if you find
some unexpected pattern from top level perspective in your bytecode, it's probably caused by inlining a few functions'
calls definitions from standard library 😉.

```kotlin
fun <U, V> List<U>.groupDividedBy(
    separator: U,
    transform: (List<U>) -> V
): List<V> = sequence {
    var curr = mutableListOf<U>()
    forEach {
        if (it == separator && curr.isNotEmpty()) yield(transform(curr))
        if (it == separator) curr = mutableListOf()
        else curr += it
    }
    if (curr.isNotEmpty()) yield(transform(curr))
}.toList()
```

## Solution

We present some quite general solution that is not the post performant but seems to be one of the most readable
ones seen today. That's because we define some general function `simulateSelectingFirst` for a game that allows
to simply define the strategy for selecting winning board during the simulation.

Additionally, parsing the data lines has become really readable with created helper functions. We use them also for
transposing the data of the board to be able to check for bingo easily. The cost of checking for bingo is proportional
to size of the board but the boards are tiny. If we would like to implement this in more efficient way, we should count
marked values for each row and each column and check, if it's big enough for bingo.

### [Day4.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day4.kt)
```kotlin
object Day4 : AdventDay() {
  override fun solve() {
    val lines = reads<String>() ?: return
    val game = Game(lines.extractOrder(), lines.extractBoards())

    game.simulateSelectingFirst { board -> board.wins() }
      ?.let { (b, v) -> b.unmarkedValues().sum() * v }.printIt()

    val leftBoards = game.boards.toMutableSet()
    game.simulateSelectingFirst { board ->
      if (board.wins()) leftBoards -= board
      leftBoards.isEmpty()
    }?.let { (b, v) -> b.unmarkedValues().sum() * v }.printIt()
  }

  private fun List<String>.extractOrder() =
    firstOrNull()?.split(",")?.map { it.value<Int>() }
      ?: throw IllegalArgumentException("No order defined in data: $this")

  private fun List<String>.extractBoards() =
    drop(1).groupSeparatedBy("") { it.toBoard<Int>() }
}

private class Game<V>(val order: List<V>, val boards: List<Board<V>>) {
  fun simulateSelectingFirst(strategy: (Board<V>) -> Boolean): Pair<Board<V>, V>? {
    for (v in order) {
      boards.forEach { it.mark(v) }
      boards.firstOrNull(strategy)?.let { return Pair(it, v) }
    }
    return null
  }
}

private inline fun <reified V> List<String>.toBoard() = map { line ->
  line.splitToSequence("\\s+".toRegex())
    .filter { it.isNotBlank() }
    .mapTo(mutableListOf()) { it.value<V>() }
}.let { Board(it) }

private class Board<V>(private val values: List<List<V>>) {
  private val transposedValues = values.transpose()
  private val markedValues = mutableSetOf<V>()
  private val allValues = values.flatten()

  fun mark(value: V) = markedValues.add(value)
  fun wins() = values.rowWins() || transposedValues.rowWins()
  fun unmarkedValues() = allValues - markedValues

  private fun List<List<V>>.rowWins() =
    any { row -> row.all { it in markedValues } }
}
```

## Extra notes

Let's see how the `Board<V>` is represented in the solution. It contains a copy of values in transposed order
to check for the bingo as described above. What's more interesting , it contains some extension function
`fun List<List<V>>.rowWins()` that has access to the field of the class. In this way we define the function
that has to be called in the context of specified object (in this case this can only be `Board<V>` context
but the same context applies in DSL design in Kotlin). It's a gorgeous way of expressing some intentions
for functions when it can have a few contexts (so almost a few `this` receivers). You can read more about it
in [KEEP 259](https://github.com/Kotlin/KEEP/issues/259) discussion to see what cool features are going to
be introduced to Kotlin in some future releases 🙃.

