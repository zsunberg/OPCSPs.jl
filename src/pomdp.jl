@auto_hash_equals type OPCSPState <: State
    i::Int
    open::IntSet # unvisited
    remaining::Float64
    d::Vector{Float64}
end
# ==(u::OPCSPState, v::OPCSPState) = u.i==v.i && u.v==v.v && u.d==v.d && u.remaining==v.remaining
# ==(u::OPCSPState, v::OPCSPState) = error("== is being used for a state") # want to see if this is being used
# hash(s::OPCSPState) = hash(s.i, hash(s.v, hash(s.d, hash(s.remaining))))
create_transition_distribution(problem::OPCSP) = OPCSPState(0, IntSet(), 0.0, Array(Float64, length(problem)))
create_state(op::OPCSP) = OPCSPState(0, IntSet(), 0.0, Array(Float64, length(op)))

@auto_hash_equals type OPCSPAction <: Action
    next::Int
    OPCSPAction() = new()
    OPCSPAction(i::Int) = new(i)
end
# ==(u::OPCSPAction, v::OPCSPAction) = u.next==v.next
# hash(a::OPCSPAction) = hash(a.next)
create_action(::OPCSP) = OPCSPAction()

@auto_hash_equals type OPCSPObs <: Observation
    d::Float64
    OPCSPObs() = new()
    OPCSPObs(d::Float64) = new(d)
end
create_observation_distribution(::OPCSP) = OPCSPObs()
create_observation(::OPCSP) = OPCSPObs()

type OPCSPDistribution <: Belief
    i::Int
    open::IntSet # unvisited
    remaining::Float64
    dist::MVN
end
function rand!(rng::AbstractRNG, s::OPCSPState, d::OPCSPDistribution)
    s.i = d.i
    copy!(s.open, d.open)
    rand!(rng, s.d, d.dist, robust=true)
    s.remaining = d.remaining
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
    bn.remaining = bo.remaining-u.problem.distances[bo.i, a.next]
    bn.dist = apply_measurement(bo.dist, a.next, o.d) #XXX creating a copy here seems bad maybe
    return bn
end
updater(p::OPCSP) = OPCSPUpdater(p)
create_belief(updater::OPCSPUpdater) = create_belief(updater.problem)
initial_belief(p::OPCSP) = OPCSPDistribution(
    p.start,
    delete!(IntSet(1:length(p)), p.start),
    p.distance_limit, 
    MVN(zeros(length(p)), p.covariance)
    )

# this could be inefficient because we are copying too much
# note that state transitions are deterministic
function transition(problem::OPCSP, s::OPCSPState, a::OPCSPAction, sp::OPCSPState=create_transition_distribution(problem))
    sp.i = a.next
    copy!(sp.open, s.open) # if performance is an issue, then change this to = and move delete! to rand!
    delete!(sp.open, a.next)
    sp.d = s.d
    sp.remaining = s.remaining - problem.distances[s.i, a.next]
    return sp
end
function rand!(::AbstractRNG, s::OPCSPState, sd::OPCSPState)
    s.i = sd.i
    copy!(s.open, sd.open)
    s.d = sd.d
    s.remaining = sd.remaining
    return s
end

reward(op::OPCSP, s::OPCSPState, ::OPCSPAction, ::OPCSPState) = op.r[s.i]+s.d[s.i]
discount(op::OPCSP) = 1.0

function observation(op::OPCSP, s::OPCSPState, a::OPCSPAction, sp::OPCSPState, od::OPCSPObs=create_observation_distribution(op))
    od.d = sp.d[a.next]
    return od
end
function rand!(rng::AbstractRNG, sample::OPCSPObs, od::OPCSPObs)
    sample.d = od.d
    return sample
end
isterminal(op::OPCSP, s::OPCSPState) = op.stop == s.i
discount(op::OPCSP) = 1.0
