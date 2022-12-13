using SEMCS
using CairoMakie
using Infiltrator

function evaluate_model(model)
    num_evaluations = 100 # number of model evaluations
    ε_range = range(0.7,0.9, length=num_evaluations)
    pe_d_range = 10.0.^range(-2.0, -2.0, length=num_evaluations)
    ki_d_range = 10.0.^range(-1, 1, length=num_evaluations)

    input_variables = model.input_variables
    output_variables = model.output_variables

    input_values = [collect(ε_range)'; collect(pe_d_range)'; collect(ki_d_range)']
    num_input_variables = length(input_variables)
    num_output_variables = length(output_variables)
    result = similar(input_values, (num_output_variables, num_evaluations))
    evaluate!(result, model, input_values)
    return (input_values, result)
end

function generate_plots(input_values, output_values)

    input_variables = [:epsilon, :pe_d, :ki_d]
    output_variables = [:k_d_xx, :d_eff_d_xx, :ki_eff_d_xx]
    ylabels = [L"K_{d,xx}",L"D^{*}_{d,xx}",L"\mathrm{Ki}^{eff}_{d,xx}"]
    xlabels = [L"\varepsilon",L"\mathrm{Pe}_d",L"\mathrm{Ki}_d"]

    fig_kdxx_vs_eps = generate_line_plot(input_values[1,:], output_values[1,:];
                                xlabel=xlabels[1], ylabel=ylabels[1], title="Permeability")
    save("results/fig_kdxx_vs_eps.png", fig_kdxx_vs_eps; resolution = (600,600))

    fig_deff_vs_kid = generate_line_plot(input_values[3,:], output_values[2,:];
                                xlabel=xlabels[3], ylabel=ylabels[2], title="Dispersion")
    save("results/fig_deff_vs_kid.png", fig_deff_vs_kid)

    fig_kideff_vs_eps = generate_line_plot(input_values[1,:], output_values[3,:];
                    xlabel=xlabels[1], ylabel=ylabels[2], title="Effective Kinetic Number")
    save("results/fig_kideff_vs_eps.png", fig_kideff_vs_eps)

    return Nothing
end

function generate_line_plot(input_values, output_values;
                            xlabel="", ylabel="", title="")

    function y_tick_format(values)
        map(values) do v
            string(round(v; digits=3))
        end
    end

    function x_tick_format(values)
        map(values) do v
            string(round(v; digits=3))
        end
    end

    fig = Figure()
    Axis(fig[1, 1], xscale = log10, yscale = log10,
        xtickformat = x_tick_format, ytickformat = y_tick_format, title = title,
        yminorticksvisible = true, yminorgridvisible = true,
        yminorticks = IntervalsBetween(10), ylabel = ylabel, xlabel = xlabel)
    lines!(input_values, output_values;
             color="red", colormap=:coolwarm)
    scatter!(input_values, output_values;
              color="black", marker='x', markersize= 10, colormap=:coolwarm)
    return fig
end

model = generate_model("data/square_array_disk_2d/vam.csv")
input_values, result = evaluate_model(model)
generate_plots(input_values, result)
