using CPLEX
using JuMP

include("instance.jl")
include("model.jl")

function main()
    instance = create_instance()
    objective, x_values, nodes, time = plne(instance)
    return objective, x_values, nodes, time
end

objective, x_values, nodes, time = main()
println("Objective: $objective")
for (u, v, t, p) in eachindex(x_values)
    value = x_values[u, v, t, p]
    if t == 1 && u == 2 && value != 0
        println("$u, $v, $t, $p : $value")
    end
end
println("Nodes = $nodes")
println("Time = $time")
