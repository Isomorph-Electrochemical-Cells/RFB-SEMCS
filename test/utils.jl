function load_data(path_verification_data)
    path_data = joinpath(dirname(pathof(SEMCS)), "..",
                        "data/verification",
                        path_verification_data)

    CSV.read(path_data, DataFrame; header=1, delim=",", types=Float64)
end

function load_model_data(unit_cell_geometry)
    path_data_vam = joinpath(dirname(pathof(SEMCS)), "..",
                            "data", unit_cell_geometry, "vam.csv")
    CSV.read(path_data_vam, DataFrame; header=1, delim=",", types=Float64)
end

function dimensionless_fibre_diameter(unit_cell_geometry, porosity)
    if unit_cell_geometry == "square_array_disk_2d"
        return 2.0*sqrt.((ones(length(porosity)).-porosity)/π)
    else
        throw("unknown unit cell geometry")
    end
end
