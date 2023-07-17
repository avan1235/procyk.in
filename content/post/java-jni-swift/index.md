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

1. Swift library definition in [swift-lib](https://github.com/avan1235/java-swift/tree/master/rust-swift/swift-lib)
2. Rust library bridge in [rust-swift](https://github.com/avan1235/java-swift/tree/master/rust-swift)
3. Java `.jar` definition which uses JNI to call functions properly exposed by rust.

Let's check what's required for each layer and how easily we can glue Swift with Java.

### Swift library

Swift project is defined with the help of Swift Package manager (SPM) which allows to define Swift projects independent from Xcode.
The definition of project dependencies in [Package.swift](https://github.com/avan1235/java-swift/blob/master/rust-swift/swift-lib/Package.swift)
contains `SwiftRs` library that allows us to convert types between Rust and Swift. It requires to define _static_ library product which will be exposed
to Rust.

Our main Swift function is defined in [lib.swift](https://github.com/avan1235/java-swift/blob/master/rust-swift/swift-lib/src/lib.swift) and it contains
the definition of the function annotated with `@_cdecl`, which defines exposed name in compilation result. We define simple function

```swift
@_cdecl("say_hello")
func sayHello(to: SRString) -> SRString {
    let to = to.toString()
    let result = "Hello \(to)"
    print("Swift print:", result)
    return SRString(result)
}
```

that takes input string and prepends `"Hello "` to it, printing the result as a side effect.
We show here only how to work with strings, but used library [swift-rs](https://github.com/Brendonovich/swift-rs) allows to use custom types - check a
great [example](https://github.com/Brendonovich/swift-rs/blob/master/example) from library repository.

### Rust wrapper

Rust bridge is responsible for two steps

- receiving data from Swift and properly linking the build result
- exposing defined function to be compatible with JNA

We can find all all definitions in single [lib.rs](https://github.com/avan1235/java-swift/blob/master/rust-swift/src/lib.rs) file.
