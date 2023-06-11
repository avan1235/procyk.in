---
title: Advent of Code 2021 in Kotlin - Day 17
description: Take a look into Kotlin delegated properties when implementing efficient data parsing in Kotlin.

date: "2021-12-17T00:00:00Z"

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

In [Day 17](https://adventofcode.com/2021/day/17) brings us some physics simulation of free-falling probe
that has some initial velocity. Our goal is to properly write the rules of the described world and
look at the statistics from the simulations to get the problem solution. Let's see how we can deal with
it in Kotlin and why immutability rocks when performing some data transformations.

## Solution

We create the representation of current state of the world and use it as immutable data in simulation -
named `State`. It's the most common approach to create some function in immutable class that returns
this state after transformation as new object. The `step` method does all of this by transforming
some state to another, according to described rules in the problem.

We run the simulation for the whole range of initial velocities that makes sense to do. They are limited, as
target area is limited and time in our problem is discrete, so we have to worry only about the situations,
in which we have a chance to hit target area. The key observation here is

> The probe has no chance of hitting target area iff after single second it missed this area and is behind it.

As we know that after the first second the probe will be at distance $(v_x, v_y)$, we can set the ranges
for initial velocities to be smaller than the distances to target are, to make sure that we checked all
reasonable states in our simulations.

### [Day17.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day17.kt)
```kotlin
import kotlin.math.absoluteValue
import kotlin.math.sign

object Day17 : AdventDay() {
  override fun solve() {
    val data = reads<String>()?.singleOrNull() ?: return
    val targetArea = data.toTargetArea()

    val maxX = targetArea.x.maxOf { it.absoluteValue }
    val maxY = targetArea.y.maxOf { it.absoluteValue }

    targetArea.runSimulations(x = -maxX..maxX, y = -maxY..maxY).run {
      maxOf { state -> state.yHistory.maxOf { it } }.printIt()
      size.printIt()
    }
  }
}

private fun String.toTargetArea() = removePrefix("target area: x=").split(", y=")
  .map { rng -> rng.split("..").let { (from, to) -> from.toInt() directedTo to.toInt() } }
  .let { (x, y) -> TargetArea(x, y) }

private data class TargetArea(val x: IntProgression, val y: IntProgression) {
  fun runSimulations(x: IntRange, y: IntRange): List<State> {
    return buildList {
      for (vx in x) for (vy in y) simulate(vx, vy)?.let { add(it) }
    }
  }

  fun simulate(vx: Int, vy: Int): State? {
    var state = State(vx, vy)
    while (state.canReach(this)) {
      state = state.step()
      if (state.x in x && state.y in y) return state
    }
    return null
  }
}

private data class State(
  val vx: Int, val vy: Int,
  val x: Int = 0, val y: Int = 0,
  val yHistory: List<Int> = listOf(),
) {
  fun step() = State(
    x = x + vx,
    y = y + vy,
    vx = vx - vx.sign,
    vy = vy - 1,
    yHistory = yHistory + y,
  )

  fun canReach(targetArea: TargetArea) = when {
    vy < 0 && y < targetArea.y.first -> false
    vx == 0 && x !in targetArea.x -> false
    else -> true
  }
}
```

## Extra notes

Notice how do we store the history of `State` locations with some list structure. It's important to use
`List<T>` instead of `MutableList<T>` to make sure that the `State` is effectively immutable. That's one
of the rules that we have to always remember - all the fields of immutable classes have to be immutable,
not only final.

It's worth noticing that some cool properties from `kotlin.math` were used in presented solution. We have
used the `sign` value of number to simulate the drag on the probe with simple expression. Additionally, the
`absoluteValue` property was used to calculate the actual range of searching for our simulation.
