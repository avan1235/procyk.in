---
title: |
  [#1] Latte Native compiler in Kotlin - Parser
slug: latte-native-compiler-in-kotlin-1
description: Let's discuss the purpose of implementing the compiler by ourselves and trying to understand the insights from Compilers Construction.

date: "2023-06-13T00:00:00Z"

image: img/featured/featured-latte-compiler.jpg

featured: false

tags:
- latte
- native
- compilers-construction
- mim-uw

categories:
- University Project

---

## Introduction

In the context of compilers' construction, we can distinguish compiler fronted and backend parts of the program.
The first one is responsible for changing the input source code into the internal representation, which later
is going to be transformed by the second one.
In this post, we're going to focus on the frontend architecture and see what are the particular steps
needed to go from the text data to tree structure corresponding to the program definition.

## What's needed in frontend

The desired goal seems pretty obvious — we want to produce internal representation for every input program
so that we can later transform it easily. Although this is actually done in two steps, which are:

1. tokenization — lexer is responsible for recognizing in input text the structures like identifier

