

struct Instance
    nb_autres_alleles::Array{Array{Int64, 1}, 2} #[individu, gène][allèle]
    is_male::Array{Bool, 1}

    function Instance(
        nb_autres_alleles::Array{Array{Int64, 1}, 2},
        is_male::Array{Bool, 1}
    )
        new(
        nb_autres_alleles,
        is_male)
    end
end

function create_theta(theta_1::Float64, H::Int64)
    return Array{Float64, 1}([theta_1^((H-r)/(H-1)) for r=1:H])
end

function create_instance()
    is_male = Array{Bool, 1}([1, 1, 1, 1, 0, 0, 0, 0])
    nb_autres_alleles = Array{Array{Int64, 1}, 1}([
    [1, 1], [0, 2], [1, 1], [1, 1], [1, 1],
    [2, 0], [1, 1], [1, 1], [1, 1], [0, 2],
    [2, 0], [1, 1], [1, 1], [1, 1], [1, 1],
    [2, 0], [0, 2], [1, 1], [2, 0], [2, 0],
    [1, 1], [0, 2], [0, 2], [2, 0], [1, 1],
    [1, 1], [0, 2], [2, 0], [1, 1], [1, 1],
    [0, 2], [0, 2], [2, 0], [0, 2], [0, 2],
    [2, 0], [0, 2], [2, 0], [1, 1], [2, 0],
    ])
    nb_autres_alleles = permutedims(reshape(nb_autres_alleles, (5, 8)))

    return Instance(nb_autres_alleles, is_male)
end
