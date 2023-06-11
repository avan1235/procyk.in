---
title: Advent of Code 2021 in Kotlin - Day 22
description: Define a lot of cool `infix fun` for Kotlin ranges to deliver more concise solutions.

date: "2021-12-22T00:00:00Z"

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

The [Day 22](https://adventofcode.com/2021/day/22) problem is the next example of problem that is strictly
divided in two parts, that seems to be identical but requires much different solutions. In the first part
we can start with naive implementation which is good as the considered space is limited but in the second
part we have to come up with some smarter approach. Let's see the idea behind and the cool implementation
in Kotlin.

## Solution

For the first part we prepare straightforward solution which keeps all the cubes in space separately, as
their number is limited by task description (i.e. it can be at most $101^2$). So for every `Step` we
take care only about the `Cube`s from limited range and add them or remove from current collection.

However, in the second part this approach is too naive. That's because the sizes of the added and removed
cubes are really huge, so adding individual `Cube`s in space would take too much time and memory.

After some time of thinking about the solution, we can come up with the approach of inserting 3D ranges
to reactor, so instead of keeping information about individual cubes, we keep the groups of them.

The hardest part of the solution is to implement the difference of `Range3D` that we represented as
a triple of `IntRange`. To do that, we provided a few helper infix function that makes checking relative
position of ranges easier. In my opinion, the hardest part was the proper implementation of
`operator fun IntRange.minus(r: IntRange)` that is later used in `operator fun Range3D.minus(r: Range3D)`.
The main idea behind this approach is to divide the considered `Range3D`s into 8 (or less) smaller pieces
and check which of them are in the result `Range3D`.

### [Day22.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day22.kt)
```kotlin
import kotlin.math.max
import kotlin.math.min

object Day22 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val steps = data.map { it.toStep() }

    LimitedReactor(limit = -50..50).apply { steps.forEach { execute(it) } }.size.printIt()
    Reactor().apply { steps.forEach { execute(it) } }.size.printIt()
  }
}

private fun String.toRange() = drop(2).split("..")
  .map { it.toInt() }.let { (f, t) -> f..t }

private fun String.toStep() = split(" ").let { (a, r) ->
  val (x, y, z) = r.split(",").map { it.toRange() }
  Step(Action.valueOf(a.uppercase()), Range3D(x, y, z))
}

private infix fun IntRange.limit(l: IntRange?) = l?.let { max(first, l.first)..min(last, l.last) } ?: this

private enum class Action { ON, OFF }
private data class Step(val action: Action, val range: Range3D) {
  fun cubes(l: IntRange? = null) = buildSet {
    for (xi in range.x limit l) for (yi in range.y limit l)
      for (zi in range.z limit l) add(Cube(xi, yi, zi))
  }
}

private data class Cube(val x: Int, val y: Int, val z: Int)
private class LimitedReactor(private val limit: IntRange) {
  private val on = hashSetOf<Cube>()
  val size get() = on.size

  fun execute(step: Step) = when (step.action) {
    Action.ON -> on += step.cubes(limit)
    Action.OFF -> on -= step.cubes(limit)
  }
}

private infix fun IntRange.outside(r: IntRange) = last < r.first || first > r.last
private infix fun IntRange.inside(r: IntRange) = first >= r.first && last <= r.last
private val IntRange.size get() = last - first + 1
private operator fun IntRange.minus(r: IntRange): Sequence<IntRange> = when {
  this inside r -> sequenceOf(this)
  r inside this -> sequenceOf(first..r.first - 1, r, r.last + 1..last)
  r outside this -> sequenceOf(this)
  last < r.last -> sequenceOf(first..r.first - 1, r.first..last)
  r.first < first -> sequenceOf(first..r.last, r.last + 1..last)
  else -> error("Not defined minus for $this-$r")
}.filter { it.size > 0 }

private class Reactor {
  private val on: HashSet<Range3D> = hashSetOf()
  val size get() = on.sumOf { it.size }

  fun execute(step: Step) = when (step.action) {
    Action.OFF -> on.flatMap { it - step.range }.toHashSet().also { on.clear() }
    Action.ON -> on.fold(hashSetOf(step.range)) { cut, curr -> cut.flatMap { it - curr }.toHashSet() }
  }.let { on += it }
}

private data class Range3D(val x: IntRange, val y: IntRange, val z: IntRange) {
  val size get() = x.size.toLong() * y.size.toLong() * z.size.toLong()

  operator fun minus(r: Range3D): Sequence<Range3D> =
    if (r outside this) sequenceOf(this)
    else sequence {
      for (x in x - r.x) for (y in y - r.y) for (z in z - r.z) yield(Range3D(x, y, z))
    }.filter { it inside this && it outside r }

  infix fun outside(r: Range3D) = x outside r.x || y outside r.y || z outside r.z
  infix fun inside(r: Range3D) = x inside r.x && y inside r.y && z inside r.z
}
```

## Extra notes

The whole solution takes advantage of defining many infix and operator functions for ranges.
Most of them are defined in order to get a simple way of calculating difference of many ranges.

When performing most of the operations on sets of ranges, we use the sequences to produce the values.
That's because there are many transformations done on these iterables so approach with sequences is
preferred. Building the sequences is in Kotlin as easy as building collections with `sequence { }`
builder or `sequenceOf()` function, so we definitely should consider using them in our code more
frequently.

We haven't mentioned yet in our discussions the getters' implementation in Kotlin. While usually
we define the field values with immediate initialisation like
```kotlin
val someField: FieldType = calculatedSomeFieldValue()
```
it might be not a good approach in multiple situations because the `calculatedSomeFieldValue` function
is called just on object initialisation.

One of the approaches here is to provide the getter implementation of the field, so it's values will
be calculated every time when the property is accessed. We can with simple expression definition like
```kotlin
val someField: FieldType get() = calculatedSomeFieldValue()
```
which can be also written as multiple statements, if some extra instructions are needed to calculate
result like
```kotlin
val someField: FieldType get() {
  val intermediateValue = calculatedSomeFieldValue()
  return valueTransformation(intermediateValue)
}
```
In both of these cases, the function calculating the field value is called every time when the field is
accessed. That's may take a lot of resources so sometimes the lazy approach is definitely preferred.
It can be used when the returned field value is known to be always the same, so it can be cached in
delegated property. It's enough to define such field as
```kotlin
val someField: FieldType by lazy { calculatedSomeFieldValue() }
```
Then, only at the first access of `someField` the `calculatedSomeFieldValue` is called. It's pretty
and short approach to get a really cool effect, so we should remember about it when defining
the fields in our classes (especially when they depend on some objects' state) 🤞.
