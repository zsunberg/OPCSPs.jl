addprocs(4)

using OPCSPs
using MCTS

N = 10

problems = [gen_problem(noise=5.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

naive = evaluate_performance(problems, iss, GurobiExactSolver(), rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.1),
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    exploration_constant=100.0,
    n_iterations=10000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)
