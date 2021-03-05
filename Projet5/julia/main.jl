using Plots

include("projet5.jl")


function main()
    T = 12

    instance = create_instance(T)

    M = size(instance.p)[2]

    tab_objectives = Array{Float64}([])
    tab_emissions = Array{Float64}([])

    range = 1:T

    for i=range
        objective, x = rolling_model(instance, i)
        average_emissions = sum(instance.e[t, m]*x[t, m] for t=1:T for m=1:M)/T
        push!(tab_objectives, objective)
        push!(tab_emissions, average_emissions)
    end

    plot(range, tab_objectives)
    savefig("objectives.png")
    plot(range, tab_emissions)
    savefig("emissions.png")
end


main()
