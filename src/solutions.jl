using JuMP
using Gurobi

function solve_op(op::OrienteeringProblem; output=0, relax=false)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
    N = length(op)

    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    without_both = intersect(without_start, without_stop)

    if relax
        @defVar(m, 0 <= x[1:N,1:N] <= 1)
        @defVar(m, 2 <= u[without_start] <= N)
    else
        @defVar(m, x[1:N,1:N], Bin)
        @defVar(m, 2 <= u[without_start] <= N, Int)
    end

    @setObjective(m, Max, sum{ sum{op.r[i]*x[i,j], j=1:N}, i=1:N })

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1)
    # problem

    @addConstraint(m, connectivity[k=without_both], sum{x[i,k], i=1:N} == sum{x[k,j], j=1:N})

    @addConstraint(m, once[k=1:N], sum{x[k,j], j=1:N} <= 1)
    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit)
    @addConstraint(m, nosubtour[i=without_start,j=without_start], u[i]-u[j]+1 <= (N-1)*(1-x[i,j]))

    if op.start != op.stop
        @addConstraint(m, sum{x[op.stop,i],i=1:N} == 0)
    end

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

function solve_op_heur(op::OrienteeringProblem; rng=nothing)
    openset = [1:length(op)]
    total_dist = 0.0
    @assert op.start != op.stop # code may not work for this case 
    choice = -1
    path = [op.start]
    current = op.start
    while current != op.stop
        future = SimpleOP(op.r[openset],
                          [],
                          op.distance_limit-total_dist,
                          findfirst(openset,path[end]),
                          findfirst(openset,op.stop),
                          op.distances[openset,openset])
        choice = next_node_heur(future, rng=rng)
        choice = openset[choice]
        total_dist += op.distances[path[end],choice]
        @show push!(path,choice)
        splice!(openset,current)
        current = choice
    end
    return path
end

# S-algorithm from Tsiligirides 1984
function next_node_heur(op::OrienteeringProblem; rng=nothing)
    if rng==nothing
        rng = MersenneTwister(rand(Uint))
    end

    @assert op.start != op.stop

    is_feasible(i) = op.distances[op.start,i]+op.distances[i,op.stop]<=op.distance_limit
    feasible = nothing
    # try
    #     feasible = filter(is_feasible, [1:op.start-1, op.start+1:length(op)])
    # catch e
    #     @bp
    # end
    feasible = filter(is_feasible, [1:op.start-1, op.start+1:length(op)])
    @assert length(feasible) > 0
    
    # Tsiligiride's notation

    T_max = op.distance_limit
    T = 0.0
    S = op.r
    C = op.distances
    NPTS = length(op)
    LAST = op.start

    # r = 2.0
    r = 1.0
    a = 0.0

    # DEL(j) = sum([S[i]/C[j,i] for i in feasible])
    # E(j) = a*(T_max - T - C(LAST,j) - C(j,op.stop))*DEL(j)
    E(j) = 0.0 # because a = 0.0 was used

    A = zeros(length(op))
    for j in 1:length(A)
        if is_feasible(j) && j != op.start
            A[j] = ((S[j] + E(j))/C[op.start,j])^r
        end
    end

    sum_A = sum(A)
    P = [A[j]/sum_A for j in 1:length(op)]

    rn = rand(rng)
    accum = P[1]
    decision = 1
    while accum < rn
        decision += 1
        accum += P[decision]
    end
    return decision
end

function solve_opcsp_feedback(op::OPCSP)
    d_belief = MVN(zeros(length(op)), copy(op.covariance))
    openset = collect(1:length(op))
    total_dist = 0.0
    choice = -1
    path = [op.start]
    apply_measurement!(d_belief, op.start, op.d[op.start])
    while choice != op.stop
        # @show 1/length(openset)*sum(abs(d_belief.mean - op.d))
        mean_future = SimpleOP(op.r[openset] + d_belief.mean[openset],
                          [],
                          op.distance_limit-total_dist,
                          findfirst(openset, path[end]),
                          findfirst(openset, op.stop),
                          op.distances[openset, openset])
        mpc_path = solve_op(mean_future)
        choice = openset[mpc_path[2]]
        total_dist += op.distances[path[end], choice]
        push!(path, choice)
        splice!(openset, mpc_path[1])
        apply_measurement!(d_belief, choice, op.d[choice])
    end
    return path
end

function cheat(op::OPCSP)
    complete_knowledge = SimpleOP(op.r+op.d, op.positions, op.distance_limit, op.start, op.stop)
    return solve_op(complete_knowledge)
end
