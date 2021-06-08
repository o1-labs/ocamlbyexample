# Ocaml By Example

<img width="1337" alt="Screen Shot 2021-06-02 at 9 48 58 PM" src="https://user-images.githubusercontent.com/1316043/120588632-5cb50f00-c3ec-11eb-9007-5221ec26f885.png">

Learn the OCaml language, following a series of examples!

You can visit the rendered course here: https://o1-labs.github.io/ocamlbyexample/.

This page is inspired by https://www.gobyexample.com.

## Adding your own examples (chapters)

Create a folder in `book/chapters/` (using another example), then add your chapter in `book/chapters.json`.

Some guidelines: 

1. short examples are best
1. one chapter teaches one concept well
1. one block of explanation teaches one subconcept well
1. a concept is always introduced and explained the first time it is being used in an example

## How to render the webpage locally

You need the [OCaml](https://ocaml.org/) language setup.
Once you've set up OCaml you can install the dependencies needed by the project with:

```
make deps
```

Then simply run:

```
make
```

or to automatically update the website as you change files:

```
make watch
```

## Can I use this for another programming language?

Yes, while the code is written in OCaml you can use it to build similar webpages for any programming language (although syntax highlighting will only work for languages supported by [highlight.js](https://github.com/highlightjs/highlight.js/blob/main/SUPPORTED_LANGUAGES.md)).

So feel free to fork this page and use to teach your own stuff!
