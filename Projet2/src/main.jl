using JuMP, CPLEX, StatsBase, TickTock

include("instance.jl")
include("model.jl")

function solve_main_instances()
    costs_grid = Array{Float64, 2}([
        7 3 10 10 2 8 6 4 5 5;
        7 7 10 5 2 8 6 3 9 9;
        7 3 4 6 3 2 4 9 7 8;
        6 2 7 6 4 7 5 10 7 8;
        2 4 3 4 9 6 4 9 8 4;
        7 5 2 9 8 9 5 6 10 10;
        5 2 3 7 9 9 4 9 6 3;
        5 2 9 4 2 8 6 9 3 4;
        9 6 5 4 5 6 8 9 6 6;
        8 8 7 7 3 5 8 3 9 9;
    ])
    edge_size::Int64 = 10

    min_areas::Array{Float64, 1} = [30, 20, 70]
    max_areas::Array{Float64, 1} = [35, 21, 75]
    budgets::Array{Float64, 1} = [920, 520, 3500]

    for (area_min, area_max, budget) in zip(min_areas, max_areas, budgets)
        println("Amin: $area_min, Amax: $area_max, Budget: $budget")

        instance = create_instance(costs_grid, area_min, area_max, budget)
        tick()
        x, lambda, counter = dinkelbach(instance)
        time = tok()
        x_tab = transpose(reshape(x, (edge_size, edge_size)))
        display(x_tab)
        println("\nNb parcelles: ", sum(x))
        println("Budget utilise $(sum(instance.costs[i] * x[i] for i=1:instance.nb_parcels)) / $budget")
        println("Objectif: ", lambda)
        println("Nb itérations: ", counter)
        println("Time: $time")
        println()
    end
end

function solve_random_instance(edge_size::Int64)
    instance, area_min, area_max, budget = create_random_instance(edge_size)
    println("Amin: $area_min, Amax: $area_max, Budget: $budget")

    x, lambda, nb_iterations = dinkelbach(instance)

    display(transpose(reshape(x, (edge_size, edge_size))))
    println("\nNb parcelles: ", sum(x))
    println("Budget utilise $(sum(instance.costs[i] * x[i] for i=1:instance.nb_parcels)) / $budget")
    println("Objectif: ", lambda)
    println("Nb itérations: ", nb_iterations)
    println()
end

solve_main_instances()
solve_main_instances()
# solve_random_instance(20)
