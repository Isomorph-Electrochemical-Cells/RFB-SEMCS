using SEMCS
using Test, SafeTestsets

@time @safetestset "SEMCS.jl" begin include("permeability_test.jl") end
