---
title: Advent of Code 2021 in Kotlin - Day 9
description: Discover the BFS and DFS search algorithms in Kotlin with `tailrec fun` implementation.

date: "2021-12-09T00:00:00Z"

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

The [Day 9](https://adventofcode.com/2021/day/9) problem requires from us searching through the defined heightmap. We
can make it using commonly known algorithms for searching graphs where our graph can be seen as the positions from the
map connected with each other if they are adjacent on map. Let's see then how to implement the DFS and BFS search
algorithms in Kotlin 🔍.

## Solution

In order to get the answer for the first part of the problem it's enough if for every position from our map, we filter
the positions that are the low points and sum the values from map on these positions increased by 1 as stated in problem
description.

For the second part, we define some useful `search` method that is capable of search the map in the DFS and BFS order.
Usually we would write these algorithms with some recursive function that calls itself in order to visit siblings nodes.

For example, in case of DFS search, we could define

```kotlin
fun dfs(from: Node, action: (Node) -> Unit = {}): Set<Node> {
  val visited = mutableSetOf<Node>()
  fun go(curr: Node) {
    visited += curr.also(action)
    neighbours(curr).filterNot { it in visited }.forEach { go(it) }
  }
  return visited.also { go(from) }
}
```

which would allow us to visit node, visit its first child, then the first child of first child etc. But we have to
remember that for bigger data such definition would not work (and wouldn't be really efficient)
because calling function `go` brings some extra cost in space and time.

In such cases we usually define the iterative version of these algorithms that from my perspective may be harder to
understand and keep clean in code. We could try to define such method in the following way

```kotlin
fun search(
  from: Node,
  type: SearchType = SearchType.DFS,
  action: (Node) -> Unit = {},
  edge: (Node, Node) -> Boolean = { _, _ -> true }
): Set<Node> {
  val visited = mutableSetOf<Node>()
  val queue = ArrayDeque<Node>().apply { add(from) }
  while (true) {
    val curr = when (type) {
      SearchType.DFS -> queue.removeLastOrNull() ?: break
      SearchType.BFS -> queue.removeFirstOrNull() ?: break
    }
    visited += curr.also(action)
    neighbours(curr).filter { edge(curr, it) && it !in visited }.forEach { queue += it }
  }
  return visited
}
```

where we see that the order of search depends on the order of removing elements from `queue`. You can look at it in the
following way:

- for DFS we inserted some sibling node to `queue` and the next node that we want to visit is this node so the last in
  the `queue` - let's remove then the last element from `queue` and start searching from it
  (you can know it as Last-In, First-Out or LIFO order)
- for BFS, at first we want to add all siblings of current node to the `queue` and then start searching from the first
  node that was inserted in the past - let's remove then the first element from `queue` and start searching from it
  (you can know it as First-In, First-Out or FIFO order)

In Kotlin, we don't have to use the `while` loop to express our intention of searching because it can be generated for
us by the compiler. If we want to stay with the "recursive" approach that seems to be more readable for more people and
have an efficient search algorithm, we can use the
`tailrec fun` in Kotlin in the following way:

```kotlin
fun search(
  from: Node,
  type: SearchType = SearchType.DFS,
  action: (Node) -> Unit = {},
  edge: (Node, Node) -> Boolean = { _, _ -> true }
): Set<Node> {
  val visited = mutableSetOf<Node>()
  val queue = ArrayDeque<Node>()
  tailrec fun go(curr: Node) {
    visited += curr.also(action)
    neighbours(curr).filter { edge(curr, it) && it !in visited }.forEach { queue += it }
    when (type) {
      SearchType.DFS -> go(queue.removeLastOrNull() ?: return)
      SearchType.BFS -> go(queue.removeFirstOrNull() ?: return)
    }
  }
  return visited.also { search(from) }
}
```

This definition will be translated to the loop as in previous example by Kotlin compiler, because all
exits from inner `go` method are the tail calls of this method. It's required that no transformation is
done on the result of recursive call of function to name it a **tail recursive function** and to optimize its calls.

### [Day9.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day9.kt)

```kotlin
object Day9 : AdventDay() {
  override fun solve() {
    val map = reads<String>()?.toMap() ?: return

    map.indices.asSequence()
      .filter { p -> map.neighbours(of = p).all { map[it] > map[p] } }
      .sumOf { map[it] + 1 }
      .printIt()

    map.indices.asSequence()
      .map { p -> map.search(from = p) { from, to -> map[from] < map[to] && map[to] != 9 } }
      .distinct().map { it.size }
      .sortedDescending().take(3)
      .fold(1, Int::times)
      .printIt()
  }
}

private fun List<String>.toMap() = Map(map { line -> line.map { it.digitToInt() } })

private data class Node(val x: Int, val y: Int)

private data class Map<V>(val heights: List<List<V>>) {

  val indices = heights.flatMapIndexed { y, row -> row.indices.map { Node(it, y) } }

  operator fun get(p: Node): V = with(p) { heights[y][x] }

  fun neighbours(of: Node) = with(of) {
    sequenceOf(
      Node(x + 1, y), Node(x - 1, y),
      Node(x, y + 1), Node(x, y - 1)
    ).filter { it.isValid() }
  }

  enum class SearchType { DFS, BFS }

  fun search(
    from: Node,
    type: SearchType = SearchType.DFS,
    action: (Node) -> Unit = {},
    visit: (Node, Node) -> Boolean = { _, _ -> true }
  ): Set<Node> {
    val visited = mutableSetOf<Node>()
    val queue = ArrayDeque<Node>()
    tailrec fun go(curr: Node) {
      visited += curr.also(action)
      neighbours(curr).filter { visit(curr, it) && it !in visited }.forEach { queue += it }
      when (type) {
        SearchType.DFS -> go(queue.removeLastOrNull() ?: return)
        SearchType.BFS -> go(queue.removeFirstOrNull() ?: return)
      }
    }
    return visited.also { go(from) }
  }

  private fun Node.isValid() = y in heights.indices && x in heights[y].indices
}
```

## Extra notes

Let's see how we defined the `fun Pos.isValid()`. It's a private function in the class `Map` which is an extension
of `Pos` class. Thanks to such approach we could call it without specifying the receiver explicitly, but rather
using `this` as implicit receiver. It's the most common approach to do this for private function because they all can be
called only inside the class implementation so the `this` receiver of outer class doesn't have to be defined explicitly.

Notice also the definition of `indices` property of our `Map` - it's a good practice to create functions and properties
that are similar to the definitions from the standard library (not only in Kotlin but Kotlin provides us really
consistent standard library naming).
