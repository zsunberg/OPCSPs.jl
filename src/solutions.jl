using JuMP
using Gurobi

type OPSolution
    x
    u
end
OPSolution() = OPSolution(nothing,nothing)

function build_path(op::OrienteeringProblem, s::OPSolution)
    xopt = round(Int,s.x)
    path = [op.start]
    current = -1
    dist_sum = 0.0
    while current != op.stop
        if current==-1
            current=op.start
        end
        current = findfirst(s.x[current,:])
        push!(path, current)
    end
    return path
end

#=
function next_guess(soln::OPSolution, i)
    
end
=#

function solve_op(op::OrienteeringProblem; output=0, initial::OPSolution=OPSolution())
    m = Model(solver=Gurobi.GurobiSolver(OutputFlag=output))
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

    status = solve(m)

    if status != :Optimal
        warn("Not solved to optimality:\n$op")
    end

    soln = OPSolution(getValue(x), getValue(u))

    if distance(op,build_path(op,soln)) > op.distance_limit
        warn("Path Length: $(distance(op,path)), Limit: $(op.distance_limit)")
    end
    return soln
end

function solve_opcsp_feedback(op::OPCSP)
    d_belief = MVN(zeros(length(op)), copy(op.covariance))
    openset = collect(1:length(op))
    total_dist = 0.0
    choice = -1
    path = [op.start]
    apply_measurement!(d_belief, op.start, op.d[op.start])
    while choice != op.stop
        # @show 1/length(openset)*sum(abs(d_belief.mean - op.d))
        mean_future = SimpleOP(op.r[openset] + d_belief.mean[openset],
                          [],
                          op.distance_limit-total_dist,
                          findfirst(openset, path[end]),
                          findfirst(openset, op.stop),
                          op.distances[openset, openset])
        mpc_soln = solve_op(mean_future)
        mpc_path = build_path(mean_future, mpc_soln)
        choice = openset[mpc_path[2]]
        total_dist += op.distances[path[end], choice]
        push!(path, choice)
        splice!(openset, mpc_path[1])
        apply_measurement!(d_belief, choice, op.d[choice])
    end
    return path
end

function cheat(op::OPCSP)
    complete_knowledge = SimpleOP(op.r+op.d, op.positions, op.distance_limit, op.start, op.stop)
    soln = solve_op(complete_knowledge)
    return build_path(op, soln)
end
