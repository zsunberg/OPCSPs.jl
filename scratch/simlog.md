# [Feb 22 14:57] nothing

## Input

```julia
println("hello world!")


```

## Output

```
hello world!

```

# [Feb 22 14:59] nothing

## Input

```julia
println("hello world!")


```

## Output

```
hello world!

```

# [Feb 22 15:03] logsimtest.jl

## Input

```julia
println("hello world!")


```

## Output

```
hello world!

```

# [Feb 22 15:31] logsimtest.jl

## Input

```julia
println("hello world!")


```

## Output

```
hello world!

```

# [Feb 22 15:32] logsimtest.jl

## Input

```julia
println("hello world!")
sleep(3)
println("three seconds have passed")


```

## Output

```
hello world!
three seconds have passed

```

# [Feb 22 16:35] sampling_feedback.jl
## Input
```julia
using OPCSPs

noise = 2.0
N = 1
problems = [gen_problem(noise=noise,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

sampled = evaluate_performance(problems, iss, SampledFeedbackSolver(GurobiExactSolver(), MersenneTwister(1947)))
@show mean(sampled)

```
## Output
```
mean(mean_feedback) = 46.98365069350054
mean(sampled) = 51.252383063435666

```
# [Feb 22 16:36] sampling_feedback.jl
## Input
```julia
using OPCSPs

noise = 2.0
N = 10
problems = [gen_problem(noise=noise,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

sampled = evaluate_performance(problems, iss, SampledFeedbackSolver(GurobiExactSolver(), MersenneTwister(1947)))
@show mean(sampled)

```
## Output
```
mean(mean_feedback) = 66.79664013761433
mean(sampled) = 65.06642546758724

```
# [Feb 22 16:59] sampling_feedback.jl
## Input
```julia
addprocs(4)

using OPCSPs

noise = 2.0
N = 1000
problems = [gen_problem(noise=noise,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

sampled = evaluate_performance(problems, iss, SampledFeedbackSolver(GurobiExactSolver(), MersenneTwister(1947)))
@show mean(sampled)

```
## Output
```
mean(mean_feedback) = 62.90322424802666
mean(sampled) = 60.781836617810214

```
# [Feb 22 19:25] sampling_feedback.jl
## Input
```julia
addprocs(4)

using OPCSPs

noise = 2.0
N = 1000
problems = [gen_problem(noise=noise,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

sampled = evaluate_performance(problems, iss, SampledFeedbackSolver(GurobiExactSolver(), MersenneTwister(1947)))
@show mean(sampled)

```
## Output
```
mean(mean_feedback) = 62.90322424802666
mean(sampled) = 60.86227076090873

```
# [Feb 22 19:28] sampling_feedback.jl

## Input
```julia
addprocs(4)

using OPCSPs

noise = 2.0
N = 1000
problems = [gen_problem(noise=noise,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

sampled = evaluate_performance(problems, iss, SampledFeedbackSolver(GurobiExactSolver(), MersenneTwister(1947)))
@show mean(sampled)

```
## Output
```
mean(mean_feedback) = 62.90322424802666
mean(sampled) = 60.86227076090873

```
# [Feb 22 19:42] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

r = [0, 10.1, 5, 5, 5, 0]
cov = Float64[ 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 2 2 -2 0; 0 0 2 4 0 0; 0 0 -2 0 4 0; 0 0 0 0 0 0]
positions = Vector{Float64}[[0, 0], [0,-1.71], [0,1], [1,1], [-1,1], [0,0]]
p = OPCSP(r, positions, cov, 3.43, 1, 6)

N = 1000
problems = OPCSP[p for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(MersenneTwister(1947)))
@show mean(influence)

```
## Output
```
mean(mean_feedback) = 10.099999999999953
mean(influence) = 11.028196116606976

```
# [Feb 22 19:45] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=0.2,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(MersenneTwister(1947)))
@show mean(influence)

```
## Output
```
mean(mean_feedback) = 62.32002052915202
mean(influence) = 62.2706525955652

```
# [Feb 22 19:47] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=2.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(MersenneTwister(1947)))
@show mean(influence)

```
## Output
```
mean(mean_feedback) = 62.90322424802666
mean(influence) = 46.1417408869183

