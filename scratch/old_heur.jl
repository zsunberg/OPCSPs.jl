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
