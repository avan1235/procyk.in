---
title: Advent of Code 2021 in Kotlin - Day 16
description: Take a look into Kotlin delegated properties when implementing efficient data parsing in Kotlin.

date: "2021-12-16T00:00:00Z"

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

In [Day 16](https://adventofcode.com/2021/day/16) problem starts with a really long description. In my opinion,
this type of tasks are the worst ones, as they come with a hard-to-understand problem, for which solution is
really straightforward, but only when written in imperative approach with multiple nesting of code. Let's
see how we can approach this kind of problems in Kotlin by using context of the operation and lazy
initialized variables in classes.

## Solution

Understanding the whole description of the task is the most difficult part of it. we should take our time,
read it at leas twice and try to analyze given examples in practice. After that, we can go to actual
implementation that contains a few fascinating concepts of Kotlin code.

We convert the given data from hex to bits using the `String` extension function `toInt` with
specified radix and then extracting every of bits with divide and mod operations. It may look obvious
but of course I started with explicitly specifying each case from task and came up with this nice approach
after some refactorings.

```kotlin
private fun Char.toBits() = "$this".toInt(radix = 16).let {
  sequenceOf((it / 8) % 2, (it / 4) % 2, (it / 2) % 2, it % 2)
}
```

There are two main features that allows us to have more concise and readable code which is pretty
efficient in the same time. We use sequences to consume input data from bits. That's why we define some
helper function that is capable of "consuming" some beginning of the sequence and returning the rest of the
sequence in the single call

```kotlin
private inline fun <T> Sequence<T>.use(n: Int, action: (Sequence<T>) -> Unit): Sequence<T> {
  sequence { yieldAll(take(n)) }.let(action)
  return drop(n)
}
```

It's important to highlight how the lambda scope ([closure](https://kotlinlang.org/docs/lambdas.html#closures))
in Kotlin works to get full understanding of the usage of this extension function. Remember, that in case of Java,
when we want to capture some variable in lambda scope, then it has to be effectively `final` which means,
that it cannot be reassigned. For example, we cannot write in Java the definition like

```java
private static int sum(int to) {
  int idx = 0;
  final int result = IntStream.iterate(1, (it) -> {
    idx += 1; // this will not compile as idx has to be final
    return it + 1;
  }).limit(to).sum();
  System.out.println(idx);
  return result;
}
```

On the other hand, in Kotlin we can write some similar code that will compile and work as expected.
```kotlin
private fun sum(to: Int): Int {
  var idx = 0
  val result = generateSequence(1) {
    idx += 1
    it + 1
  }.take(to).sum()
  println(idx)
  return result
}
```

This type of  approach is more complex in runtime and may be slower but gives the developer more
possibilities to write some functionalities. If we look at the bytecode that is generated for such
implementation we would see that the variable is stored as `IntRef`, so the object which field is modified.
If we would like to make it work in Java, we would have to create our own class that would be capable
of wrapping some value, then wrap the value and handle it properly inside the lambda scope. All these
steps would introduce a lot of noise to our code, so we should be really thankful to Kotlin compiler
that it does the job for us.

When we know that, we can take a look at the whole implementation, where we can find updates of some `var`s
inside the lambda of `use` extension function. E.g. when we want to consume the packet version value,
we consume the first 3 bits and use it to update the value of `version` field from `PacketHeader`, by simply saying

```kotlin
from.use(3) { version = it.msb().toInt() }
```

In the following code we can find even more complex update of such variables in scope of the lambda, that
in my opinion produced really readable code.

### [Day16.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day16.kt)
```kotlin
import kotlin.properties.Delegates.notNull

object Day16 : AdventDay() {
  override fun solve() {
    val data = reads<String>()?.singleOrNull() ?: return
    val bits = data.asSequence().flatMap { it.toBits() }

    val (packet, rest) = buildPacket(from = bits)
    rest.requireZeros()
    packet.sumVersionNumbers().printIt()
    packet.eval().printIt()
  }
}

private typealias Bits = Sequence<Int>

private fun Packet.sumVersionNumbers(): Int = when (this) {
  is NumberPacket -> header.version
  is OpPacket -> header.version + subPackets.sumOf { it.sumVersionNumbers() }
}

private fun Packet.eval(): Long = when (this) {
  is NumberPacket -> value
  is OpPacket -> when (header.type) {
    0 -> subPackets.fold(0L) { acc, p -> acc + p.eval() }
    1 -> subPackets.fold(1L) { acc, p -> acc * p.eval() }
    2 -> subPackets.minOf { it.eval() }
    3 -> subPackets.maxOf { it.eval() }
    5 -> subPackets.let { (l, r) -> if (l.eval() > r.eval()) 1 else 0 }
    6 -> subPackets.let { (l, r) -> if (l.eval() < r.eval()) 1 else 0 }
    7 -> subPackets.let { (l, r) -> if (l.eval() == r.eval()) 1 else 0 }
    else -> throw IllegalStateException("Unknown combination of data in packet: $this")
  }
}

private fun buildPacket(from: Bits): Pair<Packet, Bits> = PacketHeader().run {
  val bits = from
    .use(3) { version = it.msb().toInt() }
    .use(3) { type = it.msb().toInt() }

  when (type) {
    4 -> buildNumberPacket(from = bits)
    else -> buildOpPacket(from = bits)
  }
}

private fun PacketHeader.buildNumberPacket(from: Bits) = NumberPacket(header = this).run {
  var bits = from
  var reading = true
  while (reading) {
    bits = bits.use(1) { reading = it.first() == 1 }
    bits = bits.use(4) { value = value * 16 + it.msb() }
  }
  Pair(this, bits)
}

private fun PacketHeader.buildOpPacket(from: Bits) = OpPacket(header = this).run {
  var bits = from
    .use(1) { countSubPackets = it.first() == 1 }
    .use(if (countSubPackets) 11 else 15) { subPacketsCounter = it.msb().toInt() }
  subPackets = if (countSubPackets)
    buildList {
      repeat(subPacketsCounter) {
        val (subPacket, subBits) = buildPacket(from = bits)
        add(subPacket).also { bits = subBits }
      }
    }
  else buildList {
    bits = bits.use(subPacketsCounter) {
      bits = it
      while (bits.any()) {
        val (subPacket, subBits) = buildPacket(from = bits)
        add(subPacket).also { bits = subBits }
      }
    }
  }
  Pair(this, bits)
}

private fun Char.toBits() = "$this".toInt(radix = 16).let {
  sequenceOf((it / 8) % 2, (it / 4) % 2, (it / 2) % 2, it % 2)
}

private inline fun <T> Sequence<T>.use(n: Int, action: (Sequence<T>) -> Unit): Sequence<T> {
  sequence { yieldAll(take(n)) }.let(action)
  return drop(n)
}

private fun Bits.msb() = fold(0L) { acc, b -> 2 * acc + b }

private class PacketHeader {
  var version: Int by notNull()
  var type: Int by notNull()
}

private sealed class Packet(val header: PacketHeader)
private class NumberPacket(header: PacketHeader) : Packet(header) {
  var value: Long = 0
}

private class OpPacket(header: PacketHeader) : Packet(header) {
  var countSubPackets: Boolean by notNull()
  var subPacketsCounter: Int by notNull()
  var subPackets: List<Packet> by notNull()
}

private fun Bits.requireZeros() =
  if (any { it == 1 }) throw IllegalStateException("Left non zero bytes") else Unit
```

## Extra notes

In our code we used Kotlin delegated properties multiple time. We define field in classes with e.g.
```kotlin
var countSubPackets: Boolean by notNull()
```
to have the instance of the class with field, which is not initialized after construction, but can
be accessed as not nullable value, when initialized. That's because [Kotlin delegation properties](https://kotlinlang.org/docs/delegated-properties.html)
can implement some interface when storing other value in practice. In this example we have a delegated
property, which stores a nullable value, but expose it as not nullable. When the value is accessed and is
not set, then the exception is thrown. It's worth to see how this works and play with it, as it allowed us
to create some hind of scope, in which we create the instance of `PacketHeader` and initialize its fields later,
without creating any builder for it.
