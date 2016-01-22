using JuMP

function create_mip_without_subtour(op::OrienteeringProblem; output=0)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
    N = length(op)

    V = 1:N
    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    Vprime = intersect(without_start, without_stop)

    @defVar(m, x[1:N,1:N], Bin) # (7)
    @defVar(m, y[1:N], Bin) # (8)

    @setObjective(m, Max, sum{ op.r[j]*y[j], j=1:N }) # (1)

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1) # (2)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1) # (3)

    @addConstraint(m, conservation[j=Vprime], sum{x[i,j],i=1:N} + sum{x[j,k],k=1:N} == 2*y[j]) # (4)

    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit) # (5)

    return m
end
