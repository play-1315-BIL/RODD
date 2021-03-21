struct Instance
    t::Array{Float64, 2} # size M x N
    w1::Float64
    w2::Float64
    g::Float64
    l::Float64
end

function create_random_instance(edge_size::Int64)
    t = floor.(rand(edge_size, edge_size) * 100) .+ 1
    w1 = 1
    w2 = 1
    # g = 1.26157
    g = 1
    l = 3
    return Instance(t, w1, w2, g, l)
end
