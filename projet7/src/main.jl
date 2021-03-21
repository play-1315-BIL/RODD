using CPLEX
using JuMP

include("instance.jl")
include("model.jl")

function main()
    instance = create_instance()
    objective, x_values = plne(instance)
end

main()
