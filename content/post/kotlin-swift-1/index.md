---
title: |
  Kotlin vs Swift [#1]
description: Take a look at the projects' structures to see how to prepare first code samples when building HTTP server

date: "2023-06-29T00:00:00Z"

image: img/featured/featured-kotlin-swift.jpg

featured: false

tags:
- kotlin
- ktor
- swift
- vapor
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

We're going to work with project managed by Swift Package Manager, which is a tool available from
Swift 3.0. The alternatives are old CocoaPods and Carthage, which existed before SPM.

SPM organizes code in modules, which can be seen as namespaces that enforce the access control in code.
The source files with their `Package.swift` manifest file are called package. Package can have
multiple targets, which is a library or an executable. We can see that the manifest file is
defined in Swift language which gives us more possibilities with the knowledge of this language.
We can define the dependencies in the script by specifying the location of their sources.
Script needs to start with special line with the definition of version for `swift-tools` - you can get unreadable errors after removing this line so watch out!

Here is a sample configuration file which we'll use to start simple HTTP server. Let's notice that the dependencies are mentioned here twice - first
we got the list of them, then we assign specific dependencies to concrete
targets. 

```swift
// swift-tools-version: 5.8

import PackageDescription

let package = Package(
        name: "swift-playground",
        dependencies: [
            .package(
                    url: "https://github.com/vapor/vapor.git",
                    branch: "main"),
        ],
        targets: [
            .executableTarget(
                    name: "swift-playground",
                    dependencies: [
                        .product(name: "Vapor", package: "vapor"),
                    ],
                    path: "Sources"),
        ]
)
```

It's worth noticing how the code structure in such SPM looks like - the
manifest file exists in root directory while the source files are placed in
some directory defined in script.

To specify the entrypoint of our executable we have two options:

- use special `@main` annotation on struct with static `main` method

![Swift package project structure with entrypoint annotated with `@main`](/img/post/swift-structure-full.png)

- name the file with entrypoint `main.swift` and then place the instructions
top-file

![Swift package project structure with simplest entrypoint file open under the project definition](/img/post/swift-structure-main.png)

We can then try deploying our HTTP server base with a few top-file
instructions based on the [Vapor](https://vapor.codes/) library documentation.

```swift
import Vapor

let arguments = ["vapor", "serve", "--port", "1234"]
let app = try Application(.detect(arguments: arguments))
defer {
    app.shutdown()
}

app.get("") { req in
    "Hello World!"
}

try app.run()
```

This small piece of code shows a huge power of Swift and its constructs
and allows to deploy a HTTP server with a few lines of code - wow!
It's enough to call `swift run` command or run the build configuration
created by Swift plugin in CLion.

You can find the running example at [this commit](https://github.com/avan1235/kotlin-vs-swift/tree/32e386118dbaa5c074c7fd5abde3c3bc3a48e506/swift-playground).

Psss.. We're going to discuss these language features in future posts, so stay tuned!

### Kotlin project structure

The Kotlin project uses Gradle which is not limited to Kotlin and Java
projects but they are its main targets. It allows to define hierarchical
structure of project with tasks able to run arbitrary Kotlin code. It
supports applying different plugins which can modify the project.

To compile Kotlin project with Gradle, we don't even need to install
Kotlin compiler as we've seen in [the previous post](/post/kotlin-swift-0/#kotlin-compiler). Gradle, thanks to applying `kotlin("jvm")` plugin, 
can manage downloading Kotlin compiler, and thanks to applying
`application` plugin it can create and run a JVM application with
proper dependencies' management.

The latest configuration files uses Kotlin language, so once again we 
get all the features of the language when building the project!
The minimal configuration to run the HTTP server in Kotlin might look like
in the following way

```kotlin
plugins {
    kotlin("jvm") version "1.8.21"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.ktor:ktor-server-core-jvm:2.3.2")
    implementation("io.ktor:ktor-server-netty-jvm:2.3.2")
}

application {
    mainClass.set("MainKt")
}
```

It requires manual specification of the class that contains the entrypoint
for the JVM - let's notive the name `MainKt` was give, as this is the name
of the class generated by Kotlin for the top-file `main` function.

![Kotlin Gradle project structure with simplest entrypoint file open under the project definition](/img/post/kotlin-structure-full.png)

We can notice that the project contains also other files that build its structure:

- `gradle.properties` file can contain extra definitions in key-value format
- `gradlew` files with the `gradle` directory allows to run Gradle without installing it on machine and depending on local version - it's a portable version of Gradle that can be submitted to the repository and redistributed
and requires only JVM to work
- `settings.gradle.kts` file defines the top parent of the hierarchical project structure

So our first try to deploy the same HTTP server as we did with Swift would
use the mentioned `build.gradle.kts` and have the following `Main.kt` file

```kotlin
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun main() {
    embeddedServer(Netty, port = 1234) {
        routing {
            get ("/") {
                call.respondText("Hello World!")
            }
        }
    }.start(wait = true)
}
```

We can notice that Kotlin also allows using just a small piece of code
to start a huge machine such as HTTP server. It seems more declarative in
this case, as everything is wrapped in single structure describing our intention.

You can find the Kotlin sample in [this commit](https://github.com/avan1235/kotlin-vs-swift/tree/74dd174d749c510a7bf00217e3a8f646cd6c8ad0/kotlin-playground).

## Summary

Both languages uses their power to define builds which gives the programmers
more flexibility when defining the project structure. They aim to provide a
declarative way of defining a project with similar concepts of splitting them
into libraries which can be reused as dependencies. Both languages allow to
define a sample application with a few lines which show a huge powers of these languages. We're going to dive deep into the in the future posts, so stay tuned!