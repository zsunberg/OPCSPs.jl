module OPCSPs

import POMDPs: POMDP, State, Action, Observation, Belief, BeliefUpdater, AbstractSpace
import POMDPs: rand!, actions, updater, initial_belief, domain, isterminal
import POMDPs: transition, observation, action, reward, update, discount
import POMDPs: create_state, create_observation, create_action, create_belief
import POMDPs: create_observation_distribution, create_transition_distribution
import Base: ==, hash, length

include("MVNTools.jl")
using OPCSPs.MVNTools

export MVNTools

export OPCSP,
       SimpleOP

export solve_op,
       solve_opcsp_feedback,
       cheat,
       gen_opcsp,
       gen_two_cluster_problem,
       updater

abstract OrienteeringProblem <: POMDP

type SimpleOP <: OrienteeringProblem
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

type OPCSP <: OrienteeringProblem
    r::Vector{Float64}
    d::Vector{Float64}
    positions::Vector{Vector{Float64}}
    covariance::Matrix{Float64}
    distance_limit::Float64
    start::Int
    stop::Int
    distances::Matrix{Float64}
end
function OPCSP(r, d, positions, covariance, distance_limit=1.0, start=1, stop=-1)
    if stop == -1
        stop = start
    end
    return OPCSP(r, d, positions, covariance, distance_limit, start, stop, find_distances(positions))
end
reward(op::OPCSP, path::Vector{Int}) = sum([op.r[i]+op.d[i] for i in path])
length(op::OrienteeringProblem) = length(op.r)

include("pomdp.jl")
include("problems.jl")
include("util.jl")
include("solutions.jl")

end # module
