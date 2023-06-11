---
title: Advent of Code 2021 in Kotlin - Day 8
description: Let's try to deduce numbers from data in natural and readable way using proper representation of today Advent of Code problem.
date: "2021-12-08T00:00:00Z"

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

The [Day 8](https://adventofcode.com/2021/day/8) problem is given with really long description that may frighten the reader at first.
It explains the definition of 7-segment display which is commonly used in electronics and how its segments are ordered.
What's more important, it contains also some hints how we can look at the problem and what should be done to
distinguish the digits from input.

## Solution

The first part of the problem is pretty straightforward so probably doesn't need extra explanation.

The second part needs some deeper deduction that may require some explanation. What we vat to find in
this part is to map the numbers shuffled representations to numbers (where all of them are shuffled in the
same manner).

As stated in the problem description, we can deduce which are 1, 4, 7 and 8 numbers as they are build with
the unique number of segments (respectively 2, 4, 3 and 7).

Next we can notice that the other numbers are built of 5 or 6 segments. So we can process every group
separately and try to deuce each number using some helper function `extract`.

```kotlin
fun MutableSet<Digit>.extract(by: Digit, diff: Int) =
      single { (it - by).segments.size == diff }.also { this -= it }
```

It takes the set of digits where all of them have the same number of segments and then finds the single digit for which, after removing
the segments from set `by`, the number of segments is equal to `diff`. After that it also modifies the set of
numbers by removing the returned digit from it.

First we notice, that for the numbers from group built of 5 segments when we remove the segments from 1, we will get
only one set of segments of size 3, and it will correspond to the rest of the digit 3. So we write that
```kotlin
val three = fiveSeg.extract(one, 3)
```
and then also notice that for the rest of the numbers from set `fiveSeg` if we remove the segments from 4, we will get only
one set of segments of size 3, that will correspond to the rest of digit 2, so we get
```kotlin
val two = fiveSeg.extract(four, 3)
```
and the only five segments digits that is left unprocessed is 5, so we can write
```kotlin
val five = fiveSeg.single()
```

The same process can be applied to the set of numbers that are built of 6 segments and we do it accordingly in code by
```kotlin
val sixSeg = seg[6]!!.toMutableSet()
val nine = sixSeg.extract(four, 2)
val six = sixSeg.extract(one, 5)
val zero = sixSeg.single()
```

In this way we found the whole encoding of the numbers that can be returned as the map from digit representation to
each of numbers from 0 to 9. Next, it's enough to use this mapping and decode the `outputs` from the entry.
We use `fold` here to calculate the number that is represented by the following digits - it's not only much faster than
working on strings or characters and calling the `toInt` function on the concatenated value, but also gives us
the ability to practice the `fold` usage in action 😉.

### [Day8.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day8.kt)
```kotlin
object Day8 : AdventDay() {
  override fun solve() {
    val positions = reads<String>()?.map { it.toDigitsEntry() } ?: return

    positions.sumOf { it.outputs.count(Digit::isEasy) }.printIt()
    positions.sumOf { it.decode() }.printIt()
  }
}

private fun String.toDigitsEntry() = split(" | ").map { part ->
  part.split(" ").map { Digit(it.toSet()) }
}.let { (input, output) -> DigitsEntry(input, output) }

private data class Digit(val segments: Set<Char>) {
  val isEasy = segments.size in setOf(2, 3, 4, 7)
  operator fun minus(o: Digit) = Digit(segments - o.segments)
}

private data class DigitsEntry(val inputs: List<Digit>, val outputs: List<Digit>) {
  fun decode(): Int = deduce().let { enc ->
    outputs.fold(0) { acc, dig -> 10 * acc + enc[dig]!! }
  }

  private fun deduce(): Map<Digit, Int> {
    val seg = inputs.toSet().groupBy { it.segments.size }
    val one = seg[2]!!.single()
    val four = seg[4]!!.single()
    val seven = seg[3]!!.single()
    val eight = seg[7]!!.single()

    fun MutableSet<Digit>.extract(by: Digit, diff: Int) =
      single { (it - by).segments.size == diff }.also { this -= it }

    val fiveSeg = seg[5]!!.toMutableSet()
    val three = fiveSeg.extract(one, 3)
    val two = fiveSeg.extract(four, 3)
    val five = fiveSeg.single()

    val sixSeg = seg[6]!!.toMutableSet()
    val nine = sixSeg.extract(four, 2)
    val six = sixSeg.extract(one, 5)
    val zero = sixSeg.single()

    return listOf(zero, one, two, three, four, five, six, seven, eight, nine)
      .zip(0..9).toMap()
  }
}
```

## Extra notes

Notice that we defined some `operator fun` for `Digit` class that is in Kotlin the implementation of
the [operator overloading](https://kotlinlang.org/docs/operator-overloading.html). We define the
subtract operation for this class as a difference of their sets of segments. In this way we can
express our intention in Kotlin code more efficiently, using usually more readable operator syntax
in different places, as we did in the definition of `extract` - it was so obvious what it is that
you could even not notice that it's an overloaded operator used in this place 😎.
