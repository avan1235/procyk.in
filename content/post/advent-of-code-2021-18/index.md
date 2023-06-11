---
title: Advent of Code 2021 in Kotlin - Day 18
description: See how the tree representation may help in solving your problem.

date: "2021-12-18T00:00:00Z"

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

In [Day 18](https://adventofcode.com/2021/day/18) comes up with the problem the is described in a crazy way.
There is no tree structure mentioned in the description, however we can notice that this seems to be the best
structure to represent given data. Let's see how to do it in Kotlin.

## Solution

We represent the data specifically as binary tree, that can be `TreeParent` node with two children or
`TreeLeaf` that holds some number value. Because of the modifications that are going to happen on that
trees, we represent them as mutable data, not to copy too much of them if not needed.

Then we can see that concatenating trees is really simple - it requires only creating new node, making
it a parent for old parents and assigning all its children. Basically, it can be implemented as simply
as in `operator fun plus` for `TreeNode`. However, implementation of this function includes reduction of
the result, as described in problem description.

During the reduction we deal with two different types of events:
1. For **explodes** we need to find the first node that is at depth 4 or more and has two number children.
   This can be done with tree scanning with helper function `findToExpldde`. Its role is to go at least at
   depth 4 in tree and then return the left most parent that has both number children. Then, to implement the
   explosion functionality, we need to find the left and right siblings of these nodes in tree. We can find e.g.
   the right sibling by going up as long as we go only from right child, then take the right child of the node to which
   we came from left, and go left to find the right sibling of the starting node. We implemented this
   functionality with some pretty functions, that allows to select the directions of traversal like
   ```kotlin
   explode
     .goUpFrom { left }
     ?.left
     ?.updateOnMost({ right }) { it + leftValue }
   ```
   so don't require any code repetitions for symmetrical cases.
   The final exchange of node to zero is easy, as we have a reference to parent node, so we can change
   the child to `TreeLeaf` with value 0.
2. Also, the **split** functionality is pretty straightforward when we have a pointer to the parent node.
   So our task here is to find the first node with big enough value and exchange it with a node holding two
   values - e.i. the functionalities of `findToSplit` and `split` functions.

### [Day18.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day18.kt)
```kotlin
object Day18 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return
    val snailFish = data.map { it.toSnailFish() }

    snailFish.reduce { l, r -> l + r }.magnitude().printIt()
    sequence {
      for (l in snailFish) for (r in snailFish)
        if (l != r) yield(l + r)
    }.maxOf { it.magnitude() }.printIt()
  }
}

private sealed class TreeNode(var parent: TreeParent?) {
  abstract fun copy(with: TreeParent? = null): TreeNode
}

private class TreeLeaf(var value: Int, parent: TreeParent?) : TreeNode(parent) {
  override fun copy(with: TreeParent?) = TreeLeaf(value, with)
}

private class TreeParent(parent: TreeParent? = null) : TreeNode(parent) {
  lateinit var left: TreeNode
  lateinit var right: TreeNode
  override fun copy(with: TreeParent?) = TreeParent(with).also {
    it.left = left.copy(it)
    it.right = right.copy(it)
  }
}

private fun String.toSnailFish(): TreeNode = asSequence().run {
  fun Sequence<Char>.parse(parent: TreeParent? = null): Pair<TreeNode, Sequence<Char>> = when (first()) {
    '[' -> {
      val fish = TreeParent(parent)
      val (left, fstRest) = drop("[".length).parse(fish)
      val (right, sndRest) = fstRest.drop(",".length).parse(fish)
      Pair(fish.also { it.left = left; it.right = right }, sndRest.drop("]".length))
    }
    else -> Pair(TreeLeaf(first().digitToInt(), parent), dropWhile { it.isDigit() })
  }
  parse().let { (snailFish, _) -> snailFish }
}

private fun TreeNode.magnitude(): Long = when (this) {
  is TreeLeaf -> value.toLong()
  is TreeParent -> 3 * left.magnitude() + 2 * right.magnitude()
}

private operator fun TreeNode.plus(other: TreeNode) = TreeParent().also { parent ->
  parent.left = this.copy(parent)
  parent.right = other.copy(parent)
}.apply { reduce() }

private tailrec fun TreeNode.updateOnMost(
  select: TreeParent.() -> TreeNode,
  update: (Int) -> Int
): Unit = when (this) {
  is TreeLeaf -> value = update(value)
  is TreeParent -> select().updateOnMost(select, update)
}

private tailrec fun TreeParent.goUpFrom(select: TreeParent.() -> TreeNode): TreeParent? {
  val currParent = parent
  return if (currParent == null) currParent
  else if (currParent.select() == this) currParent.goUpFrom(select)
  else currParent
}

private fun TreeNode.leftFinalParent(): TreeParent? = when {
  this is TreeParent && left is TreeLeaf && right is TreeLeaf -> this
  this is TreeParent -> left.leftFinalParent() ?: right.leftFinalParent()
  else -> null
}

private fun TreeNode.changeTo(createNode: (TreeParent?) -> TreeNode) = when {
  parent?.right == this -> parent?.right = createNode(parent)
  parent?.left == this -> parent?.left = createNode(parent)
  else -> Unit
}

private fun TreeLeaf.split() = changeTo { parent ->
  TreeParent(parent).apply {
    left = TreeLeaf(value / 2, this)
    right = TreeLeaf(value / 2 + value % 2, this)
  }
}

private val TreeParent.leftValue: Int get() = (left as? TreeLeaf)?.value ?: 0
private val TreeParent.rightValue: Int get() = (right as? TreeLeaf)?.value ?: 0

private fun TreeNode.reduce() {
  fun TreeNode.findToExplode(level: Int): TreeParent? = when {
    level == 0 -> leftFinalParent()
    level > 0 && this is TreeParent ->
      left.findToExplode(level - 1) ?: right.findToExplode(level - 1)
    else -> null
  }

  fun TreeNode.findToSplit(): TreeLeaf? = when (this) {
    is TreeLeaf -> if (value > 9) this else null
    is TreeParent -> left.findToSplit() ?: right.findToSplit()
  }

  while (true) {
    val explode = findToExplode(level = 4)
    if (explode == null) findToSplit()?.split() ?: break
    else explode.run {
      goUpFrom { left }?.left?.updateOnMost({ right }) { it + leftValue }
      goUpFrom { right }?.right?.updateOnMost({ left }) { it + rightValue }
      changeTo { parent -> TreeLeaf(0, parent) }
    }
  }
}
```

## Extra notes

Firstly, we need to notice that `operator fun plus` for `TreeNode` copies the added nodes. That's because
during the addition process they are reduced so they content may change. However, we need them unchanged in
the second part of the task, so coping in this single place was needed.

It's wort noticing how we implemented a few helper functions, that deal with tree structure. Let's see that
a few of them are defined as tail-recursive functions, that will be optimized by compile to `while` loops.

The last thing to notice is the definition of `TreeParent` that uses the `lateinit var` to store its children.
That's because be need to create this node first, before creating its children, to give the parent node to
the children and then, after creating them, assign to parent node. This guarantees that the values will be
not null after that process, so we can use the as not nullable values after initialization.
