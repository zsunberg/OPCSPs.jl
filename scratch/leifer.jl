# XXX this is not complete
function approx_path_leifer(op::OrienteeringProblem)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
    N = length(op)

    V = [1:N]
    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    Vprime = intersect(without_start, without_stop)

    @defVar(m, x[1:N,1:N], Bin) # (7)
    @defVar(m, y[1:N], Bin) # (8)

    @setObjective(m, Max, sum{ op.r[j]*y[j] j=1:N }) # (1)

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1) # (2)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1) # (3)

    @addConstraint(m, conservation[j=Vprime], sum{x[i,j],i=1:N} + sum{x[j,k],k=1:N} == 2*y[j]) # (4)

    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit) # (5)

    status = solve(m)

    # if status != :Optimal
    #     @bp
    # end
    if status != :Optimal
        warn("Not solved to optimality:\n$op")
    end

    # @show getObjectiveValue(m)
    # @show getValue(x)
    # @show getValue(u)

    path = [op.start]
    current = -1
    dist_sum = 0.0
    xopt = round(Int,getValue(x))
    while current != op.stop
        if current==-1
            current=op.start
        end
        current = findfirst(xopt[current,:])
        push!(path, current)
    end
    # @assert(distance(op, path) <= op.distance_limit)
    if distance(op,path) > op.distance_limit
        warn("Path Length: $(distance(op,path)), Limit: $(op.distance_limit)")
    end
    return path
end

