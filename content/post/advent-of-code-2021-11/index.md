---
title: Advent of Code 2021 in Kotlin - Day 11
description: Let's use the `LazyDefaultMap<K, V>` with small fixes to solve cute simulation of flashing octopus.

date: "2021-12-11T00:00:00Z"

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

The [Day 11](https://adventofcode.com/2021/day/11) problem requires form us writing some simulation of flashing
in described manner. We can implement this in some readable way by using custom data structures and
redefining some operators in Kotlin - let's begin and see how to express some complicated code in a few lines
of text.

## Solution

We defined the operators for modifying internal values of the map to get extra functionality by calculating
`posOf` i.e. the map from values to the positions where we can find every of them on the map. Thanks to this
function we can always ask about the places with energy equal to 10 (in constant time) and propagate the
energy from them in single `flash` execution.

Let's notice that we defined the `flash` function as `tailrec fun` so it is optimized by the compiler to standard
loop. We did that because it's usually more readable to see that was our intention when writing this code - we want
to mark current positions as `flashed`, then for every of them propagate the energy to its neighbours and then
try to `flash` again from the positions on which the `maxVal` appeared in current step of flashing.

It's worth mentioning also how we defined the `LazyDefaultMap<K, V>` (and modified `DefaultMap<K, V>`) when solving
this task. Now we ended up with the definition, that allows to compute the default value lazily, but also
it sets the computed value to the backing map. It seemed to be more reasonable approach as we think about the
value extracted from map as it would be in it - so when it's a mutable value, then after its modifications,
we should observe this modification in map.

```kotlin
class LazyDefaultMap<K, V>(
  private val default: () -> V,
  private val map: MutableMap<K, V> = HashMap()
) : MutableMap<K, V> by map {
  override fun get(key: K): V = map.getOrDefault(key, default()).also { map[key] = it }
}
```

Don't miss the definitions that uses `Sequence<T>` in today code - they both were defined to improve
code readability and keep the performance in my opinion - let me know what you think about such
"functional" approaching to the problems 😉.

### [Day11.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day11.kt)
```kotlin
object Day11 : AdventDay() {
  override fun solve() {
    val map = reads<String>()?.toEnergyMap() ?: return

    with(map.copy()) {
      (1..100).fold(0) { sum, _ -> sum + simulateStep() }.printIt()
    }
    with(map.copy()) {
      generateSequence(1, Int::inc).first { simulateStep() == 100 }.printIt()
    }
  }
}

private fun List<String>.toEnergyMap() =
  EnergyMap(maxVal = 10, map { line -> line.map { it.digitToInt() }.toMutableList() })

private data class Pos(val x: Int, val y: Int)

private data class EnergyMap(val maxVal: Int, private val values: List<MutableList<Int>>) {

  val indices = values.flatMapIndexed { y, row -> row.indices.map { Pos(it, y) } }
  private val posOf = LazyDefaultMap(::mutableSetOf,
    indices.groupBy { this[it] }.mapValues { it.value.toMutableSet() }.toMutableMap()
  )

  fun copy() = EnergyMap(maxVal, values.map { it.toMutableList() })
  operator fun get(p: Pos): Int = with(p) { values[y][x] }
  operator fun set(p: Pos, v: Int) {
    val newVal = v.coerceAtMost(maxVal)
    posOf[this[p]].remove(p)
    posOf[newVal].add(p)
    values[p.y][p.x] = newVal
  }

  fun neighbours(of: Pos) = sequence {
    for (x in -1..1) for (y in -1..1) yield(Pair(x, y))
  }
    .filterNot { (x, y) -> x == 0 && y == 0 }
    .map { (x, y) -> Pos(of.x + x, of.y + y) }
    .filter { it.isValid() }

  fun simulateStep(): Int {
    val flashed = mutableSetOf<Pos>()
    tailrec fun flash(flash: Set<Pos>) {
      flashed += flash
      flash.toList().forEach { pos -> neighbours(pos).forEach { this[it] = this[it] + 1 } }
      if (flash.isNotEmpty()) flash(posOf[maxVal] - flashed)
    }
    indices.forEach { this[it] = this[it] + 1 }
    flash(posOf[maxVal])
    indices.forEach { this[it] = this[it] % maxVal }
    return flashed.size
  }

  private fun Pos.isValid() = y in values.indices && x in values[y].indices
}
```

## Extra notes

Let's see that we solved each of the parts of the task on the copy of the input map. That's because the
map internal state is mutable (it changes during the simulation) but we need to have a fresh map when
trying to solve the second part of the problem.

We used `with` Kotlin construct here, that simplified our code and introduced the context of current copy of
`EnergyMap`. That's one of the really cool Kotlin constructs that is in fact an inline function, so it brings no
extra overhead on runtime while really simplifying our code.

Also in this day we introduced tests running with expected outputs of days. We used for it some tricky and
simple function
```kotlin
fun catchSystemOut(action: () -> Unit) = ByteArrayOutputStream().also {
  val originalOut = System.out
  System.setOut(PrintStream(it))
  action()
  System.setOut(originalOut)
}.toString()
```
which is capable of catching the `System.out` value and returning it as simple `String` (that is later cmopared
with the expected output in tests and Advent days are defined to print their solutions).
