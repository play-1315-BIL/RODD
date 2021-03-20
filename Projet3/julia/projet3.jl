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

    #@constraint(model, [k=1:P], x[k] <= 3)

    variables = Dict{String, Any}("x"=>x, "p"=>p, "q"=>q)

    return model, variables
end


function solve_model!(model::Model, variables::Dict{String, Any})
    optimize!(model)
    if termination_status(model) != MOI.INFEASIBLE
        return termination_status(model), objective_value(model), value.(variables["x"]), value.(variables["p"]), value.(variables["q"])
    end
end

function compute_extinction_probabilities(instance::Instance, x)
    P = size(instance.nb_autres_alleles)[1]
    M = size(instance.nb_autres_alleles)[2]
    t = [size(instance.nb_autres_alleles[1, i])[1] for i=1:M]

    expectation = 0
    extinction_probabilities = []

    for i=1:M
        push!(extinction_probabilities, [])
        for j=1:t[i]
            exponent = 0
            survival_is_certain = false
            for k=1:P
                if instance.nb_autres_alleles[k, i][j] == 0 && x[k] > 0
                    survival_is_certain = true
                    break
                elseif instance.nb_autres_alleles[k, i][j] == 1
                    exponent += x[k]
                end
            end

            extinction_probability = 0
            if !survival_is_certain
                extinction_probability = 1/(2^exponent)
            end

            expectation += extinction_probability
            push!(extinction_probabilities[i], extinction_probability)
        end
    end

    return expectation, extinction_probabilities
end


function main()

    # theta_1 = 50
    # theta = create_theta(1e-4, theta_1)

    number_males = 100
    number_genes = Int64(round(number_males*5/4))

    #instance = create_instance()
    instance = random_instance(number_males, number_genes)

    # model, variables = generate_model(instance, theta)

    # # println(model)
    # termination_status, objective, x, p, q = solve_model!(model, variables)
    # println("termination status: ", termination_status)
    # println("objective value: ", objective)
    # #println("x: ", x)
    # #println("p: ", p)
    # #println("q: ", q)

    # expectation, extinction_probabilities = compute_extinction_probabilities(instance, x)

    # println("##############################")
    # println("expectation: ", expectation)
    # println("lower bound: ", objective)
    # println("nodes: ", node_count(model))
    # #println("probas: ", extinction_probabilities)

    # println("number_genes: ", number_genes)

    

    theta_1_values = 50:10:200
    times = []
    nodes = []
    exp = []
    lb = []

    for theta_1 = theta_1_values
        theta = create_theta(1e-4, theta_1)

        model, variables = generate_model(instance, theta)

        termination_status, objective, x, p, q = solve_model!(model, variables)

        expectation, extinction_probabilities = compute_extinction_probabilities(instance, x)

        push!(times, solve_time(model))
        push!(nodes, node_count(model))
        push!(exp, expectation)
        push!(lb, objective)
    end

    counter = 1
    for theta_1 = theta_1_values
        println("\\hline")
        println(theta_1, " & ", times[counter], " & ", nodes[counter], " & ", exp[counter], " & ", lb[counter] , "\\\\" )

        counter+=1
    end



end


main()





