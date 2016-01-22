using JuMP
using Gurobi

type OPModel
    m
    status
end

function create_model(op::OrienteeringProblem; output=0)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
    N = length(op)

    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    without_both = intersect(without_start, without_stop)

    @defVar(m, x[1:N,1:N], Bin)
    @defVar(m, 2 <= u[without_start] <= N)

    @setObjective(m, Max, sum{ sum{op.r[i]*x[i,j], j=1:N}, i=1:N })

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1)

    @addConstraint(m, connectivity[k=without_both], sum{x[i,k], i=1:N} == sum{x[k,j], j=1:N})

    @addConstraint(m, once[k=1:N], sum{x[k,j], j=1:N} <= 1)
    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit)
    @addConstraint(m, nosubtour[i=without_start,j=without_start], u[i]-u[j]+1 <= (N-1)*(1-x[i,j]))

    if op.start != op.stop
        @addConstraint(m, sum{x[op.stop,i],i=1:N} == 0)
    end

    return OPModel(m, :NotSolved)
end

function solve!(opm::OPModel)
    opm.status = solve(opm.m)
end 

type LeiferModel
    m
end

# returns a model with the phase one constraints
function create_leifer_model(op::OrienteeringProblem)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
    N = length(op)

    V = [1:N]
    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    Vprime = intersect(without_start, without_stop)

    # relaxed
    @defVar(m, 0 <= x[1:N,1:N] <= 1) # (7')
    @defVar(m, 0 <= y[1:N] <= 1) # (8')

    @setObjective(m, Max, sum{ op.r[j]*y[j] j=1:N }) # (1)

    ## Initial constraints

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1) # (2)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1) # (3)

    @addConstraint(m, conservation[j=Vprime], sum{x[i,j],i=1:N} + sum{x[j,k],k=1:N} == 2*y[j]) # (4)

    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit) # (5)

    ## Phase one constraints

    # (skip constraints from Theorm 1 for now)

    # Theorem 2

    # create suboptimal path

    # Theorem 3

    return LeiferModel(m)
end

function nearest_neighbor_heur(op::OrienteeringProblem)
    p = [op.start, op.stop]
    ti = 1
    ui = 2

    c = op.distances
    s = Set{Int}(Vprime)
    len = distance(op,p)
    ctu = c[p[ti],p[ui]]
    margin = op.distance_limit - len + ctu
    filter!(k->c[p[ti],k]+c[k,p[ui]]<=margin, s)

    while !isempty(S)
        (imaxval, imax) = findmax([op.r[i]/c[p[ti],i] for i in s])
        (jmaxval, jmax) = findmax([op.r[j]/c[j,p[tu]] for j in s])
        if imaxval > jmaxval 
            insert!(p, ti+1, imax)
            ti += 1
        else
            insert!(p, ui, jmax)
        end

        len = distance(op,p)
        ctu = c[p[ti],p[ui]]
        margin = op.distance_limit - len + ctu
        filter!(k->c[p[ti],k]+c[k,p[ui]]<=margin, s)
    end
    
    return p
end
