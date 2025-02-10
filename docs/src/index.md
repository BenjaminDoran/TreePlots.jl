```@meta
CurrentModule = TreePlots
```

# TreePlots

Documentation for [TreePlots](https://github.com/BenjaminDoran/TreePlots.jl).

This is a package that aims to provide generic plotting recipes for tree like data structures.
As such the recipes should only require that your data structure fulfills the AbstractTrees interface,
i.e. has `AbstractTrees.children(YourType)` defined.

Optionally, `TreePlots.distance(YourType)` and `TreePlots.label(YourType)` can be defined to allow plotting trees
with variable distances between children and parent nodes and pretty printing of each node in the tree respectively.

Currently, we only provide `Makie.jl` backends, but are interested in contributions for recipes for `Plots.jl` and `TidyPlots.jl`.
As well as any other backends or custom tree structures that don't work automatically.
See the `ext` folder for example extensions.

## Installation

```{julia}
using Pkg
Pkg.add("https://github.com/BenjaminDoran/TreePlots.jl.git")
```

## Basic usage

```{julia}
using CairoMakie, TreePlots
tree = ((:a, :b), (:c, :d))
treeplot(tree)
```

see [Tutorials](tutorials/basics.md) and [Gallery](gallery/simple_phylogeny.md) for more in depth examples

## `treeplot()` documentation

see [reference](95-reference.md) for other function's documentation

```@docs; canonical=false
treeplot
```

## Contributors

```@raw html
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
```
