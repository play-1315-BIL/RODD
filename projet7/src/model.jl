function generate_model(instance::Instance)
    model = Model(CPLEX.Optimizer)

    C = instance.C1 + instance.C2
    sommets, adj, delta_plus, delta_moins = graph_from_instance(instance)

    N = size(sommets)[1]
    T = instance.T
    P = instance.P

    function is_legal(u, v, t)
        l1, a1, j1 = sommets[u]
        l2, a2, j2 = sommets[v]
        return adj[u, v] && ((j2 > instance.C1 && T%2 == 0) || (j2 <= instance.C1 && T%2 == 1))
    end

    function weight(u, v)
        l1, a1, j1 = sommets[u]
        l2, a2, j2 = sommets[v]
        return instance.rendements[l2, a2, j1, j2]
    end

    x = @variable(model, x[u=1:N, v=1:N, t=1:T, p=1:P; is_legal(u, v, t)], Bin)

    @objective(model, Min, sum(x[instance.initial_l[p], v, 1, p] for p=1:P for v in delta_plus[instance.initial_l[p]] if is_legal(instance.initial_l[p], v, 1)))

    # TODO : check flow contrainte between T and 1
    @constraint(model, [p=1:P, u=1:N, t=1:T-1], sum(x[v, u, t, p] for v in delta_moins[u] if is_legal(v, u, t)) ==
                                               sum(x[u, v, t+1, p] for v in delta_plus[u] if is_legal(u, v, t+1)))

    @constraint(model, [j=1:C, t=1:T], sum(weight(u, v) * x[u, v, t, p] for p=1:P for v=1:N for u in delta_moins[v] if sommets[v][3] == j && is_legal(u, v, t)) >= instance.demand[j, t])

    return model, x
end


function solve_model!(model::Model, x::Any)
    optimize!(model)
    return objective_value(model), value.(x)
end


function plne(instance::Instance)
    model, x = generate_model(instance)
    objective, x = solve_model!(model, x)

    println("objective value: ", objective)
    println("x: ", x)
    return objective, x
end
