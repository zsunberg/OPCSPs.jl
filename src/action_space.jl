type OPCSPActionSpace <: AbstractSpace
    coll::Array{Int} # this may be larger than the actual action space to avoid reallocations - make sure to use len
    len::Int
end
length(as::OPCSPActionSpace) = as.len
OPCSPActionSpace() = OPCSPActionSpace(Array(Int,0),0)
## iteration ##
Base.start(as::OPCSPActionSpace) = 1
Base.done(as::OPCSPActionSpace, state) = state > as.len
Base.next(as::OPCSPActionSpace, state) = (OPCSPAction(as.coll[state]), state+1)
iterator(as::OPCSPActionSpace) = as

function rand!(rng::AbstractRNG, a::OPCSPAction, as::OPCSPActionSpace)
    a.next = rand(rng, as.coll[1:as.len])
    return a
end
function rand(rng::AbstractRNG, as::OPCSPActionSpace, a::OPCSPAction=OPCSPAction())
    a.next = rand(rng, as.coll[1:as.len])
    return a
end

actions(op::Union{OPCSP,OPCSPBeliefMDP}) = actions(op, OPCSPDistribution(op.start,
                                                   delete!(IntSet(1:length(op)), op.start),
                                                   op.distance_limit,
                                                   MVN(zeros(0),ones(0,0))))

function actions(op::Union{OPCSP,OPCSPBeliefMDP}, b::Union{OPCSPDistribution, OPCSPState, OPCSPBelief}, as::OPCSPActionSpace=OPCSPActionSpace())
    if length(as.coll) < length(op)
        resize!(as.coll, length(op))
    end
    f = filter(j->within_range(op,
                               b.i,
                               op.stop,
                               j,
                               b.remaining),
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
