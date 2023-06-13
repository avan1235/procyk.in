---
title: |
  Latte Native compiler in Kotlin [#0]
slug: latte-native-compiler-in-kotlin-0
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

For a few years now, every student of Computer Since at the University of Warsaw implements some kind of native x86 or
x64 compiler of [Latte](https://latte-lang.org/) language to pass the Compilers' Construction and improve the skills and
the knowledge about how the compilers are built and what kinds of problems meet the designers of programming languages
in their careers. Most of the students implement the whole project in Haskell, which is the traditional choice for this
course. While some people try also other languages, like C++, Java or Rust, I finally decided to take advantage of
my Kotlin knowledge and use it in building some basic compiler. Thanks to this I could focus on the details of compilers'
construction and getting familiar with some crucial constructs that become really helpful when dealing with compilers.

I hope that this series of posts may be helpful for some future students in passing their course with the best knowledge
gain, but I also would like to share my experience with some wider audience to show the others how the compilers may
be implemented and about what we should remember when using some popular compilers in our everyday work.

## The first thoughts to share

If somebody asks me, to give him a single advice before starting writing the compilers, I would start with the
sentence "select your favourite programming language that you feel comfortable programming any problem solution and
start reading about others approach to get most of their experience, as this part of computer science has is really
good founded".

The fun part is that I made a mistake, and chose some other great programming language before Kotlin to use in this
project — Rust.
It was a great opportunity for me to get familiar with the basics of the new programming language, but
the problem was that at some point this task became too hard to think about complex compiler construction and learning
some new aspects of the programming language in the same time.
So if you're a student and still not sure if you
should take advantage of your programming skills in some language or try to learn new one during this course — I
strongly advise you focussing on the course topics that are fascinating and don't bother yourself about some
programming language. It's just a tool that you can learn anytime, so stay focused and try to learn a few new
things about compilers 😎.

## What's included in the posts

I share publicly my project at [GitHub](https://github.com/avan1235/latte-compiler) just to show you what the whole
structure might look like and maybe to make you play with the Latte language if needed. The point of these posts
is to share the knowledge, some good internet sources and code samples that you may use when implementing your own
compiler. This project gives a lot of satisfaction for the developer, so even if you're not a student, you can get a
chance to see what are the particular steps in building the compiler from scratch.

There are a lot of topics that are discussed during the Compilers' Construction courses around the world, so
I won't rewrite this content from scratch, but rather show some concrete examples of the implementation or give some
useful tips on concrete aspects of them.

Don't waste then more time on discussions and let's begin our joint adventure through compilers' world 🤓.
