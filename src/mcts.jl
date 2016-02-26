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
    anchors::Dict{Int,Set{OPCSPBelief}}
end
OPCSPAg(radius::Float64) = OPCSPAg(radius, Dict{Int,Set{OPCSPBelief}}())

same_besides_profit(u::OPCSPBelief, v::OPCSPBelief) = u.i == v.i && u.remaining == v.remaining && u.open == v.open

function MCTS.assign(ag::OPCSPAg, b::OPCSPBelief)
    found = false
    if haskey(ag.anchors, b.i)
        i_anchors = ag.anchors[b.i]
        local anch
        for anch in filter(an->same_besides_profit(an,b), i_anchors)
            if sum(abs(anch.dist.mean-b.dist.mean)) <= ag.radius
                found = true
                break
            end
        end
    else
        i_anchors = ag.anchors[b.i] = Set{OPCSPBelief}()
    end
    if !found
        push!(i_anchors, deepcopy(b))
        return b
    end
    return anch
end
