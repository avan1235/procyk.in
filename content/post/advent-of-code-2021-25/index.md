---
title: Advent of Code 2021 in Kotlin - Day 25
description: Finish the Advent in a great style with the readable solution written in Kotlin with less than 100 lines of code.

date: "2021-12-25T00:00:00Z"

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

I was somehow afraid, that [Day 25](https://adventofcode.com/2021/day/25) will start with some really hard problem,
as it was the last day and the previous ones were probably one of the hardest days in this time. Happily,
we got a great present and the whole problem with proper representation in data was quite simple and didn't
even have a second part, so it didn't take a lot of time. Let's see how we can see this kind of problems to
efficiently manage the transformed data in readable way.

## Solution

The approach used in this day is quite similar to some previous days, where instead of
having some array of sea fields or the map from field to the type of the field, we store the sets of
the fields of each type, as there are only three of them `east`, `south` and `empty`.

With the sets' representation, all moves transformations are really easy, as they operate on some current sets'
values and don't require taking extra care about some intermediate state of the transformation. We could
even abstract some kind of partial step of transformation as separate function `moveGroup` that for some current
set of empty places and of the places of to move from, was able to generate the pair of these transformed sets
with just a few lines of code.


### [Day25.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day25.kt)
```kotlin
object Day25 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val sea = data.toSea()

    generateSequence(sea) { it.step().takeIf { update -> update != it } }.count().printIt()
  }
}

private fun List<String>.toSea(): Sea {
  val east = HashSet<Region>()
  val south = HashSet<Region>()
  val empty = HashSet<Region>()
  for ((y, line) in withIndex()) for ((x, c) in line.withIndex()) when (c) {
    '.' -> empty
    '>' -> east
    'v' -> south
    else -> error("Unknown input char: $c")
  } += Region(x, y)
  return Sea(east, south, empty, first().length, size)
}

private data class Region(val x: Int, val y: Int)

private data class Sea(
  val east: Set<Region>, val south: Set<Region>, val empty: Set<Region>,
  val xSize: Int, val ySize: Int,
) {
  fun step(): Sea {
    val (currEmpty, east) = moveGroup(empty, east) { east() }
    val (finalEmpty, south) = moveGroup(currEmpty, south) { south() }
    return copy(east = east, south = south, empty = finalEmpty)
  }

  private fun moveGroup(currEmpty: Set<Region>, moving: Set<Region>, move: Region.() -> Region) =
    HashSet(currEmpty).let { empty ->
      empty to moving.mapTo(HashSet()) { region ->
        region.move().takeIf { it in currEmpty }
          ?.also { empty -= it }
          ?.also { empty += region }
          ?: region
      }
    }

  private fun Region.east() = Region((x + 1) % xSize, y)
  private fun Region.south() = Region(x, (y + 1) % ySize)
}
```

## Extra notes

To implement the `moveGroup` function, we used the lambda with receiver parameter `move: Region.() -> Region`
to simulate the movement of given field. In Kotlin, we can use this kind of definitions, to get a better
syntax look and better experience, when using these functions. That's because they don't need specifying
the lambda argument, as it is a `this` object, for which we can call some method, e.g. in our code we just write
```kotlin
moveGroup(empty, east) { east() }
```
and the `east` method is called on some default `this` object in the specified context. We defined some extension
functions for these moves and located them in the `Sea` class to take advantage of the `Sea` context and
check for the size of the sea in the implementation of the method called on `Region`.
