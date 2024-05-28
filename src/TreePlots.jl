module TreePlots

using Reexport
using Statistics: mean
using AbstractTrees: children, parent, PreOrderDFS, PostOrderDFS

const LAYOUTS = (:dendrogram, :circular, :radial)
const BRANCHTYPES = (:square, :straight)

"""
    distance(node)

return scaler distance from node to parent of node. Defaults to `1`

To extend `treeplot` to your type define method for `TreePlots.distance(node::YourNodeType)`
"""
distance() = 1
distance(node) = 1
isleaf(n) = (isempty ∘ children)(n)
leafcount(t) = mapreduce(isleaf, +, PreOrderDFS(t))

function nodepositions(tree; showroot=false, layoutstyle=:dendrogram)
    nodedict = Dict{Any,Tuple{Float32,Float32}}()
    currdepth = showroot ? distance(tree) : 0
    leafcount = [-1]
    if layoutstyle == :dendrogram
        coord_positions_dendrogram!(nodedict, tree, currdepth, leafcount)
    else
        throw(ArgumentError("""layoutstyle $layoutstyle not in $LAYOUTS"""))
    end
    return nodedict
end

function coord_positions_dendrogram!(nodedict, node, curr_depth, leafcount)
    if isleaf(node)
        leafcount[begin] += 1
        return nodedict[node] = (curr_depth, only(leafcount))
    end
    childs = map(children(node)) do child
        coord_positions_dendrogram!(nodedict, child, distance(node) + curr_depth, leafcount)
    end
    height = mean(last.(childs))
    return nodedict[node] = (curr_depth, height)
end

function makesegments(nodedict, tree; resolution=25, branchstyle=:square, rootsegment=false)
    segs = Vector{Vector{Tuple{Float32,Float32}}}()
    if branchstyle == :square
        make_square_segments!(segs, nodedict, tree; resolution)
    elseif branchstyle == :straight
        make_straight_segments!(segs, nodedict, tree)
    else
        throw(ArgumentError("""branchstyle $branchstyle not in $BRANCHTYPES"""))
    end
    return segs
end

function make_square_segments!(segs, nodedict, tree; resolution=25)
    for node in PreOrderDFS(tree)
        isleaf(node) && continue
        for child in children(node)
            px, py = nodedict[node]
            cx, cy = nodedict[child]
            push!(segs, [
                (px, py),
                [(px, ty) for ty in range(py, cy, length=resolution)]...,
                (cx, cy),
                (NaN, NaN),
            ])
        end
    end
end

function make_straight_segments!(segs, nodedict, tree)
    for node in PreOrderDFS(tree)
        isleaf(node) && continue
        for child in children(node)
            px, py = nodedict[node]
            cx, cy = nodedict[child]
            push!(segs, [(px, py), (cx, cy), (NaN, NaN)])
        end
    end
end

include("./MakieRecipe.jl")
@reexport using .MakieRecipe: treeplot, treeplot!
using .MakieRecipe: theme_empty

end # module
