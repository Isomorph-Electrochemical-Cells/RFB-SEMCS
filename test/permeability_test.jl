using SEMCS
using CSV
using DataFrames
using Test
using Infiltrator

function permeability_verification()

    path_data_yazdchi = joinpath(dirname(pathof(SEMCS)), "..",
                        "data/verification/Yazdchi_2011/Yazdchi_porosity_permeability.csv")

    df_data = CSV.read(path_data_yazdchi, DataFrame; header=1, delim=",", types=Float64)

    path_data_vam = joinpath(dirname(pathof(SEMCS)), "..",
                            "data/square_array_disk_2d/vam.csv")
    model = generate_model(path_data_vam)

    ε_values = df_data[!,"porosity"]
    kdxx_values = df_data[!,"K_d_xx"]

    idx_selection = ε_values .>= 0.6 .&& ε_values .<= 0.95
    ε_values = ε_values[idx_selection]
    kdxx_values = kdxx_values[idx_selection]
    pe_d_values = similar(kdxx_values)
    ki_d_values = similar(kdxx_values)
    fill!(pe_d_values, 0.01)
    fill!(ki_d_values, 0.01)

    num_evaluations = length(ki_d_values)

    input_variables = model.input_variables
    output_variables = model.output_variables

    input_values = [ε_values'; pe_d_values'; ki_d_values']
    num_input_variables = length(input_variables)
    num_output_variables = length(output_variables)
    result = similar(input_values, (num_output_variables, num_evaluations))
    evaluate!(result, model, input_values)

    rel_tol = 0.06
    @test maximum(abs.(result[1,:] - kdxx_values)./abs.(kdxx_values)) < rel_tol
end

permeability_verification()
