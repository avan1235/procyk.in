---
title: Advent of Code 2020 in Kotlin - Day 4
description: Think more deeply about extension functions (with simple bytecode analysis) and `typealias`es in Kotlin

date: "2021-10-10T00:00:00Z"

image: featured.jpg

tags:
- kotlin
- advent-of-code-2020
- puzzle

categories:
- Code sample
- Advent of Code
---

## Introduction

The [Day 4](https://adventofcode.com/2020/day/4) problem might be seen as a business problem that requires reading some
input data from the user, parsing it and performing business transformations.

We can try to realize that using some readable approach with the usage of extension functions and defining a few
`typealiases`es which would express our intentions.

## Solution

Let's start with the code solution

```kotlin
object Day4 : AdventDay() {
  override fun solve() {
    val lines = reads<String>() ?: return
    val passports = lines
      .split { it.isBlank() }
      .mapNotNull { it.toPassport() }
    passports.count { it.hasFields() }.printIt()
    passports.count { it.hasValidFields() }.printIt()
  }
}

private typealias Passport = Map<String, String>
private typealias FieldCheck = (String) -> Boolean

fun List<String>.toPassport(): Passport? = joinToString(separator = " ").run {
  takeIf { isNotBlank() }?.run {
    split(" ").associate {
      val field = it.split(":")
      field[0] to field[1]
    }
  }
}

val REQUIRED_FIELDS_CHECKS = mapOf(
  "byr" to ranged(4, 1920..2002),
  "iyr" to ranged(4, 2010..2020),
  "eyr" to ranged(4, 2020..2030),
  "hgt" to {
    val value = it.takeWhile(Char::isDigit).value<Int>()
    val type = it.dropWhile(Char::isDigit)
    (type == "cm" && value in 150..193) || (type == "in" && value in 59..76)
  },
  "hcl" to { v -> v.length == 7 && v[0] == '#' && v.drop(1).all { it in '0'..'9' || it in 'a'..'f' } },
  "ecl" to { it in setOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth") },
  "pid" to { it.length == 9 && it.all(Char::isDigit) },
)

fun ranged(digits: Int, range: IntRange): FieldCheck =
  { if (it.length == digits && it.all(Char::isDigit)) it.value() in range else false }

fun Passport.hasFields() = keys.containsAll(REQUIRED_FIELDS_CHECKS.keys)

fun Passport.hasValidFields() = hasFields() && REQUIRED_FIELDS_CHECKS.all { this[it.key]?.let(it.value) ?: true }
```

## Extra code comments

We should start with the input data format that is given in unusual way because particular passports can be
defined in a few lines. Because of that we have to split the input on blank lines and concatenate the adjacent
lines to each other to get the complete passport definitions.

Next we can convert the passport definitions into proper data structure that represents particular fields in passport with
`Map<String, String>`. Using extension functions seems to be a good approach for this problem because we use
only some defined data structure (i.e. `Map<String, String>`) without defining new class. Thanks to the Kotlin syntax
we can use them later by calling on particular passports objects. We know from [Kotlin documentation](https://kotlinlang.org/docs/extensions.html)
that these functions are implemented as syntax sugar static functions on JVM that take caller object as the first argument.
We can also observe that using great tool in Intellij IDE for showing some bytecode that corresponds to selected part of code.
To use it, it's enough to select some function and call the action (with `Ctrl + Shift + A`/`Cmd + Shift + A`)
named `Show Kotlin Bytecode`. Using that tool we see, that for example in case of the simplest `Passport::hasFields` function
the compiled Kotlin bytecode looks like
```
public final static hasFields(Ljava/util/Map;)Z
  @Lorg/jetbrains/annotations/NotNull;()
 L0
  ALOAD 0
  LDC "$this$hasFields"
  INVOKESTATIC kotlin/jvm/internal/Intrinsics.checkNotNullParameter (Ljava/lang/Object;Ljava/lang/String;)V
 L1
  LINENUMBER 46 L1
  ALOAD 0
  INVOKEINTERFACE java/util/Map.keySet ()Ljava/util/Set; (itf)
  GETSTATIC Day4Kt.REQUIRED_FIELDS_CHECKS : Ljava/util/Map;
  INVOKEINTERFACE java/util/Map.keySet ()Ljava/util/Set; (itf)
  CHECKCAST java/util/Collection
  INVOKEINTERFACE java/util/Set.containsAll (Ljava/util/Collection;)Z (itf)
  IRETURN
 L2
  LOCALVARIABLE $this$hasFields Ljava/util/Map; L0 L2 0
  MAXSTACK = 2
  MAXLOCALS = 1
```
The most interesting for us parts of this code are:
- function is declared as `static final` function
- function takes a `Map` object as its argument and uses it later by calling `ALOAD 0`

which strictly corresponds to our theoretical knowledge of the extension functions in Kotlin.

By the way, we can observe that the first part of this function is checking if it's first argument (i.e. `Passport`
caller object) is `null` or not, because it was defined as not nullable type. It's worth recalling that these Kotlin
checks for nullability are not only the compiler checks, but they also result in extra checks in runtime of our code 😉
