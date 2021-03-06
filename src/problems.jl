# function gen_opcsp(r, positions, covariance, distance_limit=1.0, start=1, stop=-1; rng=nothing)
#     d = rand!(rng, Array(Float64, length(r)), MVN(zeros(length(r)), covariance))
#     return OPCSP(r, d, positions, covariance, distance_limit, start, stop)
# end

function gen_op(;distance_limit=1.5,
                 n_nodes=10,
                 rng=MersenneTwister())

    positions = Array(Vector{Float64}, n_nodes)
    for i in 1:n_nodes
        positions[i] = rand(rng, 2).-0.5
    end

    return SimpleOP(5.0*rand(rng, n_nodes) + 5.0,
                    positions,
                    distance_limit,
                    1,
                    n_nodes)
end

function gen_two_cluster_problem(;distance_limit=6.0,
                                  n_nodes=10,
                                  p=0.4, # probability of connection
                                  rng=MersenneTwister(),
                                  noise=1.0
                                  )
    positions = Array(Vector{Float64}, n_nodes)
    n_1 = trunc(Int,n_nodes/2)
    for i in 1:n_1
        positions[i] = rand(rng, 2)
        # positions[i] = sample(MVN([-0.5,0], eye(2)), rng=rng)
    end
    for i in n_1+1:n_nodes
        positions[i] = -rand(rng,2)
        # positions[i] = sample(MVN([0.5,0], eye(2)), rng=rng)
    end

    # generate correlations with erdos-renyi connectivity
    covariance = zeros(n_nodes, n_nodes)
    for i in 1:n_nodes
        for j in i+1:n_nodes
            if rand(rng) < p
                sgn = rand(rng)
                if sgn >= 0.5
                    rho = 0.99
                else
                    rho = -0.99
                end
                # rho = 2.0*rand(rng)-1.0
                # stdev = randn(rng,2)
                stdev = rand(rng,2)
                block = [     stdev[1]^2 rho*prod(stdev);
                         rho*prod(stdev)      stdev[2]^2]
                covariance[[i,j], [i,j]] += block
            end
        end
    end
    for i in 1:n_nodes
        if covariance[i,i] == 0.0
            covariance[i,i] = randn(rng)^2
        end
    end
    covariance = covariance.*(noise^2/(det(covariance)^(1/n_nodes))) 

    @assert isposdef(covariance)
    @assert norm(positions[1]-positions[n_nodes]) <= distance_limit

    r = 5.0*rand(rng, n_nodes) + 5
    return OPCSP(r, positions, covariance, distance_limit, 1, n_nodes)
end


function gen_problem(;distance_limit=sqrt(2),
                      n_nodes=10,
                      p=0.4, # probability of connection
                      rng=MersenneTwister(),
                      noise=1.0
                      )

    positions = Array(Vector{Float64}, n_nodes)
    for i in 1:n_nodes
        positions[i] = rand(rng, 2)
    end
    
    # generate correlations with erdos-renyi connectivity
    covariance = zeros(n_nodes, n_nodes)
    for i in 1:n_nodes
        for j in i+1:n_nodes
            if rand(rng) < p
                sgn = rand(rng)
                if sgn >= 0.5
                    rho = 0.99
                else
                    rho = -0.99
                end
                # rho = 2.0*rand(rng)-1.0
                # stdev = randn(rng,2)
                stdev = rand(rng,2)
                block = [     stdev[1]^2 rho*prod(stdev);
                         rho*prod(stdev)      stdev[2]^2]
                covariance[[i,j], [i,j]] += block
            end
        end
    end
    for i in 1:n_nodes
        if covariance[i,i] == 0.0
            covariance[i,i] = randn(rng)^2
        end
    end
    covariance = covariance.*(noise^2/(det(covariance)^(1/n_nodes))) 

    @assert isposdef(covariance)
    @assert norm(positions[1]-positions[n_nodes]) <= distance_limit

    # r = 5.0*rand(rng, n_nodes) + 5
    # r = 10.0*rand(rng, n_nodes)
    r = 10*ones(n_nodes)
    return OPCSP(r, positions, covariance, distance_limit, 1, n_nodes)
