using Random, Distributions

struct Instance
    d::Array{Float64, 1}
    h::Array{Int64, 1}
    p::Array{Int64, 2}
    f::Array{Int64, 2}
    e::Array{Int64, 2}
    Emax::Int64

    function Instance(
        d::Array{Float64, 1},
        h::Array{Int64, 1},
        p::Array{Int64, 2},
        f::Array{Int64, 2},
        e::Array{Int64, 2},
        Emax::Int64,
    )
        new(
            d,
            h,
            p,
            f,
            e,
            Emax,
        )
    end
end

function create_instance(T)
    Emax = 3

    M = 4

    d = Array{Float64, 1}(rand(Uniform(20, 70), T))
    h = Array{Int64, 1}(ones(T))
    p = Array{Int64, 2}(zeros(T, M))

    f = Array{Int64, 2}(zeros(T, M))
    e = Array{Int64, 2}(zeros(T, M))

    for t=1:T
        f[t, :] = [10, 30, 60, 90]
        e[t, :] = [8, 6, 4, 2]
    end

    return Instance(d, h, p, f, e, Emax)
end

