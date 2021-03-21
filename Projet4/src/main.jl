using CPLEX
using JuMP
using Plots

include("instance.jl")
include("model.jl")

function solve_main_instances()
    t = Array{Float64, 2}(
        [
            84 68 97 98 64 89 82 71 74 76;
            87 83 98 75 60 90 78 67 92 94;
            84 68 70 81 67 61 73 92 86 90;
            79 62 86 79 73 84 76 98 84 90;
            62 72 66 72 92 80 71 91 87 70;
            85 77 63 93 90 94 76 81 99 98;
            76 63 66 84 94 93 72 92 79 65;
            76 63 92 69 60 88 79 93 66 73;
            92 82 77 72 77 81 89 95 80 80;
            88 89 83 86 69 78 91 64 94 92;
        ]
    )

    w1::Float64 = 1
    w2::Float64 = 5
    l::Float64 = 3
    g::Float64 = 1.26157

    instance = Instance(t, w1, w2, g, l)
    M = size(t)[1]
    N = size(t)[2]
    model1, variables1 = generate_MIP_model(instance)#; add_bound=60)
    model2, variables2 = generate_01_model(instance)#; add_bound=60)

    objective1, x1, d, nodes1, time1 = solve_MIP_model(model1, variables1)
    println("Objective: $objective1, $nodes1, $time1")
    display(x1)
    println()
    for i=1:M
        println([j for j=1:N if x1[i, j] == 1])
    end
    e1 = sum(t[i, j] * (1 - x1[i, j]) for i=1:M for j=1:N)
    non_cut = sum((1 - x1[i, j]) for i=1:M for j=1:N)
    e2 = sum(g * l * (4 * x1[i, j] - d[i, j]) for i=1:M for j=1:N)
    nb_lisieres = sum((4 * x1[i, j] - d[i, j]) for i=1:M for j=1:N)
    println("e1 = $e1, e2 = $e2, non_cut = $non_cut, nb_lisieres = $nb_lisieres")

    objective2, x2, y, time2 = solve_01_model(model2, variables2)
    println("Objective: $objective2, $time2")
    display(x2)

    println()
    t = Array{Float64, 2}(
        [
            10 10 10 1 10;
            10 10 1 1 10;
            10 10 1 10 10;
            1 10 10 10 10;
            1 10 10 10 10;
        ]
    )
    M = size(t)[1]
    N = size(t)[2]

    w1 = 2
    w2 = 1
    l = 3
    g = 1.26157

    instance = Instance(t, w1, w2, g, l)
    model1, variables1 = generate_MIP_model(instance)#; add_bound=60)
    model2, variables2 = generate_01_model(instance)#; add_bound=60)

    objective1, x1, d, nodes1, time1 = solve_MIP_model(model1, variables1)
    println("Objective: $objective1, $nodes1, $time1")
    display(x1)
    println()
    for i=1:M
        println([j for j=1:N if x1[i, j] == 1])
    end
    e1 = sum(t[i, j] * (1 - x1[i, j]) for i=1:M for j=1:N)
    non_cut = sum((1 - x1[i, j]) for i=1:M for j=1:N)
    e2 = sum(g * l * (4 * x1[i, j] - d[i, j]) for i=1:M for j=1:N)
    nb_lisieres = sum((4 * x1[i, j] - d[i, j]) for i=1:M for j=1:N)
    println("e1 = $e1, e2 = $e2, non_cut = $non_cut, nb_lisieres = $nb_lisieres")
    println()

    objective2, x2, y, time2 = solve_01_model(model2, variables2)
    println("Objective: $objective2, $time2")
    display(x2)
    println()
end

function solve_random_instance(size::Int64)
    instance = create_random_instance(size)
    model1, variables1 = generate_MIP_model(instance)
    model2, variables2 = generate_01_model(instance)

    objective1, x1, d, nodes1, time1 = solve_MIP_model(model1, variables1)
    objective2, x2, y, time2 = solve_01_model(model2, variables2)

    return time1, time2, nodes1
end

function solve_random_instances()
    y1::Array{Float64, 1} = []
    y2::Array{Float64, 1} = []
    x::Array{Int64, 1} = []
    for n=10:100
        time1, time2, nodes = solve_random_instance(n)
        push!(y1, time1)
        push!(y2, time2)
        push!(x, n)
        println("$n, $time1, $time2, $nodes")
    end
    fig1 = plot(x, y1, label="Modèle 1")
    plot!(fig1, x, y2, label="Modèle 2", xlab="taille de l'instance", ylab="temps de calcul (s)")

    savefig(fig1, "fig1.pdf")
    return nothing
end

solve_main_instances()
solve_random_instances()