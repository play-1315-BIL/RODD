using JuMP, CPLEX


function is_voisin(k::Int64, l::Int64, i::Int64, j::Int64)
    return abs(k - i) + abs(l - j) == 1
end

function generate_MIP_model(instance::Instance; add_bound::Int64=nothing)
    t = instance.t
    w1 = instance.w1
    w2 = instance.w2
    g = instance.g
    l = instance.l
    M = size(t)[1]
    N = size(t)[2]

    model = Model(CPLEX.Optimizer)

    @variable(model, x[i=1:M, j=1:N], Bin)
    # x = Array{Float64}([0.0  0.0  0.0  1.0  0.0;
    # 0.0  0.0  0.0  1.0  0.0;
    # 0.0  0.0  1.0  0.0  1.0;
    # 1.0  0.0  0.0  1.0  0.0;
    # 1.0  0.0  0.0  0.0  0.0])
    @variable(model, d[i=1:M, j=1:N] >= 0)

    @objective(model, Max, sum(w1 * t[i, j] * (1 - x[i, j]) + w2 * g * l * (4 * x[i, j] - d[i, j]) for i=1:M for j=1:N))

    @constraint(model, [i=1:M, j=1:N], d[i, j] >= sum(x[k, l] - (1 - x[i, j]) for k=1:M for l=1:N if is_voisin(k, l, i, j)))

    if add_bound !== nothing
        @constraint(model, sum(x[i, j] for i=1:M for j=1:N) >= add_bound)
    end
    
    variables = Dict{String, Any}("x" => x, "d" => d)

    return model, variables
end


function solve_MIP_model(model::Model, variables::Dict{String, Any})
    optimize!(model)
    return objective_value(model), value.(variables["x"]), value.(variables["d"])
end


function generate_01_model(instance::Instance; add_bound::Int64=nothing)
    t = instance.t
    w1 = instance.w1
    w2 = instance.w2
    g = instance.g
    M = size(t)[1]
    N = size(t)[2]

    model = Model(CPLEX.Optimizer)

    @variable(model, x[i=1:M, j=1:N], Bin)
    @variable(model, y[i=1:M, j=1:N, k=1:M, l=1:N; is_voisin(k, l, i, j)] >= 0)

    @objective(model, Max, sum(w1 * t[i, j] * (1 - x[i, j]) for i=1:M for j=1:N) +
                           sum(w2 * g * instance.l * y[i, j, k, l] for i=1:M for j=1:N for k=1:M for l=1:N if is_voisin(k, l, i, j)) +
                           w2 * g * instance.l * sum(x[1, j] + x[M, j] for j=1:N) + w2 * g * instance.l * sum(x[i, 1] + x[i, N] for i=1:M))

    @constraint(model, [i=1:M, j=1:N, k=1:M, l=1:N; is_voisin(k, l, i, j)], y[i, j, k, l] <= x[i, j])
    @constraint(model, [i=1:M, j=1:N, k=1:M, l=1:N; is_voisin(k, l, i, j)], y[i, j, k, l] <= 1 - x[k, l])
    # @constraint(model, [i=1:M, j=1:N, k=1:M, l=1:N; is_voisin(k, l, i, j)], y[i, j, k, l] >= x[i, j] - x[k, l])

    if add_bound !== nothing
        @constraint(model, sum(x[i, j] for i=1:M for j=1:N) >= add_bound)
    end

    variables = Dict{String, Any}("x" => x, "y" => y)

    return model, variables
end


function solve_01_model(model::Model, variables::Dict{String, Any})
    optimize!(model)
    return objective_value(model), value.(variables["x"]), value.(variables["y"])
end
