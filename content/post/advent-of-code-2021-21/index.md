---
title: Advent of Code 2021 in Kotlin - Day 21
description: Let's see how using immutable data may simplify your computations and reasoning about written code.

date: "2021-12-21T00:00:00Z"

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

The [Day 21](https://adventofcode.com/2021/day/21) problem starts with a pretty simple and obvious part of
not random dice game, while in second part we have to think deeper how to efficiently simulate
multiple paths of quantum game that may appear. Let's see then how we can deal with both parts by working with
model built with immutable objects.

## Solution

We simulate the game with its immutable representation as `DiceGame` that holds points for both players and
the order of players to move. We added to it some helper methods `looser` and `winner` which are designed
to answer the question "Was the last moved player a looser/winner?" as we use them only after player moves.
We're able to transform such a game with some dice value by  creating a new instance of game with points
of player updated and players switched. As it is an immutable data, we used `fold` once again as in multiple
previous problems to simulate state change of such object.

In the second part, we have to count the worlds, in which players win. As the number of possible values of
dice is limited, we write them to `QUANTUM_DICE_SPLITS` for better readability of our intention.
The numbers on right represent on how many ways we have get every sum from left, when the possible
sums are listed in comment.

Then, the simulation of quantum game have to count the occurrences of each game instead of keeping them in
some collection. For example, instead of having a list with 42 the same games, we just remember the game
and its associated value that equals 42. We can update these values accordingly by multiplying the last
count by the number of worlds `splits`, in which current `dice` value appear by simply writing
```kotlin
updated[nextGame] = updated[nextGame] + splits * playing[game]
```
as we've used the `DefaultMap<DiceGame, Long>` once again for simpler problem representation.

### [Day21.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day21.kt)
```kotlin
object Day21 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val (p1, p2) = data.map { it.toPlayer() }

    simulateGame(p1, p2)?.let { (p, idx) -> p.points * idx }.printIt()
    simulateQuantumGame(p1, p2).maxOf { it.value }.printIt()
  }
}

private fun simulateGame(p1: Player, p2: Player): Pair<Player, Int>? {
  generateDiceNumbers().foldIndexed(DiceGame(p1, p2, toPoints = 1000)) { idx, game, dice ->
    game.move(dice).apply { looser()?.let { return Pair(it, 3 * (idx + 1)) } }
  }
  return null
}

private val QUANTUM_DICE_SPLITS = listOf(
  3 to 1, // 1+1+1
  4 to 3, // 1+1+2, 1+2+1, 2+1+1,
  5 to 6, // 2+2+1, 2+1+2, 1+2+2, 1+1+3, 1+3+1, 3+1+1
  6 to 7, // 1+2+3, 1+3+2, 2+1+3, 2+3+1, 3+1+2, 3+2+1, 2+2+2
  7 to 6, // 2+2+3, 2+3+2, 3+2+2, 3+3+1, 3+1+3, 1+3+3
  8 to 3, // 3+3+2, 3+2+3, 2+3+3
  9 to 1, // 3+3+3
)

private fun simulateQuantumGame(p1: Player, p2: Player): Map<Int, Long> {
  val playing = mapOf(DiceGame(p1, p2, toPoints = 21) to 1L).toDefaultMap(0)
  val winCount = DefaultMap<Int, Long>(0L)

  while (playing.isNotEmpty()) {
    val updated = DefaultMap<DiceGame, Long>(0)
    for (game in playing.keys) {
      for ((dice, splits) in QUANTUM_DICE_SPLITS) {
        val nextGame = game.move(dice)
        when (val winner = nextGame.winner()) {
          null -> updated[nextGame] = updated[nextGame] + splits * playing[game]
          else -> winCount[winner.idx] = winCount[winner.idx] + splits * playing[game]
        }
      }
    }
    playing.also { it.clear() }.also { it.putAll(updated) }
  }
  return winCount
}

private fun generateDiceNumbers() = generateSequence(0) { it + 1 }
  .map { it % 100 + 1 }.windowed(size = 3, step = 3) { it.sum() }

private fun String.toPlayer() = removePrefix("Player ").run {
  val idx = takeWhile { it.isDigit() }.toInt()
  val position = dropWhile { it.isDigit() }.removePrefix(" starting position: ").toInt()
  Player(idx, position, points = 0)
}

private data class Player(val idx: Int, val position: Int, val points: Long) {
  fun move(rolled: Int): Player = ((position - 1 + rolled) % 10 + 1).let { copy(position = it, points = it + points) }
}

private data class DiceGame(val now: Player, val last: Player, val toPoints: Long) {
  fun move(rolled: Int): DiceGame = copy(now = last, last = now.move(rolled))
  fun looser(): Player? = if (last.points >= toPoints) now else null
  fun winner(): Player? = if (last.points >= toPoints) last else null
}
```

## Extra notes

The process of generation next values of dice in the first part of problem could have been expressed in really
handy way, with the usage of sequences and `windowed` function of them. It's not the most performant approach
to this problem as we could define closed formula for these numbers, but as it was the first part of the
problem, single line solution with just
```kotlin
generateSequence(0) { it + 1 }.map { it % 100 + 1 }.windowed(size = 3, step = 3) { it.sum() }
```
was in my opinion the best fit here.

Notice, that in the solution of second part, we decided to use some local `updated` map, which is used to
store the current state of the playing games instead of modifying the `playing` map. We need to remember that
in case of Java collections (which are used in Kotlin), we cannot modify the collection when iterating over
its values. The `ConcurrentModificationException` is thrown, if we would try to do so. There are of course
different approaches to solve such problems, e.g. we can copy the collection to iterate over copy and modify
the original one or just iterate over original and modify it after iteration. The second approach seemed to
give more clear result in this solution and was fast enough, so we decided to apply it to our solution.


