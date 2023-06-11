---
title: Advent of Code 2021 in Kotlin - Day 12
description: See what are the `value class`es and how to represent a graph structure in Kotlin.

date: "2021-12-12T00:00:00Z"

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

In [Day 12](https://adventofcode.com/2021/day/12) problem we are asked to fins all possible paths between
some nodes in graph with some extra restrictions. The given data that describes the graphs is quite small
because the problem of finding paths in graph is hard as there may be theoretically a lot of paths to be found.

## Solution

We solve given problem with DFS algorithm in which we keep track of the current list of visited nodes from
source. Additionally, we don't mark some nodes as visited when entering them because they can be visited
unlimited number of times.

We create an extra check to create common method for both parts of the problem so in the second we
just mark some flag that allows us to visit single node twice. Notice, how tricky can be Kotlin definitions
to make code more concise - we can write that
```kotlin
if (curr == to) currPath.also { reached += it }.also { return }
```
i.e. condition checking, modifying collection and returning in just single line of Kotlin code 😍.

We represent the graph in our approach as the map from node to the set of its adjacent nodes. To get such
representation we need to group our edges and their flipped copies by the first element.

### [Day12.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day12.kt)
```kotlin
object Day12 : AdventDay() {
  override fun solve() {
    val graph = reads<String>()?.toGraph() ?: return

    graph.allPaths(Cave("start"), Cave("end")).size.printIt()
    graph.allPaths(Cave("start"), Cave("end"), allowTwice = true).size.printIt()
  }
}

private fun List<String>.toGraph() = map { line ->
  line.split("-").map { Cave(it) }.let { (f, s) -> Pair(f, s) }
}.let { Graph(it) }

@JvmInline
private value class Cave(val name: String) {
  fun isBig() = name.any { it.isUpperCase() }
}

private class Graph(edges: List<Pair<Cave, Cave>>) {

  private val adj = (edges + edges.map { Pair(it.second, it.first) })
    .groupBy(keySelector = { it.first }, valueTransform = { it.second })
    .mapValues { it.value.toSet() }

  fun allPaths(from: Cave, to: Cave, allowTwice: Boolean = false): Set<List<Cave>> {
    val reached = mutableSetOf<List<Cave>>()
    fun dfs(curr: Cave, path: List<Cave>, visited: DefaultMap<Cave, Int>, canVisitAgain: Boolean) {
      val currPath = path + curr
      if (curr == to) currPath.also { reached += it }.also { return }

      val currVisited = if (curr.isBig()) visited else visited + (curr to visited[curr] + 1)
      adj[curr]?.asSequence()
        ?.filter { visited[it] == 0 || (canVisitAgain && visited[it] == 1) }
        ?.filterNot { it == from }
        ?.forEach { dfs(it, currPath, currVisited, if (visited[it] == 1) false else canVisitAgain) }
    }
    return reached.also { dfs(from, emptyList(), DefaultMap(0), allowTwice) }
  }
}
```

## Extra notes

See that we use some magical `value class` in this problem which is some new Kotlin construct that corresponds
to old `inline class`es. They have some similar properties as `data class`es as they have a lot of predefined
functions, but they can (and have to) have only a single field with some value (for now).

Basically, we can learn a lot about them from the [KEEP](https://github.com/Kotlin/KEEP/blob/master/notes/value-classes.md)
that introduced them to the language, but they were introduced because of a few reasons. They allow us
to create new types with no overhead in performance and memory. That means it's much more powerful than
introducing the `typealias` to our model. That's because defining
```kotlin
@JvmInline
value class Name(val value: String)
```
is much more powerful than having
```kotlin
typealias Name = String
```
because in the second situation we can mix `String` with `Name` while in the first we cannot.
Additionally, for `value class`es we can define extra functions that can be called only for them -
same as we would work with some custom type.

There is also a lot of effort in improving performance of such data, so we can read about Project
Valhalla in the [KEEP](https://github.com/Kotlin/KEEP/blob/master/notes/value-classes.md) description.
It describes also the possibility of optimizing the arrays of such created types, so they could be
as arrays of primitives in memory.
