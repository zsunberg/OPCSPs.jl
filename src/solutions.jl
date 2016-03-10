using JuMP
using Gurobi

abstract OPSolver

type GurobiExactSolver <: OPSolver
    output::Bool
    multithreaded::Bool
    time_limit::Float64
    max_license_tries::Int
end
GurobiExactSolver(;output=false,
                   multithreaded=true,
                   time_limit=Inf,
                   max_license_tries=10) = GurobiExactSolver(output,
                                                       multithreaded,
                                                       time_limit,
                                                       max_license_tries)

function first_move(solver::OPSolver, op::SimpleOP)
    return solve_op(solver, op)[2]
end

type OPSolution
    x
    u
end
OPSolution() = OPSolution(nothing,nothing)

build_path(op, s::OPSolution) = build_path(op, s.x)

function build_path(op, x)
    xopt = round(Int,x)
    path = [op.start]
    current = -1
    dist_sum = 0.0
    while current != op.stop
        if current==-1
            current=op.start
        end
        current = findfirst(xopt[current,:])
        push!(path, current)
    end
    return path
end

function solve_op(solver::GurobiExactSolver, op)
    path = build_path(op, gurobi_solve(op, solver=solver))
    @assert distance(op, path) <= op.distance_limit + 1e-3*op.distance_limit
    return path
end

function gurobi_solve(op; solver=GurobiExactSolver(), initial::OPSolution=OPSolution())
    threads = solver.multithreaded ? 0: 1
    local m
    for l in 1:solver.max_license_tries
        try
            m = Model(solver=Gurobi.GurobiSolver(OutputFlag=solver.output, Threads=threads, TimeLimit=solver.time_limit))
        catch ex
            if l >= solver.max_license_tries
                println("Maximum number of tries ($l) to create Gurobi model failed.")
                sleep(10.0)
                rethrow(ex)
            else
                sleep(0.1)
                continue
            end
        end
        break
    end

    N = length(op)

    without_start = [1:op.start-1; op.start+1:N]
    without_stop = [1:op.stop-1; op.stop+1:N]
    without_both = intersect(without_start, without_stop)

    @defVar(m, x[1:N,1:N], Bin)
    @defVar(m, 2 <= u[without_start] <= N, Int)

    if !is(initial.x, nothing)
        setValue(x, initial.x)
        for keytuple in keys(u)
            key = keytuple[1]
            setValue(u[key], initial.u[key])
        end
    end

    @setObjective(m, Max, sum{ sum{op.r[i]*x[i,j], j=1:N}, i=1:N })

    @addConstraint(m, sum{x[op.start,j], j=without_start} == 1)
    @addConstraint(m, sum{x[i,op.stop], i=without_stop} == 1)
    # problem

    @addConstraint(m, connectivity[k=without_both], sum{x[i,k], i=1:N} == sum{x[k,j], j=1:N})

    @addConstraint(m, once[k=1:N], sum{x[k,j], j=1:N} <= 1)
    @addConstraint(m, sum{ sum{op.distances[i,j]*x[i,j], j=1:N}, i=1:N } <= op.distance_limit)
    @addConstraint(m, nosubtour[i=without_start,j=without_start], u[i]-u[j]+1 <= (N-1)*(1-x[i,j]))

    if op.start != op.stop
        @addConstraint(m, sum{x[op.stop,i],i=1:N} == 0)
    end

    local status
    for l in 1:solver.max_license_tries
        try
            status = JuMP.solve(m, suppress_warnings=true)
        catch ex
            if l >= solver.max_license_tries
                println("Maximum number of tries ($l) to create Gurobi model failed.")
                sleep(10.0)
                rethrow(ex)
            else
                sleep(0.1)
                continue
            end
        end
        break
    end

    if solver.time_limit < Inf
        if status != :Optimal && status != :UserLimit
            warn("Not solved to optimality:\n$op")
        end
    else
        if status != :Optimal
            warn("Not solved to optimality:\n$op")
        end
    end

    soln = OPSolution(getValue(x), getValue(u))

    if distance(op,build_path(op,soln)) > op.distance_limit
        warn("Path Length: $(distance(op,build_path(op,soln))), Limit: $(op.distance_limit)")
    end
    return soln
end

function solve_opcsp_feedback(op, d::Vector{Float64}, solver=GurobiExactSolver())
    d_belief = MVN(zeros(length(op)), copy(op.covariance))
    openset = collect(1:length(op))
    total_dist = 0.0
    choice = -1
    path = [op.start]
    apply_measurement!(d_belief, op.start, d[op.start])
    while choice != op.stop
        mean_future = SimpleOP(op.r[openset] + d_belief.mean[openset],
                          [],
                          op.distance_limit-total_dist,
                          findfirst(openset, path[end]),
                          findfirst(openset, op.stop),
                          op.distances[openset, openset])
        # mpc_soln = gurobi_solve(mean_future)
        # mpc_path = build_path(mean_future, mpc_soln)
        mpc_path = solve_op(solver, mean_future)
        choice = openset[mpc_path[2]]
        total_dist += op.distances[path[end], choice]
        push!(path, choice)
        splice!(openset, mpc_path[1])
        apply_measurement!(d_belief, choice, d[choice])
    end
    return path
end

type Cheater end

function cheat(op, d::Vector{Float64})
    complete_knowledge = SimpleOP(op.r+d, op.positions, op.distance_limit, op.start, op.stop)
    soln = gurobi_solve(complete_knowledge)
    return build_path(op, soln)
end

type OnlyUnobservableUncertainty end

function unobservable_dist(op, d::Vector{Float64})
    ucov = zeros(op.covariance)
    ud = zeros(d)
    for i in 1:length(op)
        cov = copy(op.covariance)
        mvn = MVN(zeros(d),cov)
        for j in 1:length(op)
            if j!=i
                mvn = apply_measurement(mvn, j, d[j])
            end
        end
        @assert sum(mvn.covariance) == mvn.covariance[i,i]
        ucov[i,i] = mvn.covariance[i,i]
        ud[i] = mvn.mean[i]
    end
    @assert isdiag(ucov)
    return MVN(ud, ucov)
end

function cheat_observe_others(op, d::Vector{Float64})
    udist = unobservable_dist(op, d)
    uproblem = SimpleOP(op.r+udist.mean, op.positions, op.distance_limit, op.start, op.stop)
    soln = gurobi_solve(uproblem)
    return build_path(op, soln)
end
