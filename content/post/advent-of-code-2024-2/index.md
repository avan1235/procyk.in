---
title: Advent of Code 2024 in Kotlin - Day 2
description: Feel the beauty of old-school `for` with `if` loops

date: "2024-12-02T00:00:00Z"

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

During the [Day 2](https://adventofcode.com/2024/day/2) the most important part was to quickly validate if
the input report is valid.
Let's check out how Kotlin allows writing imperative code and combine it with
functional approach easily.

## Solution

Based on the task description, we can define the following function to check if a single report is valid.

```kotlin
fun isReportValid(report: List<Long>): Boolean {
  val increase = report[1] >= report[0]
  for (idx in report.indices) {
    if (idx == 0) continue
    if (increase && report[idx] <= report[idx - 1]) return false
    if (!increase && report[idx] >= report[idx - 1]) return false
    if (abs(report[idx] - report[idx - 1]) < 1) return false
    if (abs(report[idx] - report[idx - 1]) > 3) return false
  }
  return true
}
```

This approach is so straightforward and readable that I personally don't want to find any
functional alternative to it.
Let's notice, it can be read line by line and while self-explaining itself at the same time:

1. check if the report is increasing or decreasing
2. iterate over all elements of the report, skipping the first one
3. for each element, compare it with the previous one and check if any condition for validity is violated:
    - if the whole report is increasing, it must increase for current two elements
    - if the whole report is decreasing, it must decrease for current two elements
    - the distance between two next elements must not be smaller than 1 nor greater than 3

Using such a helper function, we can count the valid reports for _Part One_ with standard library function
```kotlin
reports.count(::isReportValid)
```

During _Part Two_ we can notice that the input reports are quite short.
So for each of them we can try generating the versions of it with one
element removed and check if any of them is a valid report.

This can be achieved with simple utility function like

```kotlin
private fun <R> List<R>.withEachElementRemoved(): Sequence<List<R>> = sequence {
  for (removedIdx in indices) {
    yield(filterIndexed { idx, _ -> idx != removedIdx })
  }
}
```

that makes use of the Kotlin `Sequence<out T>` type and provide the following versions of
a caller list lazily.

Thanks to this behavior, we can avoid generating all versions of the report if we've already
found a valid version of the report.

```kotlin
reports.count { report ->
  isReportValid(report) || report.withEachElementRemoved().any(::isReportValid)
}
```
