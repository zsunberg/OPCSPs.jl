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

actions(op::Union{OPCSP,OPCSPBeliefMDP}) = actions(op, op.start, delete!(IntSet(1:length(op)), op.start), op.distance_limit)

actions(op::Union{OPCSP,OPCSPBeliefMDP}, b::Union{OPCSPDistribution, OPCSPState, OPCSPBelief}, as::OPCSPActionSpace=OPCSPActionSpace()) = actions(op, b.i, b.open, b.remaining, as)

actions(op::Union{OPCSP,OPCSPBeliefMDP}, b::Tuple{Int,IntSet,Float64,Vector{Int}}) = actions(op, b[1], b[2], b[3])


function actions(op::Union{OPCSP,OPCSPBeliefMDP}, i::Int, open::IntSet, remaining::Float64, as::OPCSPActionSpace=OPCSPActionSpace())
    if length(as.coll) < length(op)
        as.coll = Array(Int, length(op))
        # resize!(as.coll, length(op)) # this can run into a problem in parallel
    end
    f = filter(j->within_range(op,
                               i,
                               op.stop,
                               j,
                               remaining),
               open)
    k = 0
    for a in f
        k += 1
        @inbounds as.coll[k] = a
    end
    as.len = k
    return as
end



### performance may be better with a BitArray of the right length instead of an IntSet
