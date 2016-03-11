using Base.Test
using OPCSPs
using NearestNeighbors
using Distances
import OPCSPs: NearestStateMap, SimilarStateStruct
# import OPCSPs: NearestStateMap, SimilarStateStruct, has_similar, get_nearest

function has_similar(m::NearestStateMap, s)
    return haskey(m.data, (s.i, s.remaining, s.open))
end

function get_nearest(m::NearestStateMap, s)
    similar = m.data[(s.i, s.remaining, s.open)]
    relevant = s.d[similar.feasible]
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
    relevant = s.d[similar.feasible]
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



rng = MersenneTwister(1)
op = gen_problem()
m = NearestStateMap(op, Int)

s1 = OPCSPState(1, IntSet([4, 5, 6]), 5.0, randn(rng, length(op)))
s2 = OPCSPState(1, IntSet([4, 5, 6]), 5.0, randn(rng, length(op)))

insert!(m, s1, 1)
insert!(m, s2, 2)

@test has_similar(m, s1)

near, dist = get_nearest(m, s1)
@test near == 1
@test dist == 0.0

s3 = deepcopy(s2)
s3.d[4] += 0.01
near, dist = get_nearest(m, s3)
@test near == 2
@test_approx_eq dist 0.01
