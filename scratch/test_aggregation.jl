addprocs(12)

using OPCSPs
using MCTS

N = 1000

problems = [gen_problem(noise=10.0,
                        p=0.2,
                        n_nodes=8,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

naive = evaluate_performance(problems, iss, GurobiExactSolver(multithreaded=false), rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver(multithreaded=false)), rng_offset=1000)
@show mean(mean_feedback)

s = GurobiExactSolver(multithreaded=false)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = VoronoiOPCSPAg(10.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=100.0,
    n_iterations=10000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000, parallel=true)
@show mean(ag)
