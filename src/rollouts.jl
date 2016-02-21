### Rollout policies for use with MCTS

import POMCP

## Open Loop

# # maybe I'll finish this later, but it doesn't seem that necessary for now
# type NonAdaptive <: Solver end
# 
# function solve(s::NonAdaptive, p::OPCSP, pol::StaticPath=StaticPath(Array(Int,0)))
#     
# end
# 
# type StaticPath <: Policy
#     d::Dict{Int, Int} # maps current node to next
# end
# function StaticPath(Array
# 
# function action(p::StaticPath, b::OPCSPDistribution, act::OPCSPAction=OPCSPAction(0))
#     
# end

## Open loop value estimate
# set the value_estimate_method of the POMCPSolver to use this
function POMCP.estimate_value(pomcp::POMCP.POMCPPolicy, op::OPCSP, s::OPCSPState, h::POMCP.BeliefNode)
    @assert s.remaining == h.B.remaining
    openset = cat(1, s.i, collect(s.open))
    if pomcp.solver.value_estimate_method == :OPCSPMostLikely
        mean_future = SimpleOP(op.r[openset] + d_belief.mean[openset],
                          [],
                          s.remaining,
                          1,
                          findfirst(openset, op.stop),
                          op.distances[openset, openset])
        soln = solve_op(mean_future)
        path = build_path(mean_future, soln)
        return reward(mean_future, path)
    elseif pomcp.solver.value_estimate_method == :OPCSPCheat
        cheat_future = SimpleOP(op.r[openset] + s.mu[openset],
                                [],
                                s.remaining,
                                1,
                                findfirst(openset, op.stop),
                                op.distances[openset, openset])
        soln = solve_op(cheat_future)
        path = build_path(cheat_future, soln)
        return reward(cheat_future, path)
    else
        return POMCP.rollout(pomcp, s, h)
    end
end
