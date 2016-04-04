# code for use with the MCTS.jl package
import MCTS

MCTS.node_tag(a::OPCSPAction) = "[$(a.next)]"

MCTS.node_tag(s::OPCSPBelief) = "[$(s.i)]"
MCTS.tooltip_tag(s::OPCSPBelief) = "[$(s.i), $(s.remaining)] $(s.dist.mean) | $(s.open)]"

type HeuristicActionGenerator <: MCTS.ActionGenerator
    solver::OPSolver
    rng::AbstractRNG
    _action_space::AbstractSpace
end
HeuristicActionGenerator(solver::OPSolver, rng::AbstractRNG) = HeuristicActionGenerator(solver, rng, OPCSPActionSpace())

function MCTS.next_action(gen::HeuristicActionGenerator, mdp::OPCSPBeliefMDP, s::OPCSPBelief, snode::MCTS.DPWStateNode)
    tail = tail_problem(mdp, s, prohibit_first=filter(i->i!=mdp.stop, map(a->a.next, keys(snode.A))))
    move = OPCSPAction(first_move(gen.solver, tail))
    if haskey(snode.A, move) # the best move was to the stop node, so just select something randomly
        move = rand(gen.rng, actions(mdp, s, gen._action_space))
    end
    return move
end

type PreSolvedActionGenerator <: MCTS.ActionGenerator
    presolved::Dict{Int,Int}
    secondary_solver::OPSolver
    rng::AbstractRNG
    _action_space
end
function PreSolvedActionGenerator(op::Union{OPCSPBeliefMDP,OPCSP};
                                  rng::AbstractRNG=MersenneTwister(),
                                  presolver::OPSolver=GurobiExactSolver(),
                                  secondary_solver::OPSolver=HeuristicSolver())
    d = Dict{Int,Int}()
    path = solve_op(presolver, op)
    for i in 1:length(path)-1
        d[path[i]] = path[i+1]
    end
    return PreSolvedActionGenerator(d, secondary_solver, rng, actions(op))
end

function MCTS.next_action(gen::PreSolvedActionGenerator, mdp::OPCSPBeliefMDP, s::OPCSPBelief, snode::MCTS.DPWStateNode)
    fromdict = false
    if haskey(gen.presolved, s.i) 
        next = gen.presolved[s.i]
        if next in s.open && within_range(mdp, s.i, mdp.stop, next, s.remaining)
            move = OPCSPAction(gen.presolved[s.i])
            fromdict = true
        end
    end
    if !fromdict
        tail = tail_problem(mdp, s, prohibit_first=filter(i->i!=mdp.stop, map(a->a.next, keys(snode.A))))
        move = OPCSPAction(first_move(gen.secondary_solver, tail))
    end
    if haskey(snode.A, move) # the best move was to the stop node, so just select something randomly
        move = rand(gen.rng, actions(mdp, s, gen._action_space))
    end
    return move
end

# Aggregators
type OldVoronoiOPCSPAg <: MCTS.Aggregator 
    radius::Float64
    anchors::Dict{Tuple{Int,Float64,IntSet},Vector{OPCSPBelief}}
end
OldVoronoiOPCSPAg(radius::Float64) = OldVoronoiOPCSPAg(radius, Dict{Tuple{Int,Float64,IntSet},Vector{OPCSPBelief}}())

function MCTS.initialize!(ag::OldVoronoiOPCSPAg, mdp::OPCSPBeliefMDP)
    ag.anchors = Dict{Tuple{Int, Float64, IntSet},Vector{OPCSPBelief}}()    
end

function MCTS.assign(ag::OldVoronoiOPCSPAg, b::OPCSPBelief)
    found = false
    len = length(b.dist.mean)
    # @assert length(b.dist.mean) < 32
    # @assert b.open.limit == 256
    # @assert b.open.fill1s == false
    if haskey(ag.anchors, (b.i, b.remaining, b.open))
        similar = ag.anchors[(b.i, b.remaining, b.open)]
        local anchor
        bestdist = ag.radius
        for anch in similar
            dist = 0.0
            for i in 1:len
                @inbounds dist += abs(anch.dist.mean[i]-b.dist.mean[i])
                if dist > bestdist
                    break
                end
            end
            if dist <= bestdist
                found = true
                anchor = anch
                bestdist = dist
            end
        end
    else
        similar = ag.anchors[(b.i, b.remaining, b.open)] = Vector{OPCSPBelief}()
    end
    if !found
        push!(similar, deepcopy(b))
        return b
    end
    return anchor
end

type VoronoiOPCSPAg <: MCTS.Aggregator 
    radius::Float64
    map::NearestStateMap{OPCSPState}
end
VoronoiOPCSPAg(radius::Float64) = VoronoiOPCSPAg(radius, NearestStateMap{OPCSPState}())

function MCTS.initialize!(ag::VoronoiOPCSPAg, mdp::OPCSPBeliefMDP)
    ag.map = NearestStateMap(OPCSPState, mdp)
end

function MCTS.assign(ag::VoronoiOPCSPAg, b::OPCSPBelief)
    if has_similar(ag.map, b)
        anchor, dist = get_nearest(ag.map, b)
        if dist <= ag.radius
            return anchor
        end
    end
    insert!(ag.map, b, mean(b))
    return b
end

type VoxelOPCSPAg <: MCTS.Aggregator 
    diam::Float64
    # agstates::Dict{Tuple{Int,IntSet,Vector{Int}},Int}
    # next_id::Int
end
# VoxelOPCSPAg(diam::Float64) = VoxelOPCSPAg(diam, Dict{Tuple{Int,IntSet,Vector{Int}},Int}(), 1)

function MCTS.initialize!(ag::VoxelOPCSPAg, mdp::OPCSPBeliefMDP)
    # ag.agstates = Dict{Tuple{Int,IntSet,Vector{Int}},Int}()
    # ag.next_id = 1
end

function MCTS.assign(ag::VoxelOPCSPAg, b::OPCSPBelief)
    voxel = floor(Int, b.dist.mean/ag.diam)
    return (b.i, b.open, b.remaining, voxel)
end
