include("instance.jl")
include("model.jl")

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

t2 = Array{Float64, 2}(
    [
        10 10 10 1 10;
        10 10 1 1 10;
        10 10 1 10 10;
        1 10 10 10 10;
        1 10 10 10 10;
    ]
)

w1 = Float64(1)
w2 = Float64(5)
l = Float64(3)
g = Float64(1.26157)

instance = Instance(t, w1, w2, g, l)
model1, variables1 = generate_MIP_model(instance; add_bound=60)
model2, variables2 = generate_01_model(instance; add_bound=60)

objective1, x1, d = solve_MIP_model(model1, variables1)
println("Objective: $objective1")
display(x1)

objective2, x2, y = solve_01_model(model2, variables2)
println("Objective: $objective2")
display(x2)