```
# [Feb 22 19:57] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.02:0.1 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 62.90322424802666
f = 0.0
mean(influence) = 62.90322424802666
f = 0.02
mean(influence) = 62.50146586696467
f = 0.04
mean(influence) = 62.26979268310479
f = 0.06
mean(influence) = 61.75491128437805
f = 0.08
mean(influence) = 61.26596846548928
f = 0.1
mean(influence) = 60.449400568737474

```
# [Feb 22 20:00] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.02:0.1 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 64.00777834932401
f = 0.0
mean(influence) = 64.00777834932401
f = 0.02
mean(influence) = 60.25301318990436
f = 0.04
mean(influence) = 56.136166786866625
f = 0.06
mean(influence) = 53.281667830836426
f = 0.08
mean(influence) = 51.05696911327895
f = 0.1
mean(influence) = 49.41429835569255

```

# Note
changed influence to covariance[:,i]/covariance[i,i]
# [Feb 22 20:13] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

r = [0, 10.1, 5, 5, 5, 0]
cov = Float64[ 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 2 2 -2 0; 0 0 2 4 0 0; 0 0 -2 0 4 0; 0 0 0 0 0 0]
positions = Vector{Float64}[[0, 0], [0,-1.71], [0,1], [1,1], [-1,1], [0,0]]
p = OPCSP(r, positions, cov, 3.43, 1, 6)

N = 1000
problems = OPCSP[p for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 10.099999999999953
f = 0.0
mean(influence) = 10.099999999999953
f = 0.05
mean(influence) = 11.028196116606976
f = 0.1
mean(influence) = 11.028196116606976
f = 0.15
mean(influence) = 11.028196116606976
f = 0.2
mean(influence) = 11.028196116606976

```
# [Feb 22 20:15] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 64.00777834932401
f = 0.0
mean(influence) = 64.00777834932401
f = 0.05
mean(influence) = 64.08593522108075
f = 0.1
mean(influence) = 64.11254118663678
f = 0.15
mean(influence) = 64.08577484881282
f = 0.2
mean(influence) = 64.03722505754851

```

# Note
changed influence to covariance[:,i]/sqrt(covariance[i,i])
# [Feb 23 11:27] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 63.9958514866362
f = 0.0
mean(influence) = 63.9958514866362
f = 0.05
mean(influence) = 63.53592834118269
f = 0.1
mean(influence) = 63.45230647699294
f = 0.15
mean(influence) = 63.45498669475729
f = 0.2
mean(influence) = 63.40188243641026

```

# Note
changed influence back to covariance[:,i]/covariance[i,i]
# [Feb 23 11:42] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 63.9958514866362
f = 0.0
mean(influence) = 63.9958514866362
f = 0.05
mean(influence) = 63.85613950416608
f = 0.1
mean(influence) = 63.899421588639285
f = 0.15
mean(influence) = 63.876148893505864
f = 0.2
mean(influence) = 63.88413255325014

```
# [Feb 23 11:58] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()))
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f))
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 64.00777834932401
f = 0.0
mean(influence) = 64.00777834932401
f = 0.05
mean(influence) = 64.08593522108075
f = 0.1
mean(influence) = 64.11254118663678
f = 0.15
mean(influence) = 64.08577484881282
f = 0.2
mean(influence) = 64.03722505754851

```
# [Feb 23 12:02] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 64.00777834932401
f = 0.0
mean(influence) = 64.00777834932401
f = 0.05
mean(influence) = 64.08593522108075
f = 0.1
mean(influence) = 64.11254118663678
f = 0.15
mean(influence) = 64.08577484881282
f = 0.2
mean(influence) = 64.03722505754851

```
# [Feb 23 12:08] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=2000)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 62.904487700790405
f = 0.0
mean(influence) = 62.904487700790405
f = 0.05
mean(influence) = 63.0946353608152
f = 0.1
mean(influence) = 62.9644825864082
f = 0.15
mean(influence) = 62.89574783136595
f = 0.2
mean(influence) = 62.89472891189719

```
# [Feb 23 12:12] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=2000)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(mean_feedback) = 62.67320114012829
f = 0.0
mean(influence) = 62.67320114012829
f = 0.05
mean(influence) = 62.77565669210183
f = 0.1
mean(influence) = 62.65221194277069
f = 0.15
mean(influence) = 62.61107693112879
f = 0.2
mean(influence) = 62.60748759722721

```
# [Feb 23 12:17] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=2000)

naive = evaluate_performance(problems, iss, GurobiExactSolver(), rng_offset=1000)
@show mean(naive)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(naive) = 61.56611865182377
mean(mean_feedback) = 62.67320114012829
f = 0.0
mean(influence) = 62.67320114012829
f = 0.05
mean(influence) = 62.77565669210183
f = 0.1
mean(influence) = 62.65221194277069
f = 0.15
mean(influence) = 62.61107693112879
f = 0.2
mean(influence) = 62.60748759722721

```
# [Feb 23 12:27] influence_bonus.jl

