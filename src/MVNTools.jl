module MVNTools

import POMDPs
import POMDPs.rand!

export MVN, apply_measurement!, apply_measurement

# Multivariate Normal Distribution
type MVN <: POMDPs.AbstractDistribution
    mean::Vector{Float64}
    covariance::Array{Float64,2}
end
Base.length(d::MVN) = length(d.mean)

function apply_measurement!(d::MVN, index::Int, meas::Float64)
    @assert d.covariance[index,index] >= 0.0
    if d.covariance[index,index] == 0.0
        @assert meas == d.mean[index]
        return d
    end

    d.mean = d.mean + d.covariance[:,index]*(meas-d.mean[index])/d.covariance[index,index]

    d.covariance = d.covariance-d.covariance[:,index]*1/d.covariance[index,index]*d.covariance[index,:]

    d.covariance[:, index] = 0.0
    d.covariance[index, :] = 0.0

    return d
end

# the following version creates a copy
function apply_measurement(d::MVN, index::Int, meas::Float64)
    @assert d.covariance[index,index] >= 0.0
    if d.covariance[index,index] == 0.0
        @assert meas == d.mean[index]
        return MVN(copy(d.mean), copy(d.covariance))
    end

    mean = d.mean + d.covariance[:,index]*(meas-d.mean[index])/d.covariance[index,index]

    covariance = d.covariance-d.covariance[:,index]*1/d.covariance[index,index]*d.covariance[index,:]

    covariance[:, index] = 0.0
    covariance[index, :] = 0.0

    return MVN(mean, covariance)
end

function rand!(rng::AbstractRNG, sample::Vector{Float64}, d::MVN; robust=false)
    # if robust, attempts to add a small number to the diagonal
    @assert length(sample) == length(d)

    nonzero = find(diag(d.covariance).!=0.0)
    nzcov = d.covariance[nonzero,nonzero]
    nzchol = zeros(size(nzcov))
    if robust
        try
            nzchol = chol(nzcov, Val{:L})
        catch e
            # Thu 19 Nov 2015 11:53:38 AM PST: couldn't remember why this is necessary
            nzchol = chol(nzcov+1e-5*minimum(diag(nzcov))*eye(length(nonzero)), Val{:L})
        end
    else
        nzchol = chol(nzcov, Val{:L})
    end
    delta = zeros(length(d))
    if rng == nothing
        delta[nonzero] = nzchol*randn(length(nonzero))
    else
        delta[nonzero] = nzchol*randn(rng, length(nonzero))
    end
    sample[:] = d.mean + delta
    return sample
end

end
