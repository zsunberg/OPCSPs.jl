using Base.Test
using OPCSPs
using NearestNeighbors
using Distances
import OPCSPs: NearestStateMap, SimilarStateStruct, has_similar, get_nearest

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