## Input
```julia
addprocs(4)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.1,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=2000)

naive = evaluate_performance(problems, iss, GurobiExactSolver(), rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(naive) = 61.56611865182377
mean(cheating) = 75.68061623654219
mean(mean_feedback) = 62.67320114012829
f = 0.0
mean(influence) = 62.67320114012829
f = 0.05
mean(influence) = 62.77565669210183
f = 0.1
mean(influence) = 62.65221194277069
f = 0.15
mean(influence) = 62.61107693112879
f = 0.2
mean(influence) = 62.60748759722721

```
# [Feb 23 13:17] influence_bonus.jl

## Input
```julia
addprocs(8)

using OPCSPs

N = 1000

problems = [gen_problem(noise=5.0,
                        p=0.3,
                        n_nodes=10,
                        rng=MersenneTwister(i))
            for i in 1:N]

iss = initial_states(problems, rng_offset=2000)

naive = evaluate_performance(problems, iss, GurobiExactSolver(), rng_offset=1000)
@show mean(naive)

cheating = evaluate_performance(problems, iss, Cheater(), rng_offset=1000)
@show mean(cheating)

mean_feedback = evaluate_performance(problems, iss, FeedbackSolver(GurobiExactSolver()), rng_offset=1000)
@show mean(mean_feedback)

for f in 0.0:0.05:0.2 
    @show f
    influence = evaluate_performance(problems, iss, InfluenceBonusFBSolver(f), rng_offset=1000)
    @show mean(influence)
end

```
## Output
```
mean(naive) = 61.847150915091014
mean(cheating) = 69.61879358722254
mean(mean_feedback) = 62.43964562890745
f = 0.0
mean(influence) = 62.43964562890745
f = 0.05
mean(influence) = 62.55009441941542
f = 0.1
mean(influence) = 62.57105494544288
f = 0.15
mean(influence) = 62.590215790881835
f = 0.2
mean(influence) = 62.583836797740204

```
# [Feb 24 16:27] test_aggregation.jl

## Input
```julia
addprocs(4)

using OPCSPs
using MCTS

N = 100

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
solver = DPWSolver(
    rollout_solver=FeedbackSolver(HeuristicSolver()),
    action_generator=HeuristicActionGenerator(HeuristicSolver(),srng),
    exploration_constant=100.0,
    n_iterations=10000,
    rng=srng,
    k_action = 5.0,
    alpha_action = 0.2,
    k_state = 3.0,
    alpha_state = 0.2
)

dpw = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(dpw)

```
## Output
```
mean(naive) = 63.83767294100001
mean(cheating) = 72.45584183318151
mean(mean_feedback) = 64.50105896451765
mean(dpw) = 59.65436355477023

```
# [Feb 25 18:27] test_aggregation.jl

## Input
```julia
# addprocs(4)

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

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000, parallel=false)
@show mean(ag)

```
## Output
```
mean(naive) = 60.0453115010791
mean(cheating) = 74.18299437940416
mean(mean_feedback) = 62.5506207467587

at /home/zach/.julia/OPCSPs/src/policies.jl:29

      28                          op.distances[openset, openset])
 -->  29       @bp mean_op.stop == 0
      30       if !isempty(prohibit_first)

debug:29> ParseError("invalid character \"\e\"")

debug:29> 0

debug:29> [5,2,3,4,6,7,8,9]

debug:29> 1

debug:29> 10

debug:29> IntSet([2, 3, 4, 6, 7, 8, 9])

debug:29> 5

debug:29> 
```
# [Feb 25 18:43] test_aggregation.jl

## Input
```julia
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
    n_iterations=100,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 60.0453115010791
mean(cheating) = 74.18299437940416
mean(mean_feedback) = 62.5506207467587
  3.849908 seconds (607.25 k allocations: 24.754 MB, 0.14% gc time)
mean(ag) = 60.136530060254884

```
# [Feb 25 18:44] test_aggregation.jl

## Input
```julia
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
    n_iterations=1000,
    rng=srng
)

@time ag = evaluate_performance(problems, iss, solver, rng_offset=1000)
@show mean(ag)

```
## Output
```
mean(naive) = 60.0453115010791
mean(cheating) = 74.18299437940416
mean(mean_feedback) = 62.5506207467587
 41.062565 seconds (607.25 k allocations: 24.769 MB, 0.01% gc time)
mean(ag) = 62.40318693470683

```
