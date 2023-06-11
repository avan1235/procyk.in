---
title: Advent of Code 2021 in Kotlin - Day 2
description: Today we discuss functional approach of standard library in Kotlin

date: "2021-12-02T00:00:00Z"

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

The [Day 2](https://adventofcode.com/2021/day/2) problem can be solved in pretty straightforward way, but
let's try to express our solution in the way, that would make the code most readable in functional style.

## Quick notes

In my solution I wanted to focus on the functional coding style in Kotlin and the well known from functional
languages function `fold` which can be seen as `foldLeft` function from other languages. Its role is to
iterate over the specified collection of items, using some accumulator to hold the current result and return
this result at the end.

In my opinion, if you don't understand what's the purpose of some function from standard library, the easiest
approach is to look into its source to analyze its behavior (what can be easily done with `Ctrl + B` shortcut
in Intellij). Let's see then at the definition of `fold`

```kotlin
inline fun <T, R> Iterable<T>.fold(init: R, f: (acc: R, T) -> R): R {
  var acc = init
  for (element in this) acc = f(acc, element)
  return acc
}
```

which now should be obvious how it works. If you have problem with seeing the way of applying it, you should
think what is actually your _current result_ (represented by `acc`) and how you extend this current value to
the state after processing one more element from collection (which is realized with transformation `f`).

It needs some time to get used to such approach, but you get some benefits with it - your code becomes more
declarative and expresses your intention directly, because you write only what's the initial state and how to
transform current state to the next one, and the whole processing is done with your transformation.

What's worth mentioning here is the `inline` keyword before this and many, many more functions from standard
library in Kotlin - this code compiled and disassembled can be seen as old-style loop over items that you
probably would write in place of calling the `fold` - so we get this readability in our cost with no
overhead for performance in execution 😍.

## Solution

The solution to the problem was implemented according to the description oof the task -
the code is more readable thanks to using `sealed interface Cmd` that we parse only once (with `fun String.cmd()`) and
then use as typed value.

The whole logic is contained in single `when` expression that allows us to define 
mentioned transformation of current result. As an accumulator we keep the values `(x, y)` or
`(x, y, aim)` and accordingly transform them.

### [Day2.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day2.kt)
```kotlin
object Day2 : AdventDay() {
  override fun solve() {
    val commands = reads<String>()?.map { it.cmd() } ?: return
    commands.calcPosition().run { first * second }.printIt()
    commands.calcAimedPosition().run { first * second }.printIt()
  }

  private fun List<Cmd>.calcPosition() = fold(Pair(0, 0)) { (x, y), (dir, v) ->
    when (dir) {
      Forward -> Pair(x + v, y)
      Down -> Pair(x, y + v)
      Up -> Pair(x, y - v)
    }
  }

  private fun List<Cmd>.calcAimedPosition() = fold(Triple(0, 0, 0)) { (x, y, a), (dir, v) ->
    when (dir) {
      Down -> Triple(x, y, a + v)
      Up -> Triple(x, y, a - v)
      Forward -> Triple(x + v, y + a * v, a)
    }
  }
}

private data class Cmd(val dir: Dir, val v: Int)
private sealed interface Dir
private object Forward : Dir
private object Up : Dir
private object Down : Dir

private fun String.cmd() = split(" ").takeIf { it.size == 2 }?.let { (dir, v) ->
  when (dir) {
    "forward" -> Cmd(Forward, v.toInt())
    "up" -> Cmd(Up, v.toInt())
    "down" -> Cmd(Down, v.toInt())
    else -> throw IllegalArgumentException("Unknown direction specified in data: $dir")
  }
} ?: throw IllegalArgumentException("Invalid data format")
```

## Extra notes

It's worth seeing how we implement also the `fun String.cmd()` as it contains the standard library
function `takeIf` which in my opinion is pretty straightforward but not well-known among
developers because we don't have a lot of other languages with similar constructs. Using
it brings no overhead too but makes the code more declarative and allows chaining functions'
calls in multiple situations.

Additionally, let's notice that we defined the `data class Cmd` which is destructured in `fold`
transformation as `(dir, v)` - that's one of beauties of `data classes` that we should not forget
about and don't worry about introducing new, local types for such transformations.
