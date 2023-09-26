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
