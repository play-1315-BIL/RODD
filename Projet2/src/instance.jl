struct Instance
    nb_parcels::Int64
    area_min::Float64
    area_max::Float64
    budget::Float64
    costs::Array{Float64, 1}
    areas::Array{Float64, 1}
    distances::Array{Float64, 2}
end

"""
Create an instance from data inputs
"""
function create_instance(costs_grid::Array{Float64, 2}, area_min::Float64, area_max::Float64, budget::Float64)
    nb_parcels = size(costs_grid)[1] * size(costs_grid)[2]
    costs = Array{Float64, 1}(zeros(nb_parcels))
    distances = Array{Float64, 2}(zeros(nb_parcels, nb_parcels))
    areas = Array{Float64, 1}(ones(nb_parcels))

    for index=1:nb_parcels
        i = trunc(Int64, (index - 1) / size(costs_grid)[2]) + 1
        j = (index - 1) % size(costs_grid)[2] + 1
        costs[index] = costs_grid[i, j] * 10

        for jndex=1:nb_parcels
            k = trunc(Int64, (jndex - 1) / size(costs_grid)[2]) + 1
            l = (jndex - 1) % size(costs_grid)[2] + 1
            # distances[index, jndex] = abs(i - k) + abs(j - l)
            distances[index, jndex] = sqrt((i - k)^2 + (j - l)^2)
        end
    end

    return Instance(nb_parcels, area_min, area_max, budget, costs, areas, distances)
end


"""
Create a random instance of size edge_size
"""
function create_random_instance(edge_size::Int64)
    costs_grid = floor.(rand(edge_size, edge_size) * 10) .+ 1
    area_max = floor(edge_size^2 / 2)# 2 + floor(rand() * (edge_size^2 - 2))
    area_min = area_max # max(2, 1 + floor(rand() * area_max))

    # budget = max(area_min * 3, rand() * (edge_size^2 * 2)) * 10

    budget = sum(sample(costs_grid, Int(area_min))) * 5

    return create_instance(costs_grid, area_min, area_max, budget), area_min, area_max, budget
end
