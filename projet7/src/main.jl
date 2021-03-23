using CPLEX
using JuMP

include("instance.jl")
include("model.jl")

function main()
    instance = create_instance()
    objective, x_values = plne(instance)
    return objective, x_values
end

objective, x_values = main()
println("Objective: $objective")
for (u, v, t, p) in eachindex(x_values)
    value = x_values[u, v, t, p]
    if t == 1 && u == 2 && value != 0
        println("$u, $v, $t, $p : $value")
    end
end
