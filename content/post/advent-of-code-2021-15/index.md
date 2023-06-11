---
title: Advent of Code 2021 in Kotlin - Day 15
description: Let's try to implement Dijkstra algorithm in Kotlin to solve the next graph related problem from Advent.

date: "2021-12-15T00:00:00Z"

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

In [Day 15](https://adventofcode.com/2021/day/15) problem seems to be the hardest that we struggled with
so far. It's not so obvious at first sight, how it should be solved and the input data for the problem
is big enough to prevent us from creating brute-force solutions. Let's see then how can we approach this
problem and what are the hardest parts in its implementation.

## Solution

When solving the problem, we face two problems:
1. Proper graph representation
2. Designing algorithm for path finding

In the first part we need to represent properly the graph based on the input data. According to problem
description, we can see that our graph may be interpreted as nodes between adjacent cells from the
map, where the weights of the edges are the values from cells to which we enter. In this way, we
can find the shortest path (with the smallest sum of weights on edges) to get the solution for
given problem.

It's worth noticing that in the second part of the task we wouldn't need to repeat the structure
in graph, but modify the operations on graph representation in proper way. Unfortunately, such an
approach would lead us to the less readable code in place of some memory saving. That's why we
decided to keep the whole representation in memory. In this scenario, graph building process
was quite harder, as it required calculating all its nodes, but in the actual algorithm we didn't
have to worry about any graph representation.

Path finding algorithm for this problem is a straightforward application of _Dijkstra's algorithm_.
It can be described in natural way as follows:

> Let's consider two featured nodes $s, d \in N$ from graph $G(N, E)$. We keep the current shortest
> distance to every node from $s$ in $dist$. So at the beginning $dist(s) = 0$ and for $n \neq s$ we
> have $dist(n) = \infty$. We consider all nodes from $N$ and in current step we **extract**
> the node $u$ with the shortest path to $s$ in current time. Having that, we consider every its neighbour $n$ -
> we have to check, if current distance from $s$ to $n$ is not smaller than the distance from $s$ to $u$
> plus the weight of the edge between $u$ and $n$
>
> In this way we build the shortest path from $s$ to every node of the graph, so at the end we can
> just return the length of the shortest path to destination node $d$.

To be able to represent the **extraction** process efficiently, we use the `PriorityQueue` which orders
the nodes in it based on the distance of the node to $s$, which is stored in `dist` field of queue node `QN`.

### [Day15.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day15.kt)
```kotlin
import java.util.*

object Day15 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return

    data.toWeightedGraph(times = 1).shortestPathLength().printIt()
    data.toWeightedGraph(times = 5).shortestPathLength().printIt()
  }
}

private fun List<String>.toWeightedGraph(times: Int): WeightedGraph = map { line ->
  line.mapNotNull { it.digitToIntOrNull() }
}.let { data ->
  val m = data.first().size
  val n = data.size
  val md = m * times
  val nd = n * times

  LazyDefaultMap<N, MutableList<E>>(::mutableListOf).also { adj ->
    for (x in 0 until md) for (y in 0 until nd)
      for ((tx, ty) in listOf(x + 1 to y, x - 1 to y, x to y + 1, x to y - 1)) {
        if (tx !in 0 until md || ty !in 0 until nd) continue
        val extra = (ty / n) + (tx / m)
        adj[x `#` y] += E(tx `#` ty, (data[ty % n][tx % m] + extra - 1) % 9 + 1)
      }
  }.let { WeightedGraph(md, nd, it) }
}

private data class N(val x: Int, val y: Int)
private data class E(val to: N, val w: Int)

private infix fun Int.`#`(v: Int) = N(this, v)

private class WeightedGraph(val m: Int, val n: Int, private val adj: Map<N, List<E>>) {

  fun shortestPathLength(source: N = 0 `#` 0, dest: N = m - 1 `#` n - 1): Long {
    data class QN(val n: N, val dist: Long)

    val dist = DefaultMap<N, Long>(0)
    val queue = PriorityQueue(compareBy(QN::dist))
    adj.keys.forEach { v ->
      if (v != source) dist[v] = Long.MAX_VALUE
      queue += QN(v, dist[v])
    }

    while (queue.isNotEmpty()) {
      val u = queue.remove()
      adj[u.n]?.forEach neigh@{ edge ->
        val alt = dist[u.n] + edge.w
        if (alt >= dist[edge.to]) return@neigh
        dist[edge.to] = alt
        queue += QN(edge.to, alt)
      }
    }
    return dist[dest]
  }
}
```

## Extra notes

We used some cool Kotlin features to implement the parsing process as well as the path finding algorithm, so
let's take a look to code one more time with details.

We decided to define some `infix fun` that is capable of creating nodes of graph. In Kotlin, we can define
this kind of function for any type, the only restriction is the number of parameters of such functions
that has to be equal to 1. It gives us the possibility to design some cool API, as the presented `#` for
building graph nodes with 2 coordinates.

In Dijkstra implementation we used the named lambda `neigh` and the `return@neigh` statement. This approach
was better than traditional `continue` in `for` loop because `adj[u.n]` might have been null, based on the `Map<K, V>`
API (as would need extra care with `?: emptyList()`). If you're new to such a syntax, then let's read the deep dive
into similar problem with `crossinline` from [Day 6](https://kotlin-dev.ml/post/advent-of-code-2021-6/) where this
construct was used without giving extra name to the scope - here we could also write `return@forEach`
but presented approach is more readable and fancy 😎.
