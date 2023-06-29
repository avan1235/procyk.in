---
title: |
  Kotlin vs Swift [#1]
description: Take a look at the projects' structures to see how to prepare first code samples

date: "2023-06-29T00:00:00Z"

draft: true

image: img/featured/featured-kotlin-swift.jpg

featured: false

tags:
- kotlin
- swift
- IDE
- IntelliJ
- CLion

categories:
- Programming Languages

---

## Introduction

Usually, when working with some programming languages, we deal with more than a single source file.
That's when the tools responsible for compiling every source file and caching the old compilations'
results are really helpful. They allow us to forget about the raw calls to compilers and focus on
coding. We're going to explore the two examples of such tools for Kotlin and Swift and see how
the simplest configuration with them looks like.

## Project structure

Project structure is what usually defines the relative location of source files and the definition of
their dependencies in projects. In the case of Kotlin and Swift we can have some "standardized"
directories structure with certain files required for the project to be compilable. Let's see how
they works and what're the minimal examples for each of them.

### Swift project structure

![Kotlin Gradle project structure with simplest entrypoint file open under the project definition](/img/post/kotlin-structure-full.png)
![Swift package project structure with simplest entrypoint file open under the project definition](/img/post/swift-structure-main.png)
![Swift package project structure with entrypoint annotated with `@main`](/img/post/swift-structure-full.png)

## Summary

