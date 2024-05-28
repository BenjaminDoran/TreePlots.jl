module MakieRecipe

import ..TreePlots
import MakieCore


MakieCore.@recipe(TreePlot, tree) do scene
    attr = MakieCore.Attributes(
        showroot=false,
        layoutstyle=:dendrogram,
        branchstyle=:square,
        ignorebranchlengths=false,

        linevisible=true,
        linecolor=@something(MakieCore.theme(scene, :color), :black),
        linewidth=@something(MakieCore.theme(scene, :linewidth), 1),
        linecolormap=@something(MakieCore.theme(scene, :colormap), :viridis),
        branch_point_resolution=25,

        markervisible=false,
        markercolor=@something(MakieCore.theme(scene, :color), :black),
        markersize=@something(MakieCore.theme(scene, :markersize), 5),
        markercolormap=@something(MakieCore.theme(scene, :colormap), :viridis),

        leafnamesvisible=true,
        leafnames=nothing,

        leafdata=nothing,
        
    )
    MakieCore.generic_plot_attributes!(attr)
    return MakieCore.colormap_attributes!(attr, MakieCore.theme(scene, :colormap))
end

function MakieCore.plot!(plt::TreePlot)
    nleaves = TreePlots.leafcount(plt.tree[])
    nodecoords = TreePlots.nodepositions(plt.tree[])
    segs = TreePlots.makesegments(nodecoords, plt.tree[];
        resolution=plt.branch_point_resolution[],
        branchstyle=plt.branchstyle[]
    )
    # setup linecolor
    if plt.linecolor[] isa Union{AbstractVector,AbstractRange}
        length(plt.linecolor[]) == length(segs) ||
            throw(ArgumentError("""length of linecolor ($(length(plt.linecolor[]))) must match number of branches in tree ($(length(segs)))"""))
        plt.linecolor[] = repeat(plt.linecolor[], inner=length(first(segs)))
    end
    # modify all points if axis is polar 
    if occursin("Polar", string(plt.transformation.transform_func[]))
        toangle(y) = (y / (nleaves)) * 2π
        segs = map(segs) do seg
            [(toangle(y), x) for (x, y) in seg]
        end
    end

    MakieCore.lines!(plt, reduce(vcat, segs);
        plt.attributes...,
        color=plt.linecolor,
    )

end

theme_empty() = MakieCore.Theme(
    Axis=(;
        topspinevisible=false,
        rightspinevisible=false,
        leftspinevisible=false,
        bottomspinevisible=false,
        xticklabelsvisible=false,
        xgridvisible=false,
        xminorgridvisible=false,
        xticksvisible=false,
        xminorticksvisible=false,
        xlabelvisible=false,
        yticklabelsvisible=false,
        ygridvisible=false,
        yminorgridvisible=false,
        yticksvisible=false,
        yminorticksvisible=false,
        ylabelvisible=false,
    ),
    PolarAxis=(;
        spinevisible=false,
        rticklabelsvisible=false,
        rgridvisible=false,
        rminorgridvisible=false,
        thetaticklabelsvisible=false,
        thetagridvisible=false,
        thetaminorgridvisible=false,
    )
)

end