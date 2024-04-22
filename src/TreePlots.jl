module TreePlots

import MakieCore
import RecipesBase
using Statistics: mean
using AbstractTrees: children, parent, PreOrderDFS, PostOrderDFS
# const IEXIST = true
const LAYOUTS = (:dendrogram, :circular, :radial)
const BRANCHTYPES = (:rightangle, :straight)

"""
    distance(node)

return scaler distance from node to parent of node. Defaults to `1`

To extend `treeplot` to your type define method for `TreePlots.distance(node::YourNodeType)`
"""
distance() = 1
distance(node) = 1
isleaf(n) = (isempty ∘ children)(n)
leafcount(t) = mapreduce(isleaf, +, PreOrderDFS(t))


MakieCore.@recipe(TreePlot, tree) do scene
    # attr = MakieCore.Attributes(
    #     solid_color=:black,
    # )
    # MakieCore.generic_plot_attributes!(attr)
    # MakieCore.colormap_attributes!(attr, MakieCore.theme(scene, :colormap))
end

function MakieCore.plot!(tplot::TreePlot)
    # @debug "hello world"
    # MakieCore.scatter!(tplot, rand(10))
    @debug tplot.tree
    nleaves = leafcount(tplot.tree[])
    toangle(y) = 2pi * (y / (nleaves))
    nodecoords = nodepositions(tplot.tree[])
    @debug nodecoords
    segs = makesegments(nodecoords, tplot.tree[])
    @debug "segs: " segs

    @debug typeof(tplot.transformation.transform_func.val)
    if occursin("Polar", string(tplot.transformation.transform_func[]))
        segs = map(segs) do seg
            [(toangle(y), x) for (x, y) in seg]
        end
    end
    @debug "segs: " segs
    MakieCore.lines!(tplot, reduce(vcat, segs); color=tplot.solid_color)
    # MakieCore.series!(tplot, segs; solid_color=:black)
end



function _coord_postwalk!(r, n, d, i)
    if isleaf(n)
        i[begin] += 1
        return r[n] = (d, only(i))
    end
    cs = map(children(n)) do c
        _coord_postwalk!(r, c, distance(n) + d, i)
    end
    h = mean(last.(cs))
    return r[n] = (d, h)
end

function nodepositions(t)
    nodedict = Dict{Any,Tuple{Float32,Float32}}()
    _coord_postwalk!(nodedict, t, 0, [-1])
    return nodedict
end

function makesegments(R, t)
    segs = Vector{Vector{Tuple{Float32,Float32}}}()
    # segs = Vector{Tuple{Float32, Float32}}()
    for node in PreOrderDFS(t)
        isleaf(node) && continue
        for child in children(node)
            # push!(segs, [R[node],  R[child], (NaN, NaN)])
            px, py = R[node]
            cx, cy = R[child]
            push!(segs, [(px, py), [(px, ty) for ty in range(py, cy, length=25)]..., (cx, cy), (NaN, NaN)])
            # push!(segs, R[node])
            # push!(segs, R[child])
            # push!(segs, (NaN, NaN))
        end
    end
    return segs
end

end
