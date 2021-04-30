# Ocaml By Example

https://mimoo.github.io/ocamlbyexample/

## What is this?

inspired by https://www.gobyexample.com

## How to add your own example

Create a folder in `book/chapters/` (using another example), then add your chapter in `book/chapters.json`.

Some guidelines: 

* short examples are best
* a chapter should teach one thing well
* a chapter should never use something that wasn't explained in a previous chapter (unless it introduces it)

## How to render the thing locally?

You need [ocaml](https://ocaml.org/) and [dune](https://github.com/ocaml/dune) set up.

```
dune exec ./tools/bin/main.exe
```

