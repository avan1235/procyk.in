---
title: Advent of Code 2021 in Kotlin - Day 13
description: Discuss some basic transformations on 2D plane to get our origami puzzles ready for the Christmas 🎄.

date: "2021-12-13T00:00:00Z"

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

In [Day 13](https://adventofcode.com/2021/day/13) is focused on implementing the proper way of representing
folds of origami transparent cards that finally get some patterns on them. This task is quite easy when we
choose some simple (maybe not natural) representation of our card - let's see that in action.

## Solution

The first idea might be to represent the state as 2D array or map from points to value on the plane and try
to manipulate them. But it's worth noticing that it's enough if we remember only the dots positions on the plane.
That's because having them, we are able to create their equivalents on the other side of fold axe.

So having that, we're almost done - just find out how to find the new locations of the dots after some fold.
We consider only the case of x fold, as the second is analogous. When we want to fold the plane along x,
we see how far it is from the folding coord with `it.x - coord` and put it at that distance from
`coord` by defining the mirrored position as `coord - (it.x - coord)`.

### [Day13.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day13.kt)
```kotlin
object Day13 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return

    val paper = data.toPaper()
    val commands = data.toCommands()

    commands.firstOrNull()?.let { paper.fold(it) }?.dots?.size.printIt()
    commands.fold(paper) { p, cmd -> p.fold(cmd) }.printIt()
  }
}

private fun List<String>.toPaper() = takeWhile { it.isNotBlank() }.map { line ->
  line.split(",").map { it.value<Int>() }.let { (x, y) -> V2(x, y) }
}.let { Paper(it.toSet()) }

private fun String.toFoldCmd() = removePrefix("fold along ").split("=")
  .let { (axe, coord) -> FoldCmd(coord.toInt(), FoldAxe.valueOf(axe)) }

private fun List<String>.toCommands() = dropWhile { it.isNotBlank() }.drop(1).map { it.toFoldCmd() }

private data class V2(val x: Int, val y: Int)

private enum class FoldAxe { x, y }
private data class FoldCmd(val coord: Int, val axe: FoldAxe)

private data class Paper(val dots: Set<V2>) {

  fun fold(cmd: FoldCmd): Paper = with(cmd) {
    val (orig, mod) = when (axe) {
      FoldAxe.x -> dots.partition { it.x <= coord }.let { (left, right) ->
        Pair(left, right.map { it.copy(x = coord - (it.x - coord)) })
      }
      FoldAxe.y -> dots.partition { it.y <= coord }.let { (up, down) ->
        Pair(up, down.map { it.copy(y = coord - (it.y - coord)) })
      }
    }
    Paper((orig + mod).toSet())
  }

  override fun toString() = buildString {
    for (y in 0..dots.maxOf { it.y }) {
      for (x in 0..dots.maxOf { it.x }) {
        append(if (V2(x, y) in dots) '#' else '.')
      }
      appendLine()
    }
  }
}
```

## Extra notes

We used some quite new and pretty Kotlin function when writing this solution which are worth mentioning here.
It's `buildString { }` builder method that was stabilized not so long time ago. There are a few more builders in
Kotlin that can be used also for build the collections in that manner. For example, we can use also the
`buildList`, `buildSet` and `buildMap` to create these collections in similar manner, with the usage of loops and some
conditions.
