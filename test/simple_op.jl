using Base.Test

using OPCSPs

positions = Vector{Float64}[[0,0], [1,0], [1,1], [0,1], [0.5,0.5]]
r = [0.0, 10.0, 100.0, 1.0, 20.0]

op = SimpleOP(r, positions, 3.0, 1, 4)
path = solve_op(op)
@test path==[1,5,3,4]

op = SimpleOP(r, positions, 2.7, 2, 1)
path = solve_op(op)
@test path==[2,3,5,1]
