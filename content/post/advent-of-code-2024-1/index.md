---
title: Advent of Code 2024 in Kotlin - Day 1
description: Make a small warmup with reading input data and bringing some utility functions during the Day 1.

date: "2024-12-01T00:00:00Z"

image: featured.jpg

tags:
- kotlin
- advent-of-code-2024
- puzzle

categories:
- Code sample
- Advent of Code
---

## Introduction

We start with [Day 1](https://adventofcode.com/2024/day/1) for which the actual problem is usually about transforming input data
quickly, using the available library functions.

## Solution

After reading input data line by line, we can easily get the input like

```kotlin
val data = listOf(
  listOf(3, 4),
  listOf(4, 3),
  listOf(2, 5),
  listOf(1, 3),
  listOf(3, 9),
  listOf(3, 3),
)
```

while what is needed to calculate actual answer is data in format like

```kotlin
val data = listOf(
  listOf(3, 4, 2, 1, 3, 3),
  listOf(4, 3, 5, 3, 9, 3),
)
val (fst, snd) = data
```

To achieve that, we can make use of the created utility function, which treats such a list of lists as a matrix and does the transpose operation on it.
This operation is about changing the indices of columns with the indices of rows, by simply remapping the data to new structure.

```kotlin
fun <T> List<List<T>>.transpose(): List<List<T>> {
  val n = map { it.size }.toSet().singleOrNull()
    ?: throw IllegalArgumentException("Invalid data to transpose: $this")
  return List(n) { y -> List(size) { x -> this[x][y] } }
}
```

Having data in such formats, we can easily provide answers for both parts of Day 1.

_Part One_ sums the absolute distances between pairs of numbers from each of the lists with the standard library utility functions

```kotlin
fst.sorted().zip(snd.sorted()).sumOf { (a, b) -> abs(a - b) }
```

while _Part Two_ is about counting the occurrences of each number in the second list and then making use of it to calculate
the expected score with simple call to `sumOf { ... }`.

In the same time we can make use here of the `DefaultMap<K, V>` defined in our [utilities' file](https://github.com/avan1235/advent-of-code-2024/blob/a4028358d3c85d5da4fd866df36eb717a8b00982/src/main/kotlin/Util.kt#L39).
Thanks to that approach, we can get the `0` count for each number that doesn't occur in the second list and get the answer with simple

```kotlin
val sndEachCount = snd.groupingBy { it }.eachCount().toDefaultMap(0)
fst.sumOf { sndEachCount[it] * it }
```



