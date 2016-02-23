# variations on the feedback policy

# Stephan's suggestion
type SolveSampledFeedback <: Policy
    problem::OPCSP
    solver::OPSolver
    rng::AbstractRNG
end
updater(p::SolveSampledFeedback) = OPCSPUpdater(p.problem)
type SampledFeedbackSolver <: Solver
    solver::OPSolver
    rng::AbstractRNG
end
POMDPs.solve(s::SampledFeedbackSolver, p::OPCSP) = SolveSampledFeedback(p, s.solver, s.rng)

function sampled_problem(op::OPCSP, b::OPCSPDistribution, rng::AbstractRNG)
    samp = rand!(rng, create_state(op), b)
    openset = cat(1, b.i, collect(b.open))
    samp_op = SimpleOP(op.r[openset]+samp.d[openset],
                       [],
                       b.remaining,
                       1,
                       findfirst(openset, op.stop),
                       op.distances[openset, openset])
    return SubsetOP(openset, samp_op)
end

function action(p::SolveSampledFeedback, b::Union{OPCSPDistribution,OPCSPBelief}, act::OPCSPAction=OPCSPAction(0))
    sp = sampled_problem(p.problem, b, p.rng)
    act.next = first_move(p.solver, sp)
    return act
end

# Try to have a bonus for the influence
type SolveInfluenceBonusFB <: Policy
    problem::OPCSP
    factor::Float64
end
updater(p::SolveInfluenceBonusFB) = OPCSPUpdater(p.problem)
type InfluenceBonusFBSolver <: Solver
    factor::Float64
end
POMDPs.solve(s::InfluenceBonusFBSolver, p::OPCSP) = SolveInfluenceBonusFB(p, s.factor)

function action(p::SolveInfluenceBonusFB, b::OPCSPDistribution, act::OPCSPAction=OPCSPAction(0))
    tail = tail_opcsp(p.problem, b)
    path = build_path(tail.op, solve_influence_bonus(tail.op, p.factor*b.remaining/p.problem.distance_limit))
    act.next = tail.included_nodes[path[2]]
    return act
end

function tail_opcsp(op::OPCSP, b::OPCSPDistribution)
    openset = cat(1, b.i, collect(b.open))
    tail = OPCSP(op.r[openset] + b.dist.mean[openset],
                 [],
                 b.dist.covariance[openset,openset],
                 b.remaining,
                 1,
                 findfirst(openset, op.stop),
                 op.distances[openset,openset])
    return SubsetOP(openset, tail)
end

function solve_influence_bonus(op::OPCSP, influence_factor::Float64)
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=false))
    N = length(op)

    # calculate influence
    influence = Array(Float64, length(op))
    for i in 1:length(op)
        if op.covariance[i,i] == 0.0
            influence[i] = 0.0
        else
            influence[i] = influence_factor*sum(abs(op.covariance[:,i]))/op.covariance[i,i]
        end
    end

    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    without_both = intersect(without_start, without_stop)

    @defVar(m, x[1:N,1:N], Bin)
    @defVar(m, 2 <= u[without_start] <= N, Int)

    # @setObjective(m, Max, sum{ sum{op.r[i]*x[i,j], j=1:N}, i=1:N })
    @setObjective(m, Max, sum{ sum{op.r[i]*x[i,j], j=1:N}, i=1:N } + sum{ influence[j]*x[op.start,j], j=1:N })

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1)

    @addConstraint(m, connectivity[k=without_both], sum{x[i,k], i=1:N} == sum{x[k,j], j=1:N})

    @addConstraint(m, once[k=1:N], sum{x[k,j], j=1:N} <= 1)
    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit)
    @addConstraint(m, nosubtour[i=without_start,j=without_start], u[i]-u[j]+1 <= (N-1)*(1-x[i,j]))

    if op.start != op.stop
        @addConstraint(m, sum{x[op.stop,i],i=1:N} == 0)
    end

    status = JuMP.solve(m)

    if status != :Optimal
        warn("Not solved to optimality:\n$op")
    end

    soln = OPSolution(getValue(x), getValue(u))

    if distance(op,build_path(op,soln)) > op.distance_limit
        warn("Path Length: $(distance(op,build_path(op,soln))), Limit: $(op.distance_limit)")
    end
    return soln

end
