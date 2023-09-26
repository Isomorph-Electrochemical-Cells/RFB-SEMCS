function read_data(file_path)
    df_data = CSV.read(file_path, DataFrame;
        header=1, delim=",", types=Float64)
    return df_data
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
