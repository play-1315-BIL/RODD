

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

function random_instance(number_males::Int64, number_genes::Int64)
    is_male = Array{Bool, 1}(vcat(ones(number_males), zeros(number_males)))

    nb_autres_alleles = []
    for k=1:(2*number_males)
        for i=1:number_genes
            random_integer = Int64(abs(rand(Int))%3)
            push!(nb_autres_alleles, [random_integer, 2-random_integer])
        end
    end
    nb_autres_alleles = Array{Array{Int64, 1}, 2}(permutedims(reshape(nb_autres_alleles, (number_genes, 2*number_males))))

    return Instance(nb_autres_alleles, is_male)
end
