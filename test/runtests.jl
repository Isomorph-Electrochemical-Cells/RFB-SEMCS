using SEMCS
using Test
using Aqua

@time @testset "Permeability" begin
    include("test_permeability.jl")
    TestPermeability.test()
end

@testset "Aqua" begin
    Aqua.test_project_toml_formatting(SEMCS)
    Aqua.test_deps_compat(SEMCS)
    Aqua.test_stale_deps(SEMCS)
    Aqua.test_project_extras(SEMCS)
    Aqua.test_piracy(SEMCS)
    Aqua.test_undefined_exports(SEMCS)
    Aqua.test_unbound_args(SEMCS)
    Aqua.test_ambiguities(SEMCS)
end
