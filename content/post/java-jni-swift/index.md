---
title: |
  Call Swift from Java with JNI (with no ObjectiveC)
description: Let's try using JNI with the Rust support and its great supporting libraries

date: "2023-07-17T00:00:00Z"

image: img/featured/featured-kotlin-swift.jpg

featured: false
draft: true

tags:
- java
- swift
- rust
- jni

categories:
- Java

---

## Introduction

I wanted to experiment to with JNI calls to functions defined in Swift language but it turned out that
Swift ABI doesn't have to match the C ABI, so it's quite hard to expose Swift functions in standardized way.

Common procedure in this situation might be using Objective-C wrappers for Swift functions and then providing
extra C wrappers around Objective-C functions. However ,in my opinion, this approach has two downsides:

- it requires you to know Objective-C which might be not the case and moreover
- it probably makes you use Xcode to build Objective-C/Swift project

Having that in mind, I tried using other language a bridge to Swift. Rust became a great candidate thanks to 
existing crates that allows to hookup it with Swift, as well as expose it for JNI.

Let's see what are the required parts of such setup and how it all works together.

## Sample Java-Swift project

I prepared sample project, that demonstrates calling Swift function from Java, and which is publicly available on [GitHub](https://github.com/avan1235/java-swift). It consists of three main parts that 
allows it to call `sayHello` Swift function in Java code, while all needed code is packed into a single
`.jar` file:

1. Swift library definition in [this]()
