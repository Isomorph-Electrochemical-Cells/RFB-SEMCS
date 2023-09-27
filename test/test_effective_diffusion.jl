module TestEffectiveDiffusion

using SEMCS
using Test
using CSV
using DataFrames

include("utils.jl")

function test()
    path_data_ref = "ValdesParada_2011/Effective_Diffusion_Fig4_Disk_2D.csv"
    data_ref = load_data(path_data_ref)

    data_model = load_model_data("square_array_disk_2d")
    model = generate_model(data_model)

    # check that the relative error at the predictor locations is close to zero
    ε_values = data_model[!,"epsilon"]
    pe_d_values = data_model[!,"pe_d"]
    ki_d_values = data_model[!,"ki_d"]
    d_eff_d_values = data_model[!,"d_eff_d_xx"]
    evaluate_error(model, ε_values, pe_d_values, ki_d_values, d_eff_d_values, 1e-8)

    # # check that the relative error at unsampled locations is small
    ε_values = 0.8 * ones(nrow(data_ref))
    pe_d_values = 1e-2 * ones(nrow(data_ref))
    df0 = dimensionless_fibre_diameter("square_array_disk_2d", ε_values)

    ki_d_values = data_ref[!,"Ki_l"] .* df0
    d_eff_d_values = data_ref[!,"D_eff_l_xx"] ./ ε_values

    idx_selection = ki_d_values .>= 0.01 .&& ki_d_values .<= 10.0
    ε_values = ε_values[idx_selection]
    ki_d_values = ki_d_values[idx_selection]
    d_eff_d_values = d_eff_d_values[idx_selection]
    pe_d_values = pe_d_values[idx_selection]

    evaluate_error(model, ε_values, pe_d_values, ki_d_values, d_eff_d_values, 0.01)
end

function evaluate_error(model, ε_values, pe_d_values, ki_d_values, d_eff_d_values, rtol)
    num_evaluations = length(ki_d_values)

    input_variables = model.input_variables
    output_variables = model.output_variables

    input_values = [ε_values'; pe_d_values'; ki_d_values']
    num_input_variables = length(input_variables)
    num_output_variables = length(output_variables)
    result = similar(input_values, (num_output_variables, num_evaluations))
    evaluate!(result, model, input_values)

    @test maximum(abs.(result[2,:] - d_eff_d_values)./abs.(d_eff_d_values)) < rtol
end

end
