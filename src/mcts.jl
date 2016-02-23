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
    _action_space::AbstractSpace
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

