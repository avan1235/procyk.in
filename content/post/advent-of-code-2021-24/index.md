---
title: Advent of Code 2021 in Kotlin - Day 24
description: Try to reverse engineer given program with the help of Kotlin language.

date: "2021-12-24T00:00:00Z"

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

The [Day 24](https://adventofcode.com/2021/day/24) problem was not a typical problem. It includes reverse engineering
some pseudo-assembly code to predict the output of program. Let's see how we can deal with some similar problems
and how to use programming languages when solving such problems.

## Solution

As in most of the "exploitation" problems, we need to come up with some smart observation to solve the problem
What I've found is the structure of the assembly code, i.e. the fact that it's built with 14 blocks (each for
each input digit) with the same structure
```shell
inp w
mul x 0
add x z
mod x 26 // may have different value
div z 1 // may have different value
add x 12 // may have different value
eql x w
eql x 0
mul y 0
add y 25 // may have different value
mul y x
add y 1 // may have different value
mul z y
mul y 0
add y w
add y 15 // may have different value
mul y x
add z y
```
and when we see how it works, we can notice that only `w` and `z` initial values are important because
`x` and `y` are zeroed before usage of them.

So we found some 14 blocks for checking each of the digit of the final code, that transform the `z` value
and read the next digit to `w`. What we have to find is such a combination of digits for which, after all
transformations, we would end up with the `z` equal to 0.

We can try to solve this kind of problems by reverse engineering these simple gadgets and remembering what are
their outputs for every of the combination of given digit and value of `z`. So in `reverseDigitMappings` we try to
run every of these gadgets for every digit from `1..9` and a huge number of different `z` variables in initial state.
It's worth mentioning here that the selected range for `z` was fixed to get a repeatable answer when decreasing
tested ranges, so it may require increasing for some specific inputs.

Having these mapping we can start actual **reversing** the answer. So we look at the computed values and read from
them the set of pairs of input digit and `z` value, for which after transformation of 14th gadget we get 0 in
`z`. For these values we also need to solve similar problem, be recursively checking next digits backwards.
We do this with recursive function `go` which is defined as recursive because it can have at most 15 levels
of nesting, and it's the easiest way of remembering the list of digits that we've tried along our
current path of searching.

To solve both parts of the problem with the same code, we define `findDigits` with `Comparator<Long>` parameter,
so we can select an order of searching through the digits in each step. In this way we're able to find the
solution in a few seconds, where most of the time is used for generating the reverse mappings, so it can be reduced
because the gadgets blocks are repeating in input and some computations are not needed at all (but we leave them
for simpler code).

### [Day24.kt](https://github.com/avan1235/advent-of-code-2021/blob/master/src/main/kotlin/Day24.kt)
```kotlin
object Day24 : AdventDay() {
  override fun solve() {
    val data = reads<String>() ?: return

    val instr = data.map { it.toInstr() }
    val reverseDigits = instr.reverseDigitsMappings()

    reverseDigits.findDigits(compareByDescending { it }).printIt()
    reverseDigits.findDigits(compareBy { it }).printIt()
  }
}

private fun String.toInstr(): Instr {
  val parts = split(" ")
  return when {
    parts.size == 2 && parts[0] == "inp" -> Inp(parts[1])
    parts.size == 3 -> BinOp(parts[1], Op.valueOf(parts[0].uppercase()), parts[2].toRight())
    else -> error("Unknown command type: $this")
  }
}

private fun String.toRight() = try {
  Num(toLong())
} catch (_: Exception) {
  Var(this)
}

private class ReverseDigits(private val mapping: List<LazyDefaultMap<Long, MutableSet<StartingWith>>>) {
  data class StartingWith(val z: Long, val digit: Long)

  fun findDigits(digitsComparator: Comparator<Long>): Long? {
    fun go(digitIdx: Int, forZ: Long, acc: List<Long>): List<Long>? =
      if (digitIdx < 0) acc.reversed()
      else reverseRegState(digitIdx, forZ)
        .sortedWith { l, r -> digitsComparator.compare(l.digit, r.digit) }
        .firstNotNullOfOrNull { go(digitIdx - 1, it.z, acc + it.digit) }

    val digits = go(digitIdx = mapping.size - 1, forZ = 0, acc = listOf())
    return digits?.joinToString("")?.toLongOrNull()
  }

  private fun reverseRegState(idx: Int, value: Long): Set<StartingWith> =
    if (idx in mapping.indices) mapping[idx][value] else emptySet()
}

private fun List<Instr>.reverseDigitsMappings(searchMax: Long = 1 shl 15): ReverseDigits =
  groupSeparatedBy(separator = { it is Inp }, includeSeparator = true) { instr ->
    LazyDefaultMap<Long, MutableSet<ReverseDigits.StartingWith>>(::mutableSetOf).also { finishedWith ->
      for (forZ in 0L..searchMax) for (forDigit in 1L..9L)
        ALU(forDigit, withState = mapOf("z" to forZ)).apply { run(instr) }
          .registers["z"].let { finishedWith[it].add(ReverseDigits.StartingWith(forZ, forDigit)) }
    }
  }.let { ReverseDigits(it) }

private typealias VarName = String
private typealias Left = VarName

private sealed interface Right
private data class Var(val name: VarName) : Right
private data class Num(val value: Long) : Right

private enum class Op(val action: (Long, Long) -> Long) {
  ADD(Long::plus), MUL(Long::times), DIV(Long::div), MOD(Long::mod), EQL({ l, r -> if (l == r) 1 else 0 })
}

private sealed interface Instr
private data class Inp(val toVar: VarName) : Instr
private data class BinOp(val left: Left, val op: Op, val right: Right) : Instr

private class ALU(vararg val input: Long, withState: Map<VarName, Long> = emptyMap()) {
  val registers = withState.toDefaultMap(0)
  private var inputIdx = 0

  fun run(instr: Iterable<Instr>) = instr.forEach { process(it) }

  private fun process(instr: Instr) = when (instr) {
    is Inp -> {
      registers[instr.toVar] = input[inputIdx]
      inputIdx += 1
    }
    is BinOp -> when (instr.right) {
      is Num -> instr.right.value
      is Var -> registers[instr.right.name]
    }.let { rVal -> registers[instr.left] = instr.op.action(registers[instr.left], rVal) }
  }
}
```

## Extra notes

We've used in our solution some use of `sealed interface` as well as the `enum class` so it's worth mentioning
what's the actual difference between them and where we should use every of them.

So the `enum class`es in Kotlin are similar to the enums from `C`-like languages as they are some kind of
fixed, singleton objects of specified type that hold some type information. Then can of course also have extra
methods and override the others, but this kind of code becomes quite hard to read. From my experience, they
should be used when some kind of **label** is needed, so we could take some specific actions in different
contexts for the labels.

In case of the `sealed interface`s we get somehow similar possibilities, but the classes that implement this
kind of interfaces are intended to hold some values. In Kotlin, the compiler is pretty smart, so we can
use `when` statements to check for type of some object and use the fields of some checked class in the
case body, as the checked value is automatically cast to checked type. Let's take a look e.g. at the `ALU::process`
method that uses the `instr` fields and they are quite different in different cases of `when`.
