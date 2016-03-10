procs = addprocs(12)

using OPCSPs
using MCTS

N = 1000
par = true

problems = [gen_informative(noise_2norm=100.0,
                                 n_nodes=10,
                                 n_connected=4,
                                 rbar=10.0,
                                 rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

naive = evaluate_performance(problems, iss, GurobiExactSolver(multithreaded=false), rng_offset=1000, parallel=par)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000, parallel=par)
@show mean(cheating)

upper = evaluate_performance(problems, iss, OnlyUnobservableUncertainty(), rng_offset=1000, parallel=par)
@show mean(upper)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver(multithreaded=false)), rng_offset=1000, parallel=par)
@show mean(mean_feedback)

s = GurobiExactSolver(multithreaded=false)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator=VoronoiOPCSPAg(50.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=100.0,
    n_iterations=10000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000, parallel=par)
@show mean(ag)

rmprocs(procs)
