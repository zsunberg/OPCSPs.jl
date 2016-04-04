Base.length(op::SimpleOP) = length(op.r)
Base.length(op::OPCSP) = length(op.r)
distance(op, path::Vector{Int}) = sum([op.distances[path[i],path[i+1]] for i in 1:length(path)-1])

function find_distances(positions)
    distances = Array(Float64, length(positions), length(positions))
    for i in 1:length(positions)
        for j in 1:length(positions)
            distances[i,j] = norm(positions[i]-positions[j])
        end
    end
    return distances
end

within_range(op, start, stop, j, dist) = op.distances[start,j] + op.distances[j,stop] <= dist
within_range(op, j) = within_range(op, op.start, op.stop, j, op.distance_limit)


# code for quickly finding similar states
type SimilarStateStruct{T}
    feasible::BitArray{1}
    exact::Dict{Vector{Float64}, Int}
    vec::Vector{T}
    tree::KDTree
end

function SimilarStateStruct{T}(op, s, object::T)
    feasible = falses(length(op))
    for j in s.open
        if j != op.stop && within_range(op, s.i, op.stop, j, s.remaining)
            feasible[j] = true
        end
    end
    relevant = get_d(s)[feasible]
    tree = KDTree(reshape(relevant,sum(feasible),1),Cityblock())
    return SimilarStateStruct{T}(feasible,
                                 Dict{Vector{Float64}, Int}(relevant=>1),
                                 T[object],
                                 tree)
end

typealias SimilarStateDict{T} Dict{Tuple{Int,Float64,IntSet}, SimilarStateStruct{T}}

type NearestStateMap{T}
    data::SimilarStateDict{T}
    op::Union{OPCSP, OPCSPBeliefMDP}

    NearestStateMap(d, op) = new(d,op)
    NearestStateMap() = new()
end
NearestStateMap{T}(t::Type{T}, op) = NearestStateMap{T}(SimilarStateDict{T}(), op)

function has_similar(m::NearestStateMap, s)
    return haskey(m.data, (s.i, s.remaining, s.open))
end

function get_nearest(m::NearestStateMap, s)
    similar = m.data[(s.i, s.remaining, s.open)]
    relevant = get_d(s)[similar.feasible]
    ind = get(similar.exact, relevant, -1)
    if ind > 0
        return (similar.vec[ind],0.0)
    end
    idxs, dists = knn(similar.tree, relevant, 1)
    return (similar.vec[idxs[1]], dists[1])
end

function Base.insert!{T}(m::NearestStateMap{T}, s, object::T)
    key = (s.i, s.remaining, s.open)
    if haskey(m.data, key)
        similar = m.data[key]
    else
        similar = m.data[key] = SimilarStateStruct(m.op, s, object)
        return true
    end
    relevant = get_d(s)[similar.feasible]
    if haskey(similar.exact, relevant)
        @assert similar.exact[relevant] == object
        return false
    end
    push!(similar.vec, object)
    similar.exact[relevant] = length(similar.vec)
    newdata = hcat(similar.tree.data, relevant)
    similar.tree = KDTree(newdata, Cityblock())
    return true
end


