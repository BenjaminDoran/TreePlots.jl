module TreePlots

using Reexport: Reexport
using Statistics: mean
using AbstractTrees: nodevalue, children, PreOrderDFS
# using Makie: Point2f

const LAYOUTS = (:dendrogram, :cladogram, :radial)
const BRANCHTYPES = (:square, :straight)

export treeplot, treeplot!

function treeplot end
function treeplot! end

# public distance, label

"""
    distance(node)

return scaler distance from node to parent of node. Defaults to `1`

To extend `treeplot` to your type define method for `TreePlots.distance(node::YourNodeType)`
"""
distance() = 1
distance(node) = 1

"""
    label(node)

return string typed value or description of node.

Defaults to `string(nodevalue(node))`

To extend `treeplot` to your type define method for `TreePlots.label(node::YourNodeType)`
"""
label(n) = string(nodevalue(n))

isleaf(n) = (isempty ∘ children)(n)
leafcount(t) = mapreduce(isleaf, +, PreOrderDFS(t))

function nodepositions(tree; showroot = false, layoutstyle = :dendrogram)
    nodedict = Dict{Any,Tuple{Float64,Float64}}()
    currdepth = showroot ? distance(tree) : 0.0
    leafcount = [-1]
    if layoutstyle == :dendrogram
        coord_positions_dendrogram!(nodedict, tree, currdepth, leafcount)
    elseif layoutstyle == :cladogram
        coord_positions_cladogram!(nodedict, tree, currdepth, leafcount)
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
        coord_positions_dendrogram!(nodedict, child, curr_depth + distance(child), leafcount)
    end
    height = mean(last.(childs))
    return nodedict[node] = (curr_depth, height)
end

function coord_positions_cladogram!(nodedict, node, curr_depth, leafcount)
    if isleaf(node)
        leafcount[begin] += 1
        return nodedict[node] = (curr_depth, only(leafcount))
    end
    childs = map(children(node)) do child
        coord_positions_cladogram!(nodedict, child, curr_depth + distance(), leafcount)
    end
    height = mean(last.(childs))
    return nodedict[node] = (curr_depth, height)
end

function extend_tips!(nodecoords)
    maxleafposition = argmax(x -> x[1], values(nodecoords))
    for (k, v) in nodecoords
        if isleaf(k)
            nodecoords[k] = (maxleafposition[1], v[2])
        end
    end
end

function makesegments(nodedict, tree; resolution = 25, branchstyle = :square)
    segs = Vector{Vector{Tuple{Float64,Float64}}}()
    if branchstyle == :square
        make_square_segments!(segs, nodedict, tree; resolution)
    elseif branchstyle == :straight
        make_straight_segments!(segs, nodedict, tree)
    else
        throw(ArgumentError("""branchstyle $branchstyle not in $BRANCHTYPES"""))
    end
    return segs
end

function make_square_segments!(segs, nodedict, tree; resolution = 25)
    function segment_prewalk!(segs, node, parent_node)
        px, py = nodedict[parent_node]
        cx, cy = nodedict[node]

        if node == parent_node # isroot
            push!(
                segs,
                [
                    (0.0, py),
                    [(tx, cy) for tx in range(0.0, cx, length = resolution)]...,
                    (cx, cy),
                    (NaN, NaN),
                ],
            )
        else
            push!(
                segs,
                [
                    (px, py),
                    [(px, ty) for ty in range(py, cy, length = resolution)]...,
                    (cx, cy),
                    (NaN, NaN),
                ],
            )
        end

        if !isleaf(node)
            for c in children(node)
                segment_prewalk!(segs, c, node)
            end
        end
    end
    segment_prewalk!(segs, tree, tree)
    segs
end


function make_straight_segments!(segs, nodedict, tree)
    function segment_prewalk!(segs, node, parent_node)
        px, py = nodedict[parent_node]
        cx, cy = nodedict[node]

        if node == parent_node # isroot
            push!(segs, [(0.0, py), (cx, cy), (NaN, NaN)])
        else
            push!(segs, [(px, py), (cx, cy), (NaN, NaN)])
        end

        if !isleaf(node)
            for c in children(node)
                segment_prewalk!(segs, c, node)
            end
        end
    end
    segment_prewalk!(segs, tree, tree)
    segs
end

function tipannotations(nodedict)
    tipnames = String[]
    tippositions = Tuple{Float32,Float32}[]
    for (k, v) in nodedict
        isleaf(k) || continue
        push!(tipnames, (label(k)))
        push!(tippositions, v)
    end
    tippositions, tipnames
end

# include("./MakieRecipe.jl")
# @reexport using .MakieRecipe: treeplot, treeplot!
# using .MakieRecipe: theme_empty

end # module
