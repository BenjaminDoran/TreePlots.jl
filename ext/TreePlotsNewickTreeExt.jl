module TreePlotsNewickTreeExt

import TreePlots, NewickTree

TreePlots.distance(n::NewickTree.Node) = begin
    d = NewickTree.distance(n)
    isfinite(d) ? d : zero(typeof(d))
end
TreePlots.label(n::NewickTree.Node) = NewickTree.name(n)

end
