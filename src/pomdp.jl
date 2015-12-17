type OPCSPState <: State
    i::Int
    open::IntSet # unvisited
    mu::Vector{Float64}
    d_remaining::Float64
end
==(u::OPCSPState, v::OPCSPState) = u.i==v.i && u.v==v.v && u.mu==v.mu && u.d_remaining==v.d_remaining
hash(s::OPCSPState) = hash(s.i, hash(s.v, hash(s.mu, hash(s.d_remaining))))
create_transition_distribution(problem::OPCSP) = OPCSPState(0, IntSet(), Array(Float64, length(problem)), 0.0)
create_state(op::OPCSP) = OPCSPState(0, IntSet(), Array(Float64, length(op)), 0.0)

type OPCSPAction <: Action
    next::Int
    OPCSPAction() = new()
    OPCSPAction(i::Int) = new(i)
end
==(u::OPCSPAction, v::OPCSPAction) = u.next==v.next
hash(a::OPCSPAction) = hash(a.next)
create_action(::OPCSP) = OPCSPAction()

type OPCSPObs <: Observation
    d::Float64
    OPCSPObs() = new()
    OPCSPObs(d::Float64) = new(d)
end
create_observation_distribution(::OPCSP) = OPCSPObs()
create_observation(::OPCSP) = OPCSPObs()

type OPCSPDistribution <: Belief
    i::Int
    open::IntSet # unvisited
    d_remaining::Float64
    dist::MVN
end
function rand!(rng::AbstractRNG, s::OPCSPState, d::OPCSPDistribution)
    s.i = d.i
    copy!(s.open, d.open)
    rand!(rng, s.mu, d.dist)
    s.d_remaining = d.d_remaining
    return s
end
create_belief(problem::OPCSP) = OPCSPDistribution(
    0,
    IntSet(),
    0.0,
    MVN(Array(Float64,length(problem)),Array(Float64, length(problem), length(problem))))
type OPCSPUpdater <: BeliefUpdater
    problem::OPCSP
end
function update(u::OPCSPUpdater, bo::OPCSPDistribution, a::OPCSPAction, o::OPCSPObs, bn::OPCSPDistribution=create_belief(u))
    bn.i = a.next
    copy!(bn.open, bo.open)
    delete!(bn.open, a.next)
    bn.d_remaining = bo.d_remaining-u.problem.distances[bo.i, a.next]
    bn.dist = apply_measurement(bo.dist, a.next, o.d) #XXX creating a copy here seems bad maybe
    return bn
end
updater(p::OPCSP) = OPCSPUpdater(p)
create_belief(updater::OPCSPUpdater) = create_belief(updater.problem)
initial_belief(p::OPCSP) = OPCSPDistribution(
    p.start,
    IntSet(1:length(p)),
    p.distance_limit, 
    MVN(zeros(length(p)), p.covariance)
    )

# this could be inefficient because we are copying too much
# note that state transitions are deterministic
function transition(problem::OPCSP, s::OPCSPState, a::OPCSPAction, sp::OPCSPState=create_transition_distribution(problem))
    sp.i = a.next
    copy!(sp.open, s.open)
    delete!(sp.open, a.next)
    sp.d_remaining = s.d_remaining - problem.distances[s.i, a.next]
    return sp
end
function rand!(::AbstractRNG, s::OPCSPState, sd::OPCSPState)
    s.i = sd.i
    s.open = sd.open
    s.mu = sd.mu
    s.d_remaining = sd.d_remaining
    return s
end

reward(op::OPCSP, s::OPCSPState, ::OPCSPAction, ::OPCSPState) = op.r[s.i]+op.d[s.i]
discount(op::OPCSP) = 1.0

function observation(op::OPCSP, s::OPCSPState, a::OPCSPAction, sp::OPCSPState, od::OPCSPObs=create_observation_distribution(op))
    od.d = sp.mu[a.next]
    return od
end
function rand!(rng::AbstractRNG, sample::OPCSPObs, od::OPCSPObs)
    sample.d = od.d
    return sample
end
isterminal(op::OPCSP, s::OPCSPState) = op.stop == s.i
discount(op::OPCSP) = 1.0

type OPCSPActionSpace <: AbstractSpace
    coll::Array{Int}
    len::Int
end
length(as::OPCSPActionSpace) = as.len
OPCSPActionSpace() = OPCSPActionSpace(Array(Int,0),0)
## iteration ##
start(as::OPCSPActionSpace) = 1
done(as::OPCSPActionSpace, state) = state
next(as::OPCSPActionSpace, state) = (n=next(as.coll, state); return (OPCSPAction(n[1]), n[2]))
domain(as::OPCSPActionSpace) = as

function rand!(rng::AbstractRNG, a::OPCSPAction, as::OPCSPActionSpace)
    a.next = rand(rng, as.coll[1:as.len])
    return a
end

within_range(op::OrienteeringProblem, start, stop, j, dist) = op.distances[start,j] + op.distances[j,stop] <= dist


actions(op::OPCSP) = actions(op, OPCSPDistribution(op.start,
                                                   delete!(IntSet(1:length(op)), op.start),
                                                   op.distance_limit,
                                                   MVN(zeros(0),ones(0,0))))

function actions(op::OPCSP, b::OPCSPDistribution, as::OPCSPActionSpace=OPCSPActionSpace())
    if length(as.coll) < length(op)
        resize!(as.coll, length(op))
    end
    f = filter(j->within_range(op,
                               b.i,
                               op.stop,
                               j,
                               b.d_remaining),
               b.open)
    i = 0
    for a in f
        i += 1
        @inbounds as.coll[i] = a
    end
    as.len = i
    return as
end

### performance may be better with a BitArray of the right length instead of an IntSet
