---
title: Advent of Code 2021 in Kotlin - Day 14
description: Let's see how critical can be problem representation in your problem with some data structures.

date: "2021-12-14T00:00:00Z"

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

In [Day 14](https://adventofcode.com/2021/day/14) seems to be pretty straightforward when we read it for
the first time and try to implement brute-force solution. When it comes to running the same approach for
some larger data, it becomes impossible as may take exponential time and memory - let's see then how to
come up with some smarter solution 😉.

## Solution

We may try to represent the current state of the polymer as counts of every pair of consecutive letters
in polymer. We can do that because we are interested only in the occurrences of subsequences of size 2
in our polymer, **not in their order**. To build such a representation, we can use `windowed(2)` function
to iterate through the `String` that represents the polymer and count every type of subsequence.
Let's see that we need to remember also the first and the last character in polymer in our representation.
It's required in `Polymer::counts` - when we want to count the number of each character in polymer,
we count these characters in the counts of subsequences, **but** these subsequences are overlapping
and every almost every character in them is counted twice - apart from the first and the last characters
that we count manually with
```kotlin
this[first] = this[first] + 1
this[last] = this[last] + 1
```
At the end we need to divide the counts values by 2 (just with `mapValues { it.value / 2 }`) because of the
described representation.

It's worth noticing that in brute-force approach the data may grow exponentially as there may be even a
situation in which the length of polymer is almost doubled in single step (e.g. with `AAAA` and `AA -> B` we get
`ABABABA`). That's why we need to provide such a smart approach to this problem 😎.

### [Day14.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day14.kt)
```kotlin
object Day14 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return

    val polymer = data.firstOrNull()?.toPolymer() ?: return
    val rules = data.toInsertionRules()

    polymer.apply(rules, times = 10).stats().printIt()
    polymer.apply(rules, times = 40).stats().printIt()
  }
}

private fun String.toPolymer() = windowed(2).groupingBy { it }.eachCount()
  .mapValues { it.value.toLong() }.let { Polymer(it, first(), last()) }

private fun List<String>.toInsertionRules() = buildMap {
  this@toInsertionRules.drop(2).forEach { line ->
    line.split(" -> ").let { (from, to) ->
      put(from, listOf(from.first() + to, to + from.last()))
    }
  }
}.let { InsertionRules(it) }

private data class Polymer(val counts: Map<String, Long>, val first: Char, val last: Char) {

  fun apply(rules: InsertionRules, times: Int) = (1..times).fold(this) { p, _ -> rules(p) }

  fun stats() = counts().run { maxOf { it.value } - minOf { it.value } }

  fun counts() = DefaultMap<Char, Long>(0).apply {
    counts.forEach { (p, cnt) -> p.forEach { this[it] = this[it] + cnt } }
    this[first] = this[first] + 1
    this[last] = this[last] + 1
  }.run { mapValues { it.value / 2 } }
}

private data class InsertionRules(val change: Map<String, List<String>>) {

  operator fun invoke(polymer: Polymer): Polymer = DefaultMap<String, Long>(0).apply {
    polymer.counts.forEach { (pattern, count) ->
      (change[pattern] ?: listOf(pattern)).forEach { this[it] = this[it] + count }
    }
  }.let { polymer.copy(counts = it) }
}
```

## Extra notes

Notice that we defined the `operator fun invoke` for `InsertionRules`. It's one more and in my opinion
really nice operator in Kotlin that can be defined for any class. We can think of it as about applying
some class to the other e.g. in our class we **apply** `InsertionRules` **to** `Polymer` to get some
new `Polymer`. Then, taking `Polymer` and applying some rules many times to it can be defined in single
line with such a pretty syntactically code
```kotlin
fun apply(rules: InsertionRules, times: Int) = (1..times).fold(this) { p, _ -> rules(p) }
```
Keep in mind that this kind of `operator` exists in Kotlin especially when you design some libraries
as there are many cases in which such syntax look just 🆒 for other developers.

