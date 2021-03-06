using ProgressMeter
using PmapProgressMeter

function initial_states(problems::Vector{OPCSP}; rng_offset::Int=1000)
    states = Array(OPCSPState, length(problems))
    for j in 1:length(states)
        p = problems[j]
        states[j] = rand!(MersenneTwister(j+rng_offset), create_state(p), initial_belief(p))
    end
    return states
end

function test_run(p::OPCSP, is::OPCSPState, solver::Union{MCTS.DPWSolver,MCTS.AgUCTSolver}, rng::AbstractRNG=MersenneTwister())
    policy = MCTSAdapter(POMDPs.solve(solver, OPCSPBeliefMDP(p)))
    sim = POMDPToolbox.HistoryRecorder(rng=rng, initial_state=is)
    simr = simulate(sim, p, policy, OPCSPUpdater(p), initial_belief(p))
    path = Int[s.i for s in sim.state_hist]
    r = reward(p, is.d, path)
    @assert abs(simr + p.r[p.stop] + is.d[p.stop] - r) < 1e-6
    return r
end

function test_run(p::OPCSP, is::OPCSPState, policy::Policy, rng::AbstractRNG=MersenneTwister())
    sim = POMDPToolbox.HistoryRecorder(rng=rng, initial_state=is)
    simr = simulate(sim, p, policy, updater(policy), initial_belief(p))
    path = Int[s.i for s in sim.state_hist]
    r = reward(p, is.d, path)
    @assert abs(simr + p.r[p.stop] + is.d[p.stop] - r) < 1e-6
    return r
end

function test_run(p::OPCSP, is::OPCSPState, solver::Solver, rng::AbstractRNG=MersenneTwister())
    policy = POMDPs.solve(solver, p)
    return test_run(p, is, policy, rng)
end

function test_run(p::OPCSP, is::OPCSPState, solver::OPSolver, rng::AbstractRNG=MersenneTwister())
    path = solve_op(solver, p)
    return reward(p, is.d, path)
end

function test_run(p::OPCSP, is::OPCSPState, solver::Cheater, rng::AbstractRNG=MersenneTwister())
    path = cheat(p, is.d)
    return reward(p, is.d, path)
end

function test_run(p::OPCSP, is::OPCSPState, solver::OnlyUnobservableUncertainty, rng::AbstractRNG=MersenneTwister())
    path = cheat_observe_others(p, is.d)
    return reward(p, is.d, path)
end

function evaluate_performance(problems::Vector{OPCSP}, iss::Vector{OPCSPState}, solver; rng_offset::Int=100, parallel=true)
    # rewards = SharedArray(Float64, length(problems))
    N = length(problems)
    if parallel
        prog = Progress( N, dt=0.1, barlen=50, output=STDERR)
        rewards = pmap(test_run,
                       prog,
                       problems,
                       iss,
                       [solver for i in 1:N],
                       [MersenneTwister(j+rng_offset) for j in 1:N]) 
    else
        rewards = Array(Float64, length(problems))
        @showprogress for j in 1:length(problems)
            rewards[j] = test_run(problems[j], iss[j], solver, MersenneTwister(j+rng_offset))
        end
    end
    return sdata(rewards)
end