end

function gen_highly_connected(;distance_limit=sqrt(2),
                      n_nodes=10,
                      n_connected=2,
                      p=0.5, # probability of connection from a connected node to another node
                      rbar=10.0,
                      noise_2norm=1.0,
                      rng=MersenneTwister()
                      )

    positions = Array(Vector{Float64}, n_nodes)
    for i in 1:n_nodes
        positions[i] = rand(rng, 2)
    end
    
    covariance = zeros(n_nodes, n_nodes)
    open = IntSet(2:n_nodes-1)
    for i in 1:n_connected
        j = rand(rng, collect(open))
        delete!(open, j)
        others = IntSet(1:n_nodes)
        delete!(others, j)
        for k in others
            if rand(rng) < p
                sgn = rand(rng)
                if sgn >= 0.5
                    rho = 0.99
                else
                    rho = -0.99
                end
                # rho = 2.0*rand(rng)-1.0
                # stdev = randn(rng,2)
                stdev = rand(rng,2)
                block = [     stdev[1]^2 rho*prod(stdev);
                         rho*prod(stdev)      stdev[2]^2]
                covariance[[j,k], [j,k]] += block
            end
        end
    end
    for i in 1:n_nodes
        if covariance[i,i] == 0.0
            covariance[i,i] = 0.01^2
        end
    end

    # normalize so that noise sqrt(trace(covariance)) = noise
    alpha = noise_2norm^2/trace(covariance)
    covariance .*= alpha

    @assert abs(sqrt(trace(covariance))-noise_2norm) < 1e-5
    @assert isposdef(covariance + 1e-5*eye(covariance))
    @assert norm(positions[1]-positions[n_nodes]) <= distance_limit

    # r = 5.0*rand(rng, n_nodes) + 5
    # r = 10.0*rand(rng, n_nodes)
    r = rbar*ones(n_nodes)
    return OPCSP(r, positions, covariance, distance_limit, 1, n_nodes)
end

function gen_informative(;distance_limit=sqrt(2),
                      n_nodes=10,
                      n_connected=n_nodes-2,
                      rbar=10.0,
                      noise_2norm=1.0,
                      rng=MersenneTwister()
                      )

    positions = Array(Vector{Float64}, n_nodes)
    for i in 1:n_nodes
        positions[i] = rand(rng, 2)
    end
    
    covariance = zeros(n_nodes, n_nodes)
    open = IntSet(2:n_nodes-1)
    for i in 1:n_connected
        j = rand(rng, collect(open))
        delete!(open, j)
        others = IntSet(1:n_nodes)
        delete!(others, j)
        first = rand(rng, collect(others))
        delete!(others, first)
        second = rand(rng, collect(others))
        stdev = rand(rng,3)
        block = [         2.0*stdev[1]^2 .99*prod(stdev[1:2]) -.99*prod(stdev[[1,3]]);
                    .99*prod(stdev[1:2])           stdev[2]^2                       0;
                 -.99*prod(stdev[[1,3]])                    0               stdev[3]^2 ]
        covariance[[j,first,second], [j,first,second]] += block
    end
    for i in 1:n_nodes
        if covariance[i,i] == 0.0
            covariance[i,i] = 0.01^2
        end
    end

    # normalize so that noise sqrt(trace(covariance)) = noise
    alpha = noise_2norm^2/trace(covariance)
    covariance .*= alpha

    @assert abs(sqrt(trace(covariance))-noise_2norm) < 1e-5
    @assert isposdef(covariance + 1e-5*eye(covariance))
    @assert norm(positions[1]-positions[n_nodes]) <= distance_limit

    # r = 5.0*rand(rng, n_nodes) + 5
    # r = 10.0*rand(rng, n_nodes)
    r = rbar*ones(n_nodes)
    return OPCSP(r, positions, covariance, distance_limit, 1, n_nodes)
end

