include("instance.jl")
include("model.jl")

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

area_min = Float64(70)
area_max = Float64(75)
budget = Float64(3500)

edge_size = 10
instance, area_min, area_max, budget = create_random_instance(edge_size)
x, lambda, counter = dinkelbach(instance)


println("Amin: ", area_min)
println("Amax: ", area_max)
println("Budget: ", budget)
display(transpose(reshape(x, (edge_size, edge_size))))
println("Nb parcelles: ", sum(x))
println("Objectif: ", lambda)
println("Nb itérations: ", counter)
