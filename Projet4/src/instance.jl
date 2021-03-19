struct Instance
    t::Array{Float64, 2} # size M x N
    w1::Float64
    w2::Float64
    g::Float64
    l::Float64

    function Instance(
        t::Array{Float64, 2},
        w1::Float64,
        w2::Float64,
        g::Float64,
        l::Float64,
    )
        new(t, w1, w2, g, l)
    end
end


function create_instance()
    return 0
end


function create_random_instance()
    return 0
end
