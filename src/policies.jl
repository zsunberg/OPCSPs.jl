
## Best feedback policy
type SolveMeanFeedback <: Policy
    problem::Union{OPCSP, OPCSPBeliefMDP}
    solver::OPSolver
end
updater(p::SolveMeanFeedback) = OPCSPUpdater(p.problem)
type FeedbackSolver <: Solver
    solver::OPSolver
end
POMDPs.solve(s::FeedbackSolver, p::Union{OPCSP, OPCSPBeliefMDP}) = SolveMeanFeedback(p, s.solver)

type SubsetOP
    included_nodes::Vector{Int}
    op
end

# PERF: use logical indexing (?)
function tail_problem(op::Union{OPCSP,OPCSPBeliefMDP}, b::Union{OPCSPDistribution, OPCSPBelief};
                      prohibit_first=Int[]) # the solver will not be allowed to visit these nodes first (accomplished by increasing the distance beyond the limit)
    # openset = cat(1, b.i, collect(b.open))
    # below filters only positive nodes
    positive = filter(i -> op.r[i]+b.dist.mean[i]>0.0 || i==op.stop, b.open)
    # below gaurantees that we only consider feasible nodes
    feasible = filter(j -> within_range(op, b.i, op.stop, j, b.remaining), positive)
    openset = cat(1, b.i, collect(feasible))
    @assert length(find(i->i==op.stop, openset))==1
    mean_op = SimpleOP(op.r[openset]+b.dist.mean[openset],
                       [],
                       b.remaining,
                       1,
                       findfirst(openset, op.stop),
                       op.distances[openset, openset])
    if !isempty(prohibit_first)
        mean_op.distances = copy(mean_op.distances)
        for p in prohibit_first
            j = findfirst(openset, p)
            mean_op.distances[1,j] = 2.0*mean_op.distance_limit;
            mean_op.distances[j,1] = 2.0*mean_op.distance_limit;
        end
    end
    return SubsetOP(openset, mean_op)
end

function first_move(solver::OPSolver, sop::SubsetOP)
    subset_path = solve_op(solver, sop.op)
    return sop.included_nodes[subset_path[2]]
end

function action(p::SolveMeanFeedback, b::Union{OPCSPDistribution,OPCSPBelief}, act::OPCSPAction=OPCSPAction(0))
    tail = tail_problem(p.problem,b)
    if length(tail.included_nodes) == 2
        act.next = tail.included_nodes[2]
        return act
    elseif length(tail.included_nodes) == 3 # since the nodes must have positive expected rewards, this is the optimal solution
        if tail.included_nodes[3]==p.problem.stop
            act.next = tail.included_nodes[2]
        else # included_nodes[2] is op.stop
            act.next = tail.included_nodes[3]
        end
        return act
    else
        act.next = first_move(p.solver, tail)
        return act
    end
    # act.next = first_move(p.solver, tail)
    # return act
end

## 
# A policy for an OPCSP POMDP
# uses an OPCSPUpdater, so every time it needs to choose an action, it gets an OPCSPDistribution
# which corresponds to an OPCSPBelief. This can be fed into the MCTSSolver with the OPCSPBeliefMDP as its model
type MCTSAdapter <: Policy
    pol::Policy
end

function action(p::MCTSAdapter, b::OPCSPDistribution, act::OPCSPAction=OPCSPAction(0))
    s = OPCSPBelief(b)
    op = p.pol.mdp
    acts = collect(actions(op, s))
    if length(acts) == 1
        act.next = acts[1].next
        return act
    elseif length(acts) == 2
        notstop = acts[1].next == op.stop ? 2 : 1
        act.next = op.r[notstop]+s.dist.mean[notstop] > 0.0 ? notstop : op.stop
        return act
    end
    return action(p.pol, s)
end
# updater(p::MCTSAdapter) = OPCSPUpdater(p.mcts.mdp)
