using Base.Test

using OPCSPs
using OPCSPs.MVNTools

positions = Vector{Float64}[[0,0], [1,0], [1,1], [0,1], [0.5,0.5]]
r = [0.0, 10.0, 100.0, 1.0, 20.0]

covariance = diagm(ones(length(r)))

rng = MersenneTwister(1)
d = randn(rng, length(r))

op = OPCSP(r, d, positions, covariance, 3.0, 1, 4)
path = solve_op(op)
@test path==[1,5,3,4]

path = solve_opcsp_feedback(op)
@test path==[1,5,3,4]

covariance[3,2] = covariance[2,3] = 0.8
rng = MersenneTwister(2)
d = rand!(rng, Array(Float64, length(r)), MVN(zeros(length(r)), covariance))
op = OPCSP(r, d, positions, covariance, 3.0, 1, 4)
path = solve_opcsp_feedback(op)
@test path==[1,5,3,4]
