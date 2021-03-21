function generate_base_subproblem(instance::Instance)
    model = Model(CPLEX.Optimizer)
    # set_silent(model)

    N = instance.nb_parcels
    d = instance.distances
    a = instance.areas
    Amax = instance.area_max
    Amin = instance.area_min
    c = instance.costs
    B = instance.budget

    # variables
    x = @variable(model, x[1:N], Bin)
    y = @variable(model, y[i=1:N, j=1:N; j != i] >= 0)

    @constraint(model, sum(a[i] * x[i] for i=1:N) <= Amax)
    @constraint(model, sum(a[i] * x[i] for i=1:N) >= Amin)
    @constraint(model, sum(c[i] * x[i] for i=1:N) <= B)

    @constraint(model, [i=1:N, j=1:N; j != i], y[i, j] <= x[j])
    @constraint(model, [i=1:N], sum(y[i, j] for j=1:N if j != i) == x[i])

    variables = Dict{String, Any}("x"=>x, "y"=>y)

    return model, variables
end

function update_subproblem_objective!(model::Model, variables::Dict{String, Any}, lambda::Float64, instance::Instance)
    d = instance.distances
    N = instance.nb_parcels
    y = variables["y"]
    x = variables["x"]
    @objective(model, Max, -(sum(d[i, j] * y[i, j] for i=1:N for j=1:N if j != i) - lambda * sum(x[i] for i=1:N)))
end

function solve_subproblem!(model::Model, variables::Dict{String, Any})
    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        return objective_value(model), trunc.(Int64, value.(variables["x"])), value.(variables["y"])
    end

    println(termination_status(model))

    return nothing, nothing, nothing
end


function dinkelbach(instance::Instance)
    d = instance.distances
    N = instance.nb_parcels
    epsilon = 1e-15

    lambda::Float64 = 1
    subproblem, variables = generate_base_subproblem(instance)
    v_lambda = 1

    counter = 1
    while true
        update_subproblem_objective!(subproblem, variables, lambda, instance)
        v_lambda, x, y = solve_subproblem!(subproblem, variables)
        lambda = sum(d[i, j] * y[i, j] for i=1:N for j=1:N if j != i) / sum(x[i] for i=1:N)

        if v_lambda <= epsilon
            return x, lambda, counter
        end
        counter += 1
    end
end
