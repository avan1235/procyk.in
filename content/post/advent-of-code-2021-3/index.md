---
title: Advent of Code 2021 in Kotlin - Day 3
description: Abstracting the problems parts may become complicated when the problem needs understanding the whole its content before trying to implement some smaller parts. Let's see how we deal with it in Day 3 of Advent of Code.

date: "2021-12-03T00:00:00Z"

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

The [Day 3](https://adventofcode.com/2021/day/3) problem seems to be quite harder than the previous ones as it
requires understanding the whole task before trying to implement the solution. Read the task description by
yourself and try to abstract the common functionalities from it to see, how hard this process can be at the
beginning.

## Solution

In both parts of the tasks we can see some similar transformations of input date when calculating required rates
and ratings. For calculating gamma rate and epsilon rate, as well as for calculating the $O_2$ rating and $CO_2$
rating we can notice that they can be abstracted with some predicate value that filters the counts of ones and zeros
on every position.

### [Day3.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day3.kt)
```kotlin
object Day3 : AdventDay() {
  override fun solve() {
    val numbers = reads<String>() ?: return
    val n = numbers.commonLength()

    val zerosOnes = numbers.countZerosOnes(n)
    val gammaRate = zerosOnes.calcRate { zeros, ones -> ones > zeros }
    val epsilonRate = zerosOnes.calcRate { zeros, ones -> ones < zeros }
    (gammaRate * epsilonRate).printIt()

    val o2Rating = numbers.calculateRating(n) { zeros, ones -> zeros <= ones }
    val co2Rating = numbers.calculateRating(n) { zeros, ones -> zeros > ones }
    (o2Rating * co2Rating).printIt()
  }

  private fun List<String>.commonLength() = map { it.length }.toSet().singleOrNull()
    ?: throw IllegalArgumentException("No common length for list of strings: $this")

  private fun List<String>.countZerosOnes(n: Int) = listOf('0', '1')
    .map { c -> List(n) { idx -> count { it[idx] == c } } }
    .let { (zeros, ones) -> zeros.zip(ones) }

  private fun List<Pair<Int, Int>>.calcRate(
    predicate: (Int, Int) -> Boolean
  ) = map { (zeros, ones) ->
    if (predicate(zeros, ones)) '1' else '0'
  }.joinToString("").toInt(radix = 2)

  private fun List<String>.calculateRating(
    n: Int,
    predicate: (Int, Int) -> Boolean
  ): Int = toMutableList().apply {
    for (idx in 0 until n) {
      if (size == 1) break
      val (zeros, ones) = countZerosOnes(n)[idx]
      val commonValue = if (predicate(zeros, ones)) '1' else '0'
      removeIf { it[idx] != commonValue }
    }
  }.single().toInt(radix = 2)
}
```

## Extra notes

When analyzing presented solution you can notice that it's not optimal in terms of time complexity of the
algorithm used. It's mainly because in the second part we use `countZerosOnes` function in every loop execution
to calculate number of zeros and ones for the remaining list of input binary numbers. We can do this because the
given dataset is not so huge (1000 lines of data) so even the quadratic solution would be good as the length
of the lines $n$ is pretty small. In my opinion that's the most important lesson form this task - think first
what is required for your solution and for what kind of data it's expected to work. Sometimes, it's better
to write more readable code that works slower instead of trying to get the best performance and make the code
not editable by others 🙈.
