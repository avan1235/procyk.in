---
title: Advent of Code 2021 in Kotlin - Day 19
description: Let's learn new things about 3D space transformation and how we can combine them.

date: "2021-12-19T00:00:00Z"

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

In [Day 19](https://adventofcode.com/2021/day/19) we're given a problem that is mostly related to the transformations
in 3D space, including rotations and shifts of vectors. It's been fun but also a hard work to implement it in
Kotlin from basics in idiomatic way, so let's see what the final solution is.

## Solution

The approach to given problem is somehow straightforward as we try pairing each pair of scanners and remember
the transformations needed to go from one coordinates system to another. To do that, we remember a list of
transformations for each scanner, that is required to transform its coordinate system to the system of the first
scanner (collected in `transform` map). What's more important we also remember if we've already check, if there
is some relation between some pair of scanners (which is remembered in `triedToPair`). It's important not to
check multiple times for the same $\textnormal{fromId} \rightarrow \textnormal{toId}$ connection if there
was no transformation found in the past. It cannot be deduced only from `cahcedPair` map because it has no value
also if the pair was checked, and it was not found.

We search by starting from some `start` scanner that is the reference system and append next scanners, step by step,
by finding next matching pairs between scanner from `paired` and `toPair`. Notice that we've implemented the new
`hashCode` and `equals` to represent scanner by its `id`. This approach simplifies code a lot, so we don't have
to worry about indices when working with maps.

### [Day19.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day19.kt)
```kotlin
import V3.Companion.TRANSFORMS
import kotlin.math.absoluteValue

object Day19 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val scanners = data.groupSeparatedBy("") { it.toScanner() }

    val matcher = ScannersMatcher(scanners, minCommon = 12)
    val start = scanners.first()
    val (beaconsFromStart, positioned) = matcher.findPairing(start)

    beaconsFromStart.size.printIt()
    sequence {
      for ((s1, v1) in positioned) for ((s2, v2) in positioned)
        if (s1 != s2) yield(v1 - v2)
    }.maxOf { it.manhattanValue }.printIt()
  }
}

private class ScannersMatcher(val scanners: List<Scanner>, val minCommon: Int) {

  private data class FT(val from: Scanner, val to: Scanner)

  private val cachedPair = mutableMapOf<FT, V3.T>()
  private val triedToPair = DefaultMap<FT, Boolean>(false)

  fun findPairing(start: Scanner): Pair<Set<V3>, Map<Scanner, V3>> {
    val transform = DefaultMap<Scanner, List<V3.T>>(emptyList())
    val beacons = start.beacons.toMutableSet()
    val scan = mutableMapOf<Scanner, V3>().also { it[start] = V3.ZERO }

    val paired = mutableSetOf(start)
    val toPair = (scanners - paired).toMutableSet()

    while (toPair.isNotEmpty()) {
      search@ for (from in paired) for (to in toPair) {
        val pairedShift = tryPair(FT(from, to)) ?: continue
        transform[to] = transform[from] + pairedShift
        beacons += to.beacons.map { transform[to](it) }
        scan[to] = transform[to](V3.ZERO)
        to.also { paired += it }.also { toPair -= it }
        break@search
      }
    }
    return Pair(beacons, scan)
  }

  private fun tryPair(ft: FT): V3.T? {
    if (triedToPair[ft]) return cachedPair[ft]
    triedToPair[ft] = true
    for (t in TRANSFORMS) {
      val to = t(ft.to)
      val diffs = buildSet {
        for (fb in ft.from.beacons) for (tb in to.beacons) add(tb - fb)
      }
      for (diff in diffs) {
        val cnt = to.beacons.count { tb -> (tb - diff) in ft.from.beacons }
        if (cnt >= minCommon) return t.copy(shift = -diff).also { cachedPair[ft] = it }
      }
    }
    return null
  }
}

private fun List<String>.toScanner() = Scanner(
  first().removePrefix("--- scanner ").takeWhile { it.isDigit() }.toInt(),
  drop(1).map { it.toBeacon() }.toSet()
)

private fun String.toBeacon() = split(",").map { it.toInt() }
  .let { (x, y, z) -> V3(x, y, z) }

private data class V3(val x: Int, val y: Int, val z: Int) {
  data class T(val id: Int, val shift: V3)

  val manhattanValue = x.absoluteValue + y.absoluteValue + z.absoluteValue
  private fun axeRotated(id: Int) = when (id) {
    0 -> V3(x, y, z)
    1 -> V3(-y, x, z)
    2 -> V3(-x, -y, z)
    3 -> V3(y, -x, z)
    else -> error("Invalid axeRotate id")
  }

  private fun axeChanged(id: Int) = when (id) {
    0 -> V3(x, y, z)
    1 -> V3(x, z, -y)
    2 -> V3(x, -z, y)
    3 -> V3(x, -y, -z)
    4 -> V3(-z, y, x)
    5 -> V3(z, y, -x)
    else -> error("Invalid axeChanged id")
  }

  infix fun transformedBy(by: T) = axeChanged(by.id / 4).axeRotated(by.id % 4) + by.shift

  operator fun plus(v3: V3) = V3(x + v3.x, y + v3.y, z + v3.z)
  operator fun minus(v3: V3) = V3(x - v3.x, y - v3.y, z - v3.z)
  operator fun unaryMinus() = ZERO - this

  companion object {
    val ZERO = V3(0, 0, 0)
    val TRANSFORMS = (0..23).map { T(it, ZERO) }
  }
}

private class Scanner(val id: Int, val beacons: Set<V3>) {
  override fun equals(other: Any?) = (other as? Scanner)?.id == id
  override fun hashCode() = id
}

private operator fun List<V3.T>.invoke(v: V3) = foldRight(v) { t, v3 -> v3 transformedBy t }
private operator fun V3.T.invoke(s: Scanner) = Scanner(s.id, s.beacons.map { it transformedBy this }.toSet())
```

## Extra notes

We have used in the solution a few cool Kotlin features that are definitely worth mentioning. Let's look at the:
1. Definitions of `invoke` functions that are declared as operators for transformations of vectors. In this way
   we got some cool syntax to actually **applying** transformation to vector or scanner.
2. We encoded the transformation on vector as a number from range `0..23` which includes the rotation and the
   change of the `z` axe of the coordinate system. It was pretty hard to express it in some good way, so we decided
   to do it explicitly with writing all possible transformations by hand. If it's not readable, I encourage you
   to use your first 3 finger of your hand and see how these axes are transformed (that's what I did in fact).
3. Take a look at the `operator fun` defined for `V3` class representing the operations on vectors. They're
   somehow obvious, but we have to remember that it's convenient to define them as overloaded operators in Kotlin.
4. In the search of pair matches we used the named scope `search@` - in this way we can exit the outer loop
   in Kotlin (and other modern programming languages) and it somehow simplifies the code.
5. Once again we've used the builders methods that're new stable feature from Kotlin - building
   iterables with `buildSet { }` and `sequence { }` is really pleasant and straightforward.
