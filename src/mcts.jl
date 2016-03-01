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

type OPCSPAg <: MCTS.Aggregator 
    radius::Float64
    anchors::Dict{Int,Vector{OPCSPBelief}}
end
OPCSPAg(radius::Float64) = OPCSPAg(radius, Dict{Int,Vector{OPCSPBelief}}())

# inlined below
same_besides_profit(u::OPCSPBelief, v::OPCSPBelief) = u.i == v.i && u.remaining == v.remaining && u.open == v.open

function MCTS.initialize!(ag::OPCSPAg, mdp::OPCSPBeliefMDP)
    ag.anchors = Dict{Int,Vector{OPCSPBelief}}()    
end

function MCTS.assign(ag::OPCSPAg, b::OPCSPBelief)
    found = false
    @assert length(b.dist.mean) < 32
    @assert b.open.limit == 256
    @assert b.open.fill1s == false
    if haskey(ag.anchors, b.i)
        i_anchors = ag.anchors[b.i]
        local anchor
        bestdist = ag.radius
        for anch in i_anchors
            if anch.remaining == b.remaining # if the open set is still the same, remaining must be
                # if length(anch.dist.mean) >= 32
                #     sameopen = anch.open == b.open
                # else # this is the dirtiest thing I've ever done
                #     @assert anch.open.fill1s == b.open.fill1s
                #     @assert anch.open.limit == 256
                #     @assert b.open.limit == 256
                #     sameopen = anch.open.bits[1] == b.open.bits[1]
                # end
                # if sameopen
                # if anch.open == b.open
                if anch.open.bits[1] == b.open.bits[1]
                    dist = 0.0
                    for i in 1:length(anch.dist)
                        dist += abs(anch.dist.mean[i]-b.dist.mean[i])
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
            end
        end
    else
        i_anchors = ag.anchors[b.i] = Vector{OPCSPBelief}()
    end
    if !found
        push!(i_anchors, deepcopy(b))
        return b
    end
    return anchor
end
