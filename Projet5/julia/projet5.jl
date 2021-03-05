using JuMP
using CPLEX

include("instance.jl")

function generate_rolling_model(instance::Instance, window_size::Int64)
    model = Model(CPLEX.Optimizer)

    T = size(instance.d)[1]
    M = size(instance.p)[2]


    # create variables
    x = @variable(model, x[1:T, 1:M] >= 0)
    y = @variable(model, y[1:T, 1:M], Bin)
    s = @variable(model, s[1:T] >= 0)

    # objective
    @objective(model, Min, sum(sum(instance.p[t, m]*x[t, m] + instance.f[t, m]*y[t, m] for m=1:M) + instance.h[t]*s[t] for t = 1:T))

    # add contsraint
    @constraint(model, sum(x[1, m] for m=1:M) - s[1] == instance.d[1])
    @constraint(model, [t=2:T], sum(x[t, m] for m=1:M) - s[t] + s[t-1] == instance.d[t])

    @constraint(model, [t=1:T, m = 1:M], x[t, m] <= sum(instance.d[t_] for t_=t:T)*y[t, m])

    #@constraint(model, [t=1:T-window_size+1], sum((instance.e[t_, m]- instance.Emax)*x[t_, m] for m=1:M for t_=t:(t+window_size-1)) <= 0)
    @constraint(model, [t=1:T], sum((instance.e[((t_-1)%T)+1, m]- instance.Emax)*x[((t_-1)%T)+1, m] for m=1:M for t_=t:(t+window_size-1)) <= 0)


    variables = Dict{String, Any}("x"=>x, "y"=>y, "s"=>s)

    return model, variables
end


function solve_rolling_model!(model::Model, variables::Dict{String, Any})
    optimize!(model)
    if termination_status(model) != MOI.INFEASIBLE
        return termination_status(model), objective_value(model), value.(variables["x"]), value.(variables["y"]), value.(variables["s"])
    end
end


function rolling_model(instance::Instance, window_size::Int64)

    model, variables = generate_rolling_model(instance, window_size)

    # println(model)
    termination_status, objective, x, y, s = solve_rolling_model!(model, variables)
    println("termination status: ", termination_status)
    println("objective value: ", objective)
    println("x: ", x)
    println("y: ", y)
    println("s: ", s)
    return objective, x
end







