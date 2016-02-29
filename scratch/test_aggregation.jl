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

naive = evaluate_performance(problems, iss, GurobiExactSolver(), rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(10.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=100.0,
    n_iterations=5000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)
