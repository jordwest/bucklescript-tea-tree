Bucklescript-TEA Tree View
=================

This is a project I built to play with [Bucklescript](https://github.com/bloomberg/bucklescript) and [Bucklescript-TEA](https://github.com/OvermindDL1/bucklescript-tea) and evaluate it for building a larger project.

It's essentially just a tree view where elements can be dragged to new parents.

[Bucklescript](https://github.com/bloomberg/bucklescript) compiles super fast and small JS from the expressive, type safe language OCaml. Thanks to [Bucklescript-TEA](https://github.com/OvermindDL1/bucklescript-tea) this essentially looks just like an [Elm](http://elm-lang.org/) app but builds to a teeny bundle with [rollup](https://rollupjs.org/):

|          | Uncompressed | gzipped     |
| -------- | ------------ | ----------- |
| Plain    | 128kB        | 19kB        |
| Minified | 31kB         | **10kB** 🎉 |

### Running locally

```sh
git clone https://github.com/jordwest/bucklescript-tea-tree.git
cd bucklescript-tea-tree
npm install
npm run dev
```
