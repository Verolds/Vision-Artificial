### ALGORITMO KNN

function find_k_nearest_neighbors(k::Int64, classes, point)
    distances = Dict() # Initialize an empty dictionary

    for (key, cords) = classes
        for cord in eachcol(cords)
            distance = get_eucledian_distance(point, cord)
            distances[(key, cord)] = distance
        end
    end

    distances = sort(collect(distances), by=x->x[2])

    return distances[1:k]
end

function predict_using_knn(k::Int64, classes, point)
    k_nn = find_k_nearest_neighbors(k, classes, point)
    
    votes = Dict()
    
    for i in 0:k-1
        votes[string(i)] = 0
    end

    for (key, _) = k_nn
        votes[key[1]] += 1
    end

    predicted_class = ""

    max_class = maximum(values(votes))
    
    for (key, value) = votes
        if (value == max_class)
            predicted_class = key
            break
        end
    end

    return predicted_class
    
end

# Distancia euclidiana entre dos puntos
get_eucledian_distance(pointA, pointB) = sqrt(sum((pointA .- pointB).^2))