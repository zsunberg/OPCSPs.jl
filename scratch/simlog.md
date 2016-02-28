# [Feb 26 14:19] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+200))
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

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    exploration_constant=50.0,
    n_iterations=1000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 73.35942496840326
mean(cheating) = 92.34733323462301
mean(mean_feedback) = 73.3167327182346
mean(heur_feedback) = 62.31104274571209
137.609158 seconds (763.50 k allocations: 40.179 MB, 0.01% gc time)
mean(ag) = 71.36349003011475

```
# [Feb 26 14:23] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
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

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 53.71608812112478
 38.048701 seconds (763.49 k allocations: 40.053 MB, 0.02% gc time)
mean(ag) = 63.874947583941605

```
# [Feb 26 14:38] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
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

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 53.71608812112478
 36.695426 seconds (763.48 k allocations: 40.053 MB, 0.02% gc time)
mean(ag) = 63.874947583941605

```
# [Feb 26 14:42] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver()

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 65.00773477287163

```
# [Feb 26 14:48] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver()

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 14:49] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=1.0)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 14:50] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.1)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.047886961862275
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 64.71762935007906
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 14:51] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=1.0)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.33799238465485
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.00773477287163
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 14:56] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.1)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 61.86505564974978
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 64.71762935007906
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 15:01] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.1, multithreaded=false)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.37300284969215
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.86502816862658
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 15:03] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.1, multithreaded=false)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 62.37300284969215
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.86502816862658
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 15:04] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.01, multithreaded=false)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 57.577144245300154
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.17685210973745
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 15:09] grb_play.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i+300))
            for i in 1:N]

iss = initial_states(problems, rng_offset=100)

s = GurobiExactSolver(time_limit=0.01, multithreaded=false)

naive = evaluate_performance(problems, iss, s, rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(mean_feedback)

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

```
## Output
```
mean(naive) = 58.38483002100675
mean(cheating) = 85.14363270011262
mean(mean_feedback) = 65.33328896889216
mean(heur_feedback) = 53.71608812112478

```
# [Feb 26 15:14] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 10

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(GurobiExactSolver(time_limit=0.01, multithreaded=false)),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 54.2351384377302
mean(cheating) = 91.21425670683769
mean(mean_feedback) = 58.155924081512936
mean(heur_feedback) = 53.13568788582991
 39.454468 seconds (601.95 k allocations: 25.709 MB, 0.01% gc time)
mean(ag) = 65.7528603834308

```
# [Feb 26 15:15] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(GurobiExactSolver(time_limit=0.01, multithreaded=false)),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 63.781311113052986
mean(cheating) = 88.28989424734246
mean(mean_feedback) = 65.55373760747666
mean(heur_feedback) = 57.87261862585669
519.808471 seconds (763.84 k allocations: 40.076 MB, 0.00% gc time)
mean(ag) = 64.31380334567854

```
# [Feb 26 15:26] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    # rollout_solver=FeedbackSolver(GurobiExactSolver(time_limit=0.01, multithreaded=false)),
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 63.781311113052986
mean(cheating) = 88.28989424734246
mean(mean_feedback) = 65.55373760747666
mean(heur_feedback) = 57.87261862585669
 38.365421 seconds (763.68 k allocations: 40.128 MB, 0.02% gc time)
mean(ag) = 64.81114412588119

```
# [Feb 26 15:32] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 63.781311113052986
mean(cheating) = 88.28989424734246
mean(mean_feedback) = 65.55373760747666
mean(heur_feedback) = 57.87261862585669
mean(s_feedback) = 65.52058571163639
529.560497 seconds (763.37 k allocations: 40.105 MB, 0.00% gc time)
mean(ag) = 65.55556032412785

```
# [Feb 26 15:42] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(time_limit=0.1, multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 63.781311113052986
mean(cheating) = 88.28989424734246
mean(mean_feedback) = 65.55373760747666
mean(heur_feedback) = 57.87261862585669
mean(s_feedback) = 66.19014395179454
590.485263 seconds (763.70 k allocations: 40.064 MB, 0.00% gc time)
mean(ag) = 65.00569979253474

```
# [Feb 26 15:58] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=100,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 63.781311113052986
mean(cheating) = 88.28989424734246
mean(mean_feedback) = 65.55373760747666
mean(heur_feedback) = 57.87261862585669
mean(s_feedback) = 65.49600466981339
110.981630 seconds (763.70 k allocations: 40.064 MB, 0.01% gc time)
mean(ag) = 61.81518878301567

```
# Note
changed 
```
                # stdev = randn(rng,2)
                stdev = rand(rng,2)
```
# [Feb 26 16:05] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.3000303697411
mean(cheating) = 88.04785097814678
mean(mean_feedback) = 66.56136565446519
mean(heur_feedback) = 55.77851632016088
mean(s_feedback) = 64.77911653064157
576.807250 seconds (763.17 k allocations: 40.217 MB, 0.00% gc time)
mean(ag) = 64.05817087620729

```
# [Feb 26 16:16] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(1.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.3000303697411
mean(cheating) = 88.04785097814678
mean(mean_feedback) = 66.56136565446519
mean(heur_feedback) = 55.77851632016088
mean(s_feedback) = 66.05709789286043
352.464086 seconds (762.71 k allocations: 39.999 MB, 0.00% gc time)
mean(ag) = 64.17377287254712

```
# [Feb 26 17:24] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

# s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s = GurobiExactSolver(multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(1.0),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=500,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.3000303697411
mean(cheating) = 88.04785097814678
mean(mean_feedback) = 66.56136565446519
mean(heur_feedback) = 55.77851632016088
mean(s_feedback) = 67.59701429188986
390.414182 seconds (763.78 k allocations: 40.073 MB, 0.00% gc time)
mean(ag) = 65.55726686106941

```
# [Feb 26 17:43] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

# s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s = GurobiExactSolver(multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=50.0,
    n_iterations=1000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.3000303697411
mean(cheating) = 88.04785097814678
mean(mean_feedback) = 66.56136565446519
mean(heur_feedback) = 55.77851632016088
mean(s_feedback) = 67.59701429188986
937.694904 seconds (763.38 k allocations: 40.042 MB, 0.00% gc time)
mean(ag) = 65.77196476364074

```
# [Feb 26 18:09] test_aggregation.jl

## Input
```julia
addprocs(12)

using OPCSPs
using MCTS

N = 100

problems = [gen_problem(noise=10.0,
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

heur_feedback = evaluate_performance(problems, iss, FeedbackSolver(HeuristicSolver()), rng_offset=1000)
@show mean(heur_feedback)

# s = GurobiExactSolver(time_limit=0.02, multithreaded=false)
s = GurobiExactSolver(multithreaded=false)
s_feedback = evaluate_performance(problems, iss, FeedbackSolver(s), rng_offset=1000)
@show mean(s_feedback)

srng = MersenneTwister(1947)
solver = AgUCTSolver(
    aggregator = OPCSPAg(0.2),
    rollout_solver=FeedbackSolver(s),
    exploration_constant=30.0,
    n_iterations=1000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 62.3000303697411
mean(cheating) = 88.04785097814678
mean(mean_feedback) = 66.56136565446519
mean(heur_feedback) = 55.77851632016088
mean(s_feedback) = 67.59701429188986
1112.140605 seconds (763.38 k allocations: 40.233 MB, 0.00% gc time)
mean(ag) = 66.84921467247956

```
