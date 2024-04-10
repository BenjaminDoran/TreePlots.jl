using TreePlots
using Test
using Aqua

@testset "TreePlots.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(TreePlots)
    end
    # Write your tests here.
end
