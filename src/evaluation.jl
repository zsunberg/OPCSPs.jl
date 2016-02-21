

function test_run(p::OPCSP, is::OPCSPState, solver::DPWSolver; rng::AbstractRNG=MersenneTwister())
    policy = MCTSAdapter(solve(solver, OPCSPBeliefMDP(p)))
    sim = HistoryRecorder(rng=rng, initial_state=is)
    simr = simulate(sim, p, policy, OPCSPUpdater(p), initial_belief(p))
    path = Int[s.i for s in sim.state_hist]
    r = reward(p, is.d, path)
    @assert r == simr + p.r[p.stop] + is.d[p.stop]
    return r
end

function test_run(p::OPCSP, is::OPCSPState, policy::Policy; rng::AbstractRNG=MersenneTwister())
    sim = HistoryRecorder(rng=rng, initial_state=is)
    simr = simulate(sim, p, policy, updater(policy), initial_belief(p))
    path = Int[s.i for s in sim.state_hist]
    r = reward(p, is.d, path)
    @assert r == simr + p.r[p.stop] + is.d[p.stop]
    return r
end

function test_run(p::OPCSP, is::OPCSPState, solver::Solver; rng::AbstractRNG=MersenneTwister())
    policy = solve(solver, p)
    return test_run(p, is, policy, rng=rng)
end

function test_run(p::OPCSP, is::OPCSPState, solver::OPSolver; rng::AbstractRNG=MersenneTwister())
    path = solve_op(solver, p)
    return reward(p, is.d, path)
end

function evaluate_performance(problems::Vector{OPCSP}, iss::Vector{OPCSPState}, solver; rng_offset::Int=100)
    rewards = SharedArray(Float64, length(problems))
    @sync @parallel for j in 1:length(problems)
        rewards[j] = test_run(problems[j], iss[j], solver, MersenneTwister(j+rng_offset))
    end
    return sdata(rewards)
end
