---
title: Advent of Code 2021 in Kotlin - Day 23
description: Find some another practical usage of Dijkstra algorithm in solving game.

date: "2021-12-23T00:00:00Z"

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

In the [Day 23](https://adventofcode.com/2021/day/23) problem we have to face up two hard parts. The first
includes reading data from really concise input and interpreting it, while the second is about
searching in some space of states that need to be generated on the fly. Let's see how we can deal with
these problems in Kotlin.

## Solution

We use the input map to get multiple information from it. The first (obvious one) is the location of
each amphipod on the map. We store them as the map from location `F` to the amphipod type. What we need
more to properly compute the state changes, are the positions to which the amphipod can move in
the specified move. To safe time in computation, we calculate some set of `spaces` and map `collides`.
The `spaces` keeps the coordinates of all fields, that can be occupied by an amphipod. The `collides` map
stores the information about the fields on the way from one field on map to another and the number of steps
required to move between these places. We calculate this map by doing some path traversal in
`scanPaths` function, that is capable of searching the graph of moves with remembering the paths' statistics
in `path`.

Having some `MapState` we can think of generating the next states from the given state. We implement this
in `MapState::reachable` by taking into account all the rules described in task. For example, we expressed
the rule of moving only from hallway to room or from room to hallway by writing
```kotlin
if (!(from.isHallway xor moveTo.isHallway)) continue
```
so we skip the situations in which we would move from hallway to hallway and from room to room.

Having these functions implemented, we can start searching for the smallest energy needed to get to
final state of the map. We use the _Dijkstra algorithm_ to solve this problem, but we have to take
care of the states that we generate from current, not final state, as in the current moment of `findMinEnergy`
we know only some part of all possible states (that we generated from the previously visited states).

### [Day23.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day23.kt)
```kotlin
import java.util.*
import kotlin.collections.ArrayDeque

object Day23 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val extraLines = listOf("  #D#C#B#A#", "  #D#B#A#C#")

    data.findMinEnergy(maxRow = 3).printIt()
    data.addExtraLines(extraLines, startFrom = 3)
      .findMinEnergy(maxRow = 3 + extraLines.size).printIt()
  }
}

private fun List<String>.addExtraLines(lines: List<String>, startFrom: Int) = buildList {
  this@addExtraLines.take(startFrom).forEach { add(it) }
  lines.forEach { add(it) }
  this@addExtraLines.drop(startFrom).forEach { add(it) }
}

private class WayDescription(val collides: Set<F>, val steps: Int)
private class MapDescription(val spaces: Set<F>, val collides: DefaultMap<F, DefaultMap<F, WayDescription>>)

private fun List<String>.toMapDescription(maxRow: Int): MapDescription {
  val map = DefaultMap<F, ModelField>(ModelField.Wall).also { map ->
    forEachIndexed { y, line ->
      line.forEachIndexed { x, c -> F(x, y, maxRow).also { map[it] = c.toModelField(it) } }
    }
  }
  val spaces = map.entries.filter { it.value == ModelField.Used }.mapTo(HashSet()) { it.key }
  val collides = spaces
    .associateWith { scanPaths(start = it, spaces - it, map) }
    .toDefaultMap(DefaultMap(WayDescription(emptySet(), steps = 0)))

  return MapDescription(spaces, collides)
}

private fun List<String>.toMapState(maxRow: Int) = buildMap {
  forEachIndexed { y, line ->
    line.forEachIndexed { x, c ->
      F(x, y, maxRow).takeIf { it.isFinalPlace }?.let { put(it, AmphiodType.valueOf("$c")) }
    }
  }
}.let { MapState(it) }

private fun scanPaths(start: F, positions: Set<F>, map: Map<F, ModelField>): DefaultMap<F, WayDescription> {
  val path = DefaultMap<F, WayDescription>(WayDescription(emptySet(), 0))
  val visited = hashSetOf<F>()
  val queue = ArrayDeque<F>().also { it += start }
  tailrec fun go(curr: F) {
    curr.also { visited += it }.neighbours()
      .filterNot { it in visited }
      .filter { map[it] == ModelField.Used || map[it] == ModelField.Space }
      .onEach { queue += it }
      .forEach {
        path[it] = WayDescription(
          if (curr in positions) path[curr].collides + curr
          else path[curr].collides,
          steps = path[curr].steps + 1
        )
      }
    go(queue.removeFirstOrNull() ?: return)
  }
  return path.also { go(start) }
}

private fun List<String>.findMinEnergy(maxRow: Int): Long? {
  data class Reached(val state: MapState, val energy: Long)

  val mapDescription = toMapDescription(maxRow)
  val mapState = toMapState(maxRow)

  val dist = DefaultMap<MapState, Long>(Long.MAX_VALUE).also { it[mapState] = 0 }
  val queue = PriorityQueue(compareBy(Reached::energy)).also { it += Reached(mapState, 0) }

  while (queue.isNotEmpty()) {
    val curr = queue.remove()
    if (curr.state.isFinal) return dist[curr.state]

    curr.state.reachable(mapDescription).forEach neigh@{ (to, energy) ->
      val alt = dist[curr.state] + energy
      if (alt >= dist[to]) return@neigh
      dist[to] = alt
      queue += Reached(to, alt)
    }
  }
  return null
}

private data class MapStateChange(val mapState: MapState, val energy: Int)

private data class MapState(val positions: Map<F, AmphiodType>) {
  val isFinal by lazy { positions.all { it.value.col == it.key.x } }
  val byX: LazyDefaultMap<Int, HashSet<AmphiodType>> by lazy {
    LazyDefaultMap<Int, HashSet<AmphiodType>>(::hashSetOf).apply {
      positions.forEach { (f, type) -> this[f.x] += type }
    }
  }

  fun reachable(mapDescription: MapDescription) = if (isFinal) emptySequence() else sequence {
    val freeSpaces = mapDescription.spaces - positions.keys
    for ((from, type) in positions) {
      val otherPositions = HashMap(positions).also { it -= from }
      for (moveTo in freeSpaces) {
        if (!(from.isHallway xor moveTo.isHallway)) continue
        if (from.isHallway && type.col != moveTo.x) continue
        if (moveTo.isFinalPlace && byX[moveTo.x].any { it != type }) continue
        if (from.isFinalPlace && from.x == type.col && byX[from.x].all { it == type }) continue

        val onWay = mapDescription.collides[from][moveTo]
        if ((onWay.collides - freeSpaces).isNotEmpty()) continue

        val updatedMap = MapState(HashMap(otherPositions).also { it[moveTo] = type })
        yield(MapStateChange(updatedMap, onWay.steps * type.energy))
      }
    }
  }
}

private enum class ModelField { Wall, Space, Used }
private enum class AmphiodType(val energy: Int, val col: Int) {
  A(1, 3), B(10, 5), C(100, 7), D(1000, 9)
}

private data class F(val x: Int, val y: Int, private val maxRow: Int) {
  val isHallway = y == 1
  val isFinalColumn = x in FINAL_COLUMNS
  val isFinalRow = y in 2..maxRow
  val isFinalPlace = isFinalRow && isFinalColumn

  fun neighbours() = sequenceOf(f(x + 1, y), f(x, y - 1), f(x - 1, y), f(x, y + 1))
  private fun f(x: Int, y: Int) = copy(x = x, y = y)

  companion object {
    private val FINAL_COLUMNS = AmphiodType.values().map { it.col }.toHashSet()
  }
}

private fun Char.toModelField(f: F) = when {
  this == '#' || this == ' ' -> ModelField.Wall
  f.isFinalColumn && f.isHallway -> ModelField.Space
  else -> ModelField.Used
}
```

## Extra notes

Let's take a look at the `data class F` that we defined for the field on the map. It's worth noticing how
`data class`es work in Kotlin. If we take a look at the bytecode generated for this class, we would see
such fragment
```java
public int hashCode();
  Code:
  0: aload_0
  1: getfield      #13                 // Field x:I
  4: invokestatic  #108                // Method java/lang/Integer.hashCode:(I)I
  7: istore_1
  8: iload_1
  9: bipush        31
  11: imul
  12: aload_0
  13: getfield      #16                 // Field y:I
  16: invokestatic  #108                // Method java/lang/Integer.hashCode:(I)I
  19: iadd
  20: istore_1
  21: iload_1
  22: bipush        31
  24: imul
  25: aload_0
  26: getfield      #19                 // Field maxRow:I
  29: invokestatic  #108                // Method java/lang/Integer.hashCode:(I)I
  32: iadd
  33: istore_1
  34: iload_1
  35: ireturn
```
that is a representation of `hashCode` method for this class. We can see here, that in case of `data class`es
the `hashCode`, as well as `equals`, `toString` and other generated method takes into account only the
fields that are a part of primary constructor of the class (so in this case `x`, `y` and `maxRow` fields) and
the other fields declared in class are not taken into account. The same applies to the inheritance from some other
classes - their fields will not be taken into account if we use `data class`es, so all the generated
methods will only consider the fields from constructor from `data class`. That's because this type
of classes is intended to use with no inheritance, so model some really simple data. We have to
have this in the back of our minds, not to make some unreal assumptions about the generated code.
