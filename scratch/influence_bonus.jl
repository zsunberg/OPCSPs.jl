addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end
