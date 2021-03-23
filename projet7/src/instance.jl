struct Instance
    T::Int64
    P::Int64
    a_max::Int64
    l_max::Int64
    C1::Int64
    C2::Int64
    demand::Array{Int64,2} # demand[j, t]
    precedence::Array{Array{Int64,1},1} # precedence[j]
    rendements::Array{Int64,4}  # rendements[l, a, i, j]
    initial_states::Array{Int64,1}
end


function create_instance()
    T::Int64 = 10
    P::Int64 = 40
    a_max::Int64 = 2
    l_max::Int64 = 2
    C1::Int64 = 1
    C2::Int64 = 1
    demand::Array{Int64,2} = [
        1200 0 1200 0 1200 0 1200 0 1200 0;
        0 400 0 400 0 400 0 400 0 400;
    ]
    precedence::Array{Array{Int64,1},1} = [[2], [1]]
    rendements::Array{Int64,4} = zeros(l_max, a_max + 1, C1 + C2 + 1, C1 + C2)
    rendements[1, 1, 3, 1] = 72
    rendements[2, 1, 3, 1] = 120
    rendements[1, 1, 3, 2] = 54
    rendements[2, 1, 3, 2] = 90
    rendements[1, 2, 2, 1] = 54
    rendements[2, 2, 2, 1] = 90
    rendements[1, 2, 1, 2] = 39
    rendements[2, 2, 1, 2] = 65

    return Instance(T, P, a_max, l_max, C1, C2, demand, precedence, rendements, [l_max for p = 1:P])
end

function graph_from_instance(instance::Instance)
    C = instance.C1 + instance.C2

    sommets = Array{Tuple{Int64,Int64,Int64}}([])
    for l = 1:instance.l_max
        push!(sommets, (l, instance.a_max + 1, C + 1))
    end
    for l = 1:instance.l_max
        for a = 1:instance.a_max
            for j = 1:C
                push!(sommets, (l, a, j))
            end
        end
    end

    nb_sommets = size(sommets)[1]

    delta_plus = Array{Array{Int64,1},1}([[] for i = 1:nb_sommets])
    delta_moins = Array{Array{Int64,1},1}([[] for i = 1:nb_sommets])
    adj = Array{Bool,2}(zeros(nb_sommets, nb_sommets))

    for (index1, sommet1) in enumerate(sommets)
        for (index2, sommet2) in enumerate(sommets)
            l1, a1, j1 = sommet1
            l2, a2, j2 = sommet2

            if sommet1[2:end] == (C + 1, C + 1) && sommet2[2:end] == (C + 1, C + 1) && l2 == min(l1 + 1, instance.l_max)
                # jachere -> jachere
                push!(delta_plus[index1], index2)
                push!(delta_moins[index2], index1)
                adj[index1, index2] = 1
            elseif sommet2 == (1, C + 1, C + 1) && j1 != C + 1
                # culture -> jachere
                push!(delta_plus[index1], index2)
                push!(delta_moins[index2], index1)
                adj[index1, index2] = 1
            elseif sommet1[2:end] == (C + 1, C + 1) && l1 == l2 && a2 == 1
                # jachere -> culture
                push!(delta_plus[index1], index2)
                push!(delta_moins[index2], index1)
                adj[index1, index2] = 1
            elseif a2 == a1 + 1 && l1 == l2 && j2 <= C && (j1 in instance.precedence[j2])
                # culture -> culture
                push!(delta_plus[index1], index2)
                push!(delta_moins[index2], index1)
                adj[index1, index2] = 1
            # else
            #     println(sommet1, ", ", sommet2)
            end
        end
    end

    return sommets, adj, delta_plus, delta_moins
end
