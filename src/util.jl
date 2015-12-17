Base.length(op::OrienteeringProblem) = length(op.r)
# reward(op::OrienteeringProblem, path::Vector{Int}) = sum([op.r[i] for i in path])
distance(op::OrienteeringProblem, path::Vector{Int}) = sum([op.distances[path[i],path[i+1]] for i in 1:length(path)-1])

function find_distances(positions)
    distances = Array(Float64, length(positions), length(positions))
    for i in 1:length(positions)
        for j in 1:length(positions)
            distances[i,j] = norm(positions[i]-positions[j])
        end
    end
    return distances
end
