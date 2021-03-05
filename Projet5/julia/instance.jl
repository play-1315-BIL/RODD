using Distributions

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

# function generate_grid_graph(protection_cost::Array{Int64, 2}, given_survival_probability::Array{Float64, 2}, K::Int64)
#     width = size(protection_cost)[1]
#     height = size(protection_cost)[2]
#     graph = Array{Bool, 2}(zeros((width * height, width * height)))
#     new_protection_cost = Array{Int64, 1}(zeros(width*height))
#     is_edge = Array{Bool, 1}(zeros(width*height))
#     for i = 1:width
#         for j = 1:height
#             for k = 1:width
#                 for l = 1:height
#                     if max(abs(i - k), abs(j - l)) == 1
#                         graph[(i-1)*height + j, (k-1)*height + l] = true
#                     end
#                 end
#             end
#             if i == 1 || i == width || j == 1 || j == height
#                 is_edge[(i-1)*height + j] == true
#             end

#             new_protection_cost[(i-1)*height + j] = protection_cost[i, j]
#         end
#     end

#     survival_probability = Array{Float64, 2}(zeros((K, width*height)))

#     for index = 1:size(given_survival_probability)[1]
#         k = Int64(given_survival_probability[index, 1])
#         i = Int64(given_survival_probability[index, 2])
#         j = Int64(given_survival_probability[index, 3])
#         p = given_survival_probability[index, 4]
#         survival_probability[k, (i-1)*height + j] = p
#     end

#     return graph, new_protection_cost, survival_probability, is_edge
# end

# function create_instance(required_survival_probability::Array{Float64, 1})
#     number_species = Int64(6)

#     grid_protection_cost = Array{Int64, 2}([
#         6 6 6 4 4 4 4 8 8 8;
#         6 6 6 4 4 4 4 8 8 8;
#         6 6 6 4 4 4 4 8 8 8;
#         5 5 5 3 3 3 3 7 7 7;
#         5 5 5 3 3 3 3 7 7 7;
#         5 5 5 3 3 3 3 7 7 7;
#         5 5 5 3 3 3 3 7 7 7;
#         4 4 4 6 6 6 6 5 5 5;
#         4 4 4 6 6 6 6 5 5 5;
#         4 4 4 6 6 6 6 5 5 5;
#     ])

#     is_in_danger = Array{Bool, 1}([1, 1, 1, 0, 0, 0])

    

#     given_survival_probability = Array{Float64, 2}([
#         1 4 3 0.4;
#         1 5 3 0.3;
#         1 6 2 0.4;
#         1 8 6 0.3;
#         1 8 7 0.2;
#         1 9 5 0.2;
#         1 9 6 0.4;   
#         2 2 7 0.2;
#         2 3 7 0.4;
#         2 4 7 0.2;
#         2 5 9 0.4;
#         2 5 10 0.3;
#         2 7 2 0.5;
#         2 9 6 0.2;
#         2 9 7 0.2;  
#         3 2 4 0.2;
#         3 2 5 0.3;
#         3 2 7 0.4;
#         3 3 7 0.4;
#         3 4 7 0.5;
#         3 5 9 0.2;
#         3 5 10 0.4;
#         3 9 2 0.3;   
#         4 1 2 0.3;
#         4 1 4 0.3;
#         4 3 2 0.4;
#         4 4 3 0.4;
#         4 5 1 0.3;
#         4 5 3 0.2;
#         4 5 5 0.2;
#         4 6 2 0.2;
#         4 6 3 0.4;
#         4 7 5 0.4;
#         4 7 9 0.3;
#         4 8 7 0.2;
#         4 8 9 0.5;
#         4 9 7 0.4; 
#         5 1 10 0.4;
#         5 2 1 0.3;
#         5 2 10 0.3;
#         5 3 5 0.5;
#         5 6 3 0.4;
#         5 6 6 0.2;
#         5 6 7 0.2;
#         5 7 5 0.4;
#         5 7 9 0.5;
#         5 8 9 0.4;
#         5 9 2 0.5;
#         5 9 3 0.2;
#         5 9 4 0.4;
#         5 9 5 0.4;    
#         6 1 3 0.4;
#         6 1 4 0.4;
#         6 1 6 0.5;
#         6 1 7 0.3;
#         6 1 8 0.3;
#         6 2 9 0.2;
#         6 3 5 0.4;
#         6 3 9 0.4;
#         6 3 10 0.2;
#         6 4 9 0.3;
#         6 5 5 0.4;
#         6 8 1 0.5;
#         6 9 1 0.2;
#         6 10 3 0.2;
#     ])

#     parcel_graph, protection_cost, survival_probability, is_edge = generate_grid_graph(grid_protection_cost, given_survival_probability, number_species)

#     return Instance(parcel_graph, is_in_danger, survival_probability, protection_cost, required_survival_probability, is_edge)
# end
