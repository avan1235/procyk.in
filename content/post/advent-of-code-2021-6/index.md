---
title: Advent of Code 2021 in Kotlin - Day 6
description: Let's see how the proper representation of problem matters for the Day 6 problem and discuss the `crossinline` modifier in Kotlin.

date: "2021-12-06T00:00:00Z"

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

The [Day 6](https://adventofcode.com/2021/day/6) problem shows how important proper representation of problem is.
The natual way of solving this problem doesn't work in the second part as it would produce exponential size of data.
Let's see then how quickly this problem can be solved and how we can deal with immutable data in Kotlin.

## Solution

We define the `afterDay` function for `LanternFish` which returns fish after single day as new objects.
This approach is commonly used in functional programming, when dealing with immutable data - we don't
modify the internal state of objects, but instead we return some new objects with modified internal state.
In this way our code becomes more readable because we can assume immutability of the objects. The same
assumption is applied to `FishShoal` for its `afterDays` function. However, in this approach we have to use
`fold` function to write the simulation of shoal state (and not to use some additional local variable).

In our solution we keep counts of every "type" of fish in shoal using some internal map `counts`.
Instead of just keeping all fish on some list, we can notice that there is a limited number of types of
fish, because fish can have timer with only limited values. That's enough to solve this problem
efficiently and get the result in less than one second.

### [Day6.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day6.kt)
```kotlin
object Day6 : AdventDay() {
  override fun solve() {
    val shoal = reads<String>()?.singleOrNull()?.toFishShoal() ?: return

    shoal.afterDays(80).size.printIt()
    shoal.afterDays(256).size.printIt()
  }
}

private fun String.toFishShoal() = split(",").map { LanternFish(it.toInt()) }
  .groupingBy { it }.eachCount().mapValues { it.value.toLong() }
  .let { FishShoal(it) }

private data class LanternFish(private val timer: Int) {
  fun afterDay(): List<LanternFish> = when (val nextTimer = timer - 1) {
    -1 -> listOf(LanternFish(6), LanternFish(8))
    else -> listOf(LanternFish(nextTimer))
  }
}

private class FishShoal(val counts: Map<LanternFish, Long>) {
  val size = counts.values.sum()

  fun afterDays(days: Int = 1) =
    (1..days).fold(this) { shoal, _ -> shoal.afterDay() }

  private fun afterDay(): FishShoal = DefaultMap<LanternFish, Long>(0).also {
    counts.forEach { (fish, count) ->
      fish.afterDay().forEach { newFish -> it[newFish] = it[newFish] + count }
    }
  }.let { FishShoal(it) }
}
```

## Extra notes

Let's notice that it was only one day, and we used the `DefaultMap<K, V>` again in our code. That made my day -
it shows how useful was the definition of this helper and that it can be useful also in some future problems 😎.

What's worth noting here is the Kotlin way to express counting after grouping objects by som property (that was used
in `toFishShoal` definition). We can try to generalize that function as
```kotlin
inline fun <T, K> Iterable<T>.countGroupingBy(crossinline keySelector: (T) -> K) =
    groupingBy(keySelector).eachCount()
```
which can later be used for example as
```kotlin
listOf(1, 3, 4, 2, 2, 1).countGroupingBy { it }
```
in order to count the number of occurrences of object on list.
We should pay extra attention here to the `crossinline` modifier and understanding what it does in Kotlin code.

Well, it's stated in documentation that when the lambda parameter of the inline function is defined as `crossinline`,
then this parameter cannot use non-local returns. What that means in practice is we cannot use some `return` in the
`crossinline` lambda body that would cause jump out of some outer scope.

Using some good example, we can look at the definition of function from standard library, e.g.
```kotlin
inline fun <T> Iterable<T>.forEach(action: (T) -> Unit): Unit {
    for (element in this) action(element)
}
```
For this function, the `action` parameter is not defined as `crossinline` so there are two types of returns from action
allowed.

The first one is the local return that causes jumping out of the execution of the `action` lambda, so when we use it in the
following way
```kotlin
fun main() {
    listOf(1, 2, 3).forEach {
        if (it % 2 == 0) return@forEach
        println(it)
    }
    println("After forEach")
}
```
we can see printed out to the console
```shell
1
3
After forEach
```
because we jumped out from printing action for `it == 2`.

In the next situation when "standard" `return` instruction is used
```kotlin
fun main() {
    listOf(1, 2, 3).forEach {
        if (it % 2 == 0) return
        println(it)
    }
    println("After forEach")
}
```
we get
```shell
1
```
as program result in the stdout as we jumped out from the `main` for `it == 2`.

We can see with these examples that the second `return` caused jumping out of the `main` function, while `return@forEach`
finishes only execution of single `action`.

**If we used the `crossinline` modifier for `action` parameter, then the second construct would be forbidden.** Yes, that's
so simple and allows us to express our intention what the `action` should be capable of doing, when designing some functions.

I hope these examples show more clearly how this modifier works and when could be used in our code - it's somehow tricky
because it's hard to find a good example on the Internet but by playing with the language we can learn how it really works
and why it was introduced to the language ✌.

