---
title: Advent of Code 2021 in Kotlin - Day 20
description: Implement processing infinite image processing infinite time, with attention to the boundary conditions.

date: "2021-12-20T00:00:00Z"

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

The [Day 20](https://adventofcode.com/2021/day/20) problem seemed to be quite straightforward at first sight
and the base can be passed here really quickly. The magic is in boundaries conditions of the task and the
given sample, that doesn't include such situation, so we have to deal with it on ourselves.


## Solution

To solve the problem of enhancing the image, we need some more information that the locations of lighten
pixel (that we store in `Image::enlighten` field). We need to take care of the current background
state, as **it can also change** during the enhancement. However, it can only change from
fully empty to fully filled with enlighten pixels, so it's enough if we remember only a `Boolean` flag
for this state in `fillInfty`.

It's not so obvious at first to include the infinity of image also in its computations, but it was definitely
the hardest part of this task (and to realize what's going on when base sample is working but the final
answer is wrong).

### [Day20.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day20.kt)
```kotlin
object Day20 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val algorithm = data.toAlgorithm()
    val image = data.toImage()

    image.enhance(algorithm, times = 2).enlighten.size.printIt()
    image.enhance(algorithm, times = 50).enlighten.size.printIt()
  }
}

private val Char.isLight: Boolean get() = this == '#'

private fun List<String>.toAlgorithm() = take(1).single().let { Image.Algorithm(it) }

private fun List<String>.toImage() = drop(2).flatMapIndexed { y, line ->
  line.mapIndexedNotNull { x, c -> if (c.isLight) Pixel(x, y) else null }
}.toSet().let { Image(it, fillInfty = false) }

private data class Pixel(val x: Int, val y: Int) {
  infix fun on(s: Image.Surface) = x in s.x && y in s.y
}

private class Image(val enlighten: Set<Pixel>, val fillInfty: Boolean) {
  private val surface = with(enlighten) {
    Surface(minOf { it.x }..maxOf { it.x }, minOf { it.y }..maxOf { it.y })
  }

  fun enhance(algorithm: Algorithm, times: Int) = (1..times)
    .fold(this) { img, _ -> img.enhanceStep(algorithm) }

  private fun enhanceStep(algorithm: Algorithm): Image = buildSet {
    for (x in surface.x + 1) for (y in surface.y + 1) Pixel(x, y).let {
      val encoding = encoding(it)
      val state = algorithm(encoding)
      if (state) add(it)
    }
  }.let { Image(it, if (fillInfty) algorithm(0b111111111) else algorithm(0b000000000)) }

  private fun encoding(p: Pixel) = sequence {
    for (yi in -1..1) for (xi in -1..1) yield(Pixel(p.x + xi, p.y + yi))
  }
    .map { if (it on surface) it in enlighten else fillInfty }
    .fold(0) { acc, b -> 2 * acc + if (b) 1 else 0 }

  private operator fun IntRange.plus(i: Int) = first - i..last + i

  class Surface(val x: IntRange, val y: IntRange)

  class Algorithm(data: String) {
    private val lightOn: Set<Int> = data
      .mapIndexedNotNull { idx, c -> if (c.isLight) idx else null }.toSet()

    operator fun invoke(x: Int) = x in lightOn
  }
}
```

## Extra notes

We used extension properties as well extension functions in our solution to make it more readable. For
example, it's more convenient to define the
```kotlin
private val Char.isLight: Boolean get() = this == '#'
```
if we check for this equality a few times in a file, and it can be precisely named. That's just a single line
that enables nice syntax like `c.isLight` instead of writing the symbol explicitly with `==`.

Notice also the definition of `infix fun on` for `Pixel` class that was later used in `encoding` method.
We can define such functions in Kotlin for every type and give them the names, which make reading code
more pleasant. Remember about that, when writing your libraries in Kotlin, just to give the developers
possibility to use infix notation for functions with single argument.

Once again, we should see and remember how the builders for collections in Kotlin can be used. Let's see that
the usage of `buildSet { }` contains just single nested instruction, while it is a nested `for` loop with the
`let { }` usage on pixel - it's really efficient approach of going through the image and building the new one
at the same time.

We came up with also some tricky local definition of extension function for `IntRange` that made it expand
in both directions by just writing
```kotlin
private operator fun IntRange.plus(i: Int) = first - i..last + i
```
Then, it was used to process the pixels from the border in standard loop by iterating like
```kotlin
for (x in surface.x + 1) for (y in surface.y + 1)
```
This kind of approach is really cool and removes a lot of code repetitions, but we need to define them
usually with private visibility, as they might have been understood differently in different contexts, e.g.
we could have also
```kotlin
private operator fun IntRange.plus(i: Int) = first..last + i
```
or even
```kotlin
private operator fun IntRange.plus(i: Int) = first + i..last + i
```
so always remember to make sure, that the other developers will understand what you meant or just forbid
using your definitions outside your world, to make code safe 😉.
