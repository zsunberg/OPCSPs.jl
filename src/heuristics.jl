
type HeuristicSolver <: OPSolver end

function solve_op(solver::HeuristicSolver, op)
    return simple_heur(op)
end

type PathOptions
    path::Vector{Int} 
    available::IntSet
    remaining::Float64
end

function simple_heur(op)
    d = op.distances
    start = op.start
    stop = op.stop
    # pick the furthest feasible point away
    feasible = collect(filter(j->within_range(op, j), 1:length(op)))
    if length(feasible) == 2 # only contains start and stop
        return [start, stop]
    end
    imax = indmax([d[start,i]+d[stop,i] for i in feasible])
    path = [start, feasible[imax], stop]
    available = setdiff(IntSet(filter(i->op.r[i]>0.0,1:length(op))),IntSet(path))
    remaining = op.distance_limit - distance(op, path)
    po = PathOptions(path, available, remaining)
    while insert_min!(po, d) end
    @assert abs(distance(op, path) + po.remaining - op.distance_limit) < 1e-5
    trade_better!(po, d, op.r, max_tries=div(length(available),2), op=op)
    @assert abs(distance(op, path) + po.remaining - op.distance_limit) < 1e-5
    return path
end

# start simple
# XXX rolled this into simple_heur
# function construct_cheap(op::SimpleOP)
#     d = op.distances
#     start = op.start
#     stop = op.stop
#     # pick the furthest feasible point away
#     feasible = collect(filter(j->within_range(op, j), 1:length(op)))
#     if length(feasible) == 2 # only contains start and stop
#         return [start, stop]
#     end
#     imax = indmax([d[start,i]+d[stop,i] for i in feasible])
#     path = [start, feasible[imax], stop]
#     available = setdiff(IntSet(1:length(op)),IntSet(path))
#     remaining = op.distance_limit - distance(op, path)
#     po = PathOptions(path, available, remaining)
#     while insert_min!(po, d) end
#     return path
# end

# insert the node with the minimum cost of insertion (regardless of price)
function insert_min!(po::PathOptions, d)
    p = po.path # for conciseness
    mindelta = po.remaining
    imin = 0
    jmin = 0
    for j in po.available
        for i in 2:length(p)
            delta = d[p[i-1],j] + d[j,p[i]] - d[p[i-1],p[i]]
            if delta <= mindelta
                imin = i
                jmin = j
                mindelta = delta
            end
        end
    end
    if jmin > 0
        delete!(po.available, jmin)
        insert!(p, imin, jmin)
        po.remaining -= mindelta
        return true
    end
    return false
end

# XXX get rid of op
function trade_better!(po::PathOptions, d, r; max_tries=typemax(Int), op=nothing)
    p = po.path # for conciseness
    potential = copy(po.available)
    trade = false
    tries = 0
    delta(i,b) = d[p[i-1],b] + d[b,p[i]] - d[p[i-1],p[i]] # change in distance if b is inserted
    deldelta(p,i) = d[p[i-1],p[i+1]] - (d[p[i-1],p[i]] + d[p[i],p[i+1]]) # change in distance if node at i is deleted
    while !isempty(potential) && tries <= max_tries
        b = reduce((i,j)->r[i]>=r[j]?i:j, potential)
        # find best place to insert
        i = reduce((i,j)->delta(i,b)>=delta(j,b)?i:j, 2:length(p))
        # insert
        bdelta = delta(i,b)
        insert!(p, i, b)
        # see if we can get back under budget by removing a cheaper node
        # first find all the removals that would put us back under budget
        under_budget = filter(i->po.remaining-bdelta-deldelta(p,i)>=0, 2:length(p)-1)
        # next find the cheapest of these removals
        j = reduce((i,j)->r[p[i]]<r[p[j]]?i:j, under_budget)
        # if this is not the one we just added, we have made a good trade
        if p[j] != b
            trade = true
            delete!(po.available, b)
            push!(po.available, p[j])
            po.remaining -= (bdelta+deldelta(p,j))
        end
        deleteat!(p,j)
        delete!(potential, b)
        tries += 1
    end
    return trade
end
