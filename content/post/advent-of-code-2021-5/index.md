---
title: Advent of Code 2021 in Kotlin - Day 5
description: Revisit Kotlin delegated properties and ranges definitions when solving Day 5 puzzle.

date: "2021-12-05T00:00:00Z"

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

The [Day 5](https://adventofcode.com/2021/day/5) problem is the next one that can be really simple expressed using
object-oriented programming techniques. To solve it, we propose some tricky Kotlin definitions for helpers that
are really useful in the implementation of marking lines on the diagram.

## Helper definitions

### Generic `DefaultMap<K, V>`

We start with the pretty simple but really helpful definition of `DefaultMap` in Kotlin in just a few lines
```kotlin
class DefaultMap<K, V>(
    private val default: V,
    private val map: MutableMap<K, V> = HashMap()
) : MutableMap<K, V> by map {
    override fun get(key: K): V = map.getOrDefault(key, default).also { map[key] = it }
}
```
In this short definition we have realized the whole implementation of `MutableMap<K, V>` interface as most of the
functionalities are delegated to selected `map` that is a backing field in our implementation and can be customized
if needed. What we can do more is even creating some lazy generator for default values - it wasn't needed in today
problem so was not written in this way. Anyway, the most important thing is to notice and remember that in Kotlin
we don't need to implement some functionalities from implemented interfaces because we can delegate the implementation
to some specified objects that are able to realize given functionality with only single keyword `by`.

### Always working `IntProgression`

For standard ranges in Kotlin we have a restriction that it has to start on smaller value and finish on
bigger or equal (just because in other case it's empty). That makes a lot of sense when we define such
ranges statically, using some values for which the order is known at compile time. The same applies for
descending `IntProgression` that can be defined with `downTo` infix function.

In our case we don't know if we should use `rangeTo` (i.e. `..` operator) or `downTo` for points coordinates, so
we can define some small but really useful helper function that can be represented as `infix` function

```kotlin
infix fun Int.directedTo(o: Int) = if (this <= o) this..o else this downTo o
```

that returns not empty `IntProgression` for any pair of points.

## Solution

We represent the points and lines as `P` and `L` data classes for simplicity of code. They are quite readable
and allows us to keep the counts of marked points in `Map<P, Int>` because the `hashCode` and `equals`
implementation are automatically generated for data classes in Kotlin.

Moreover, in the implementation of diagram we use some baking field to count the marked points as `_m` and then
expose it as property of type `Map<P, Int>`. That's because in Kotlin the mutability of collections is checked at compile
time, based on their types, so in this way we can restrict mutability of `_m` outside of `Diagram`.

### [Day5.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day5.kt)
```kotlin
import kotlin.math.abs

object Day5 : AdventDay() {
  override fun solve() {
    val lines = reads<String>()?.map { it.toLine() } ?: return

    Diagram().apply {
      lines.filter { it.isVertical || it.isHorizontal }.forEach { markLine(it) }
      marked.count { it.value > 1 }.printIt()
    }
    Diagram().apply {
      lines.forEach { markLine(it) }
      marked.count { it.value > 1 }.printIt()
    }
  }
}

private data class P(val x: Int, val y: Int)
private data class L(val from: P, val to: P) {
  val isHorizontal = from.x == to.x
  val isVertical = from.y == to.y
  val isDiagonal = abs(from.y - to.y) == abs(from.x - to.x)
}

private fun String.toLine() = split(" -> ").map { p ->
  p.split(",").let { (x, y) -> P(x.toInt(), y.toInt()) }
}.let { (f, t) -> L(f, t) }

private class Diagram {
  private val _m = DefaultMap<P, Int>(0)
  val marked: Map<P, Int> = _m

  fun markLine(line: L) = with(line) {
    when {
      isVertical -> (from.x directedTo to.x).map { P(it, to.y) }
        .forEach { _m[it] = _m[it] + 1 }
      isHorizontal -> (from.y directedTo to.y).map { P(to.x, it) }
        .forEach { _m[it] = _m[it] + 1 }
      isDiagonal -> (from.x directedTo to.x).zip(from.y directedTo to.y)
        .map { (x, y) -> P(x, y) }
        .forEach { _m[it] = _m[it] + 1 }
      else -> Unit
    }
  }
}
```

## Extra notes

What's worth noting in this code too, are two usages of standard library `inline` functions i.e. `with` and
`apply`. Both of them are used to simplify the statements with removing all calls to `Diagram()` or `line` as they
become `this` receiver. As mentioned, these are the `inline` functions so this brings no overhead for execution -
it's just more readable code that allows use to simply select the methods called on some objects 😍.
