module OPCSPs

import POMDPs: POMDP, State, Action, Observation, Belief, BeliefUpdater, AbstractSpace, Policy, Solver
import POMDPs: rand, actions, updater, initial_belief, iterator, isterminal
import POMDPs: rand! # TODO this shouldn't be necessary, but it is here to ease transition
import POMDPs: transition, observation, action, reward, update, discount
import POMDPs: create_state, create_observation, create_action, create_belief
import POMDPs: create_observation_distribution, create_transition_distribution
using POMDPs
import Base: ==, hash, length

import MCTS

import POMDPToolbox

include("MVNTools.jl")
using OPCSPs.MVNTools
using AutoHashEquals

export MVNTools

export OPCSP,
       SimpleOP,
       OPCSPBeliefMDP,
       SolveMeanFeedback,
       FeedbackSolver,
       OPCSPUpdater,
       OPSolution,
       OPCSPState,
       OPCSPAction,
       OPCSPBelief,
       HeuristicSolver,
       GurobiExactSolver,
       HeuristicActionGenerator,
       PreSolvedActionGenerator,
       MCTSAdapter,
       SampledFeedbackSolver,
       SolveSampledFeedback,
       InfluenceBonusFBSolver,
       SolveInfluenceBonusFB,
       Cheater,
       VaroniOPCSPAg

export solve_op,
       solve_opcsp_feedback,
       cheat,
       gen_opcsp,
       gen_op,
       gen_two_cluster_problem,
       gen_problem,
       updater,
       reward,
       distance,
       build_path,
       within_range,
       initial_state,
       gurobi_solve,
       evaluate_performance,
       test_run,
       initial_states



type SimpleOP
    r::Vector{Float64}
    positions::Vector{Vector{Float64}}
    distance_limit::Float64
    start::Int
    stop::Int
    distances::Matrix{Float64}
end
function SimpleOP(r, positions, distance_limit=1.0, start=1, stop=-1)
    if stop == -1
        stop = start
    end
    return SimpleOP(r, positions, distance_limit, start, stop, find_distances(positions))
end
reward(op::SimpleOP, path::Vector{Int}) = sum([op.r[i] for i in path])

type OPCSP <: POMDP
    r::Vector{Float64} # r bar
    # d::Vector{Float64}
    positions::Vector{Vector{Float64}}
    covariance::Matrix{Float64}
    distance_limit::Float64
    start::Int
    stop::Int
    distances::Matrix{Float64}
end
function OPCSP(r, positions, covariance, distance_limit=1.0, start=1, stop=-1)
    if stop == -1
        stop = start
    end
    return OPCSP(r, positions, covariance, distance_limit, start, stop, find_distances(positions))
end
reward(op, d::Vector{Float64}, path::Vector{Int}) = sum(op.r[path] + d[path])

include("pomdp.jl")
include("mdp.jl")
include("action_space.jl")
include("problems.jl")
include("util.jl")
include("solutions.jl")
include("rollouts.jl")
include("heuristics.jl")
include("policies.jl")
include("mcts.jl")
include("feedback.jl")
include("evaluation.jl")
include("visualization.jl")

end # module
