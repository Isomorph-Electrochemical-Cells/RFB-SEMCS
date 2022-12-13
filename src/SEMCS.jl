module SEMCS

export read_data
export preprocess_data!
export generate_surrogate_model
export determine_kriging_params
export evaluate_relative_rmse
export evaluate_relative_max_error
export write_surrogate_model_params

using CSV
using DataFrames
using Surrogates
using CairoMakie
using Infiltrator
using Statistics
using LinearAlgebra

export preprocess_legacy_data!, preprocess_data!
export read_data, write_data
export evaluate!
export generate_model
export SEM

const P_MAX_VALUE::Float64 = 1.99

mutable struct SEM
    models::Vector{Kriging} # One Kriging model per output variable
    input_variables::Vector{Symbol}
    output_variables::Vector{Symbol}

    function SEM(df, input_variables, output_variables)
        models = [_initialize(df, input_variables, output_variable)
                            for output_variable in output_variables]
        return new(models, input_variables, output_variables)
    end
end

function _initialize(df, input_params, output_param)
    vec_tuple_input = Tuple.(eachrow(df[:,input_params]))
    dim_input = size(input_params)

    lower_bounds = [minimum(df[:,param]) for param in input_params]
    upper_bounds = [maximum(df[:,param]) for param in input_params]

    std_input_vars = [std(df[:,param]) for param in input_params]

    p_values = P_MAX_VALUE .* ones(dim_input) # choose an initial p value close to 2
    theta_values = 0.5 ./ std_input_vars.^p_values

    vec_output = df[:, output_param]
    k = Kriging(vec_tuple_input, vec_output,
                lower_bounds, upper_bounds;
                p = p_values, theta = theta_values)
    return k
end

function read_data(file_path)
    df_data = CSV.read(file_path, DataFrame;
        header=1, delim=",", types=Float64)
    return df_data
end

function write_data(file_path, df_data)
    CSV.write(file_path, df_data)
end


function preprocess_legacy_data!(df_data)
    df_names = names(df_data)

    if "K_xx_1" in df_names
        transform!(df_data, [:K_xx_1, :df] => ByRow((x1, x2) -> x1./x2.^2) => :K_xx_1)
        rename!(df_data, :K_xx_1 => :k_d_xx)
    end
    if "Pe_d_1" in df_names
        rename!(df_data, :Pe_d_1 => :pe_d)
    end
    if "Re_d_1" in df_names
        rename!(df_data, :Re_d_1 => :re_d)
    end
    if "D_eff_l_xx_vam" in df_names
        rename!(df_data, :D_eff_l_xx_vam => :d_eff_d_xx)
    end
    if "Ki_eff_l_vam" in df_names
        transform!(df_data, [:Ki_eff_l_vam, :df] => ByRow((x1, x2) -> x1.*x2) => :Ki_eff_l_vam)
        rename!(df_data, :Ki_eff_l_vam => :ki_eff_d_xx)
    end
end


function preprocess_data!(vam_data)
    # transform the following data columns to their logarithmic value
    log_symbols = [:epsilon, :k_d_xx, :ki_d, :pe_d, :d_eff_d_xx, :ki_eff_d_xx]
    for symbol in log_symbols
        transform!(vam_data, symbol=> ByRow(x -> log(x)) => symbol)
    end
end

function generate_model(file_path)
    input_variables = [:epsilon, :pe_d, :ki_d]
    output_variables = [:k_d_xx, :d_eff_d_xx, :ki_eff_d_xx]

    df = read_data(file_path)
    preprocess_data!(df)
    return SEM(df, input_variables, output_variables)
end

function evaluate!(result, model, values)
    for idx_output in range(1,length(model.models))
        for idx_input in range(1,size(values,2))
            result[idx_output, idx_input] = exp.(model.models[idx_output](log.(values[:,idx_input])))
        end
    end
end

end
