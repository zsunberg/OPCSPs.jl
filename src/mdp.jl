type OPCSPBeliefMDP <: POMDP
    r::Vector{Float64}
    positions::Vector{Vector{Float64}}
    covariance::Matrix{Float64}
    distance_limit::Float64
    start::Int
    stop::Int
    distances::Matrix{Float64}
end
function OPCSPBeliefMDP(op::OPCSP)
    OPCSPBeliefMDP(op.r, op.positions, op.covariance, op.distance_limit, op.start, op.stop, op.distances)
end
length(op::OPCSPBeliefMDP) = length(op.r)

create_action(::OPCSPBeliefMDP) = OPCSPAction()

@auto_hash_equals type OPCSPBelief <: State
    i::Int
    open::IntSet
    remaining::Float64
    dist::MVN
end
OPCSPBelief(d::OPCSPDistribution) = OPCSPBelief(d.i, d.open, d.remaining, d.dist)
create_state(problem::OPCSPBeliefMDP) = OPCSPBelief(
    0,
    IntSet(),
    0.0,
    MVN(Array(Float64,length(problem)), Array(Float64, length(problem), length(problem))))

function MCTS.generate(p::OPCSPBeliefMDP, s::OPCSPBelief, a::OPCSPAction, rng::AbstractRNG)
    sp = create_state(p)
    sp.i = a.next
    copy!(sp.open, s.open)
    delete!(sp.open, a.next)
    sp.remaining = s.remaining-p.distances[s.i, a.next]
    d = rand_elem(rng, s.dist, a.next)
    sp.dist = apply_measurement(s.dist, a.next, d)
    r = reward(p, s, a, sp)
    return (sp, r)
end
initial_state(p::OPCSPBeliefMDP) = OPCSPBelief(
    p.start,
    delete!(IntSet(1:length(p)), p.start),
    p.distance_limit, 
    MVN(zeros(length(p)), p.covariance)
    )


# get the reward for whichever action you pick, not whichever state you're in
function reward(p::OPCSPBeliefMDP, ::OPCSPBelief, a::OPCSPAction, sp::OPCSPBelief)
    @assert sp.dist.covariance[a.next, a.next] == 0.0
    return p.r[a.next]+sp.dist.mean[a.next]
end

discount(op::OPCSPBeliefMDP) = 1.0
isterminal(op::OPCSPBeliefMDP, s::OPCSPBelief) = op.stop == s.i
