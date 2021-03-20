using JuMP
using CPLEX

include("parsing.jl")

function generate_natural_reserve_model(instance::Instance)
    model = Model(CPLEX.Optimizer)

    N = Int64(size(instance.parcel_graph)[1])
    K = Int64(size(instance.survival_probability)[1])
    p = instance.survival_probability
    alpha = instance.required_survival_probability
    D = instance.is_in_danger
    delta = instance.parcel_graph
    is_edge = instance.is_edge


    # create variables
    x = @variable(model, x[1:N], Bin)
    y = @variable(model, y[1:N], Bin)

    # objective
    @objective(model, Min, sum(instance.protection_cost[i] * x[i] for i=1:N))

    # add contsraints
    @constraint(model, [k=1:K ; !D[k]], sum(x[i] * log(1 - p[k, i]) for i=1:N) <= log(1 - alpha[k]))
    @constraint(model, [k=1:K ; D[k]], sum(y[i] * log(1 - p[k, i]) for i=1:N) <= log(1 - alpha[k]))

    @constraint(model, [i=1:N ; is_edge[i]], y[i] == 0)

    @constraint(model, [i=1:N], x[i] >= y[i])
    @constraint(model, [i=1:N, j=1:N; delta[i, j]], x[j] >= y[i])

    variables = Dict{String, Any}("x"=>x, "y"=>y)

    return model, variables
end


function solve_natural_reserve_model!(model::Model, variables::Dict{String, Any})
    optimize!(model)
    if termination_status(model) != MOI.INFEASIBLE
        return termination_status(model), objective_value(model), value.(variables["x"]), value.(variables["y"])
    end
end

function compute_survival_probability(instance::Instance, x, y)
    N = Int64(size(instance.parcel_graph)[1])
    K = Int64(size(instance.survival_probability)[1])

    survival_probabilities = Array{Float64, 1}(zeros(K))
    for k = 1:K
        extinction_probability = 1
        if instance.is_in_danger[k]
            extinction_probability = exp(sum(y[i]*log(1 - instance.survival_probability[k, i]) for i=1:N))
        else
            extinction_probability = exp(sum(x[i]*log(1 - instance.survival_probability[k, i]) for i=1:N))
        end
        survival_probabilities[k] = 1 - extinction_probability
    end

    return survival_probabilities
end


function natural_reserve_model(required_survival_probability::Array{Float64, 1})
    #instance = create_instance(required_survival_probability)
    
    number_species = 40
    grid_size = Int64(round(sqrt(number_species/6*100)))
    
    instance = random_instance(grid_size, number_species)

    model, variables = generate_natural_reserve_model(instance)

    # println(model)
    termination_status, objective, x, y = solve_natural_reserve_model!(model, variables)
    println("termination status: ", termination_status)
    println("objective value: ", objective)
    println("x: ", x)
    println("y: ", y)
    println("node count: ", node_count(model))

    println("grid_size", grid_size)

    #survival_probabilities = compute_survival_probability(instance, x, y)
    #println("survival_probabilities", survival_probabilities)
end

required_survival_probability = Array{Float64, 1}([0.9, 0.9, 0.9, 0.5, 0.5, 0.5])

natural_reserve_model(required_survival_probability)

