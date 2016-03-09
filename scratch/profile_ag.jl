using OPCSPs
using MCTS
using ProfileView
using POMDPs
import POMDPToolbox

p = gen_informative(noise_2norm=100.0,
                n_nodes=10,
                rbar=10.0
                rng=MersenneTwister(1))
is = rand!(MersenneTwister(1543), create_state(p), initial_belief(p))

s = GurobiExactSolver(multithreaded=false)
solver = AgUCTSolver(
    aggregator=VoronoiOPCSPAg(20.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=100.0,
    n_iterations=100000,
    rng=MersenneTwister(1947)
)

policy = MCTSAdapter(POMDPs.solve(solver, OPCSPBeliefMDP(p)))
sim = POMDPToolbox.HistoryRecorder(rng=MersenneTwister(2011), initial_state=is)
simr = simulate(sim, p, policy, OPCSPUpdater(p), initial_belief(p))

Profile.clear()

policy = MCTSAdapter(POMDPs.solve(solver, OPCSPBeliefMDP(p)))
@profile simulate(sim, p, policy, OPCSPUpdater(p), initial_belief(p))

policy = MCTSAdapter(POMDPs.solve(solver, OPCSPBeliefMDP(p)))
@time simulate(sim, p, policy, OPCSPUpdater(p), initial_belief(p))

ProfileView.view()
