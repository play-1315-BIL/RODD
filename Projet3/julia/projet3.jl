using JuMP
using CPLEX

include("instance.jl")


function generate_model(instance::Instance, theta::Array{Float64, 1})
    model = Model(CPLEX.Optimizer)

    P = size(instance.nb_autres_alleles)[1]
    M = size(instance.nb_autres_alleles)[2]
    t = [size(instance.nb_autres_alleles[1, i])[1] for i=1:M]
    H = size(theta)[1]
    n = instance.nb_autres_alleles
    is_male = instance.is_male

    # create variables
    x = @variable(model, x[1:P] >= 0, Int)
    p = @variable(model, p[i=1:M, j = 1:t[i]] >= 0)
    q = @variable(model, q[i=1:M, j = 1:t[i]] >= 0)

    # objective
    @objective(model, Min, sum(p[i, j] for i=1:M for j=1:t[i]))

    # add contsraints
    @constraint(model, [i=1:M, j = 1:t[i], r=1:H], log(theta[r]) + 1/theta[r]*(q[i, j] - theta[r]) >= sum(x[k] * log(1/2) for k=1:P if n[k, i][j] == 1))
    @constraint(model,  [i=1:M, j = 1:t[i]], p[i, j] >= q[i, j] - sum(x[k] for k = 1:P if n[k, i][j] == 0))

    @constraint(model, sum(x[k] for k=1:P if is_male[k]) == P)
    @constraint(model, sum(x[k] for k=1:P if !is_male[k]) == P)

    @constraint(model, [k=1:P], x[k] ==2)

    variables = Dict{String, Any}("x"=>x, "p"=>p, "q"=>q)

    return model, variables
end


function solve_model!(model::Model, variables::Dict{String, Any})
    optimize!(model)
    if termination_status(model) != MOI.INFEASIBLE
        return termination_status(model), objective_value(model), value.(variables["x"]), value.(variables["p"]), value.(variables["q"])
    end
end


function main()

    theta = create_theta(1e-3, 50)

    instance = create_instance()

    model, variables = generate_model(instance, theta)

    # println(model)
    termination_status, objective, x, p, q = solve_model!(model, variables)
    println("termination status: ", termination_status)
    println("objective value: ", objective)
    println("x: ", x)
    println("p: ", p)
    println("q: ", q)

end


main()





