using OPCSPs.MVNTools

using PyCall
using PyPlot
@pyimport matplotlib.patches as patches

function plot_confidence_ellipse(d::MVN, num_sigma::Int=3)
    assert(length(d.mean)==2)
    lambda, phi = eig(d.covariance)
    ell = patches.Ellipse(xy = d.mean,
                          width = sqrt(lambda[1])*num_sigma*2,
                          height = sqrt(lambda[2])*num_sigma*2,
                          angle = 180/pi*atan2(phi[2,1], phi[1,1]))
    ell[:set_facecolor]("none")
    gca()[:add_artist](ell)
    draw()
end

d = MVN([0,1], [1 0.08; 0.08 0.04])

n_samples = 10000
samples = Array(Float64, n_samples, 2)
rng = MersenneTwister()
for i in 1:n_samples
    samples[i,:] = rand!(rng, Array(Float64, length(d)), d)
end

figure(1)
clf()
plot_confidence_ellipse(d, 1)
plot_confidence_ellipse(d, 2)
plot_confidence_ellipse(d, 3)
xlim(-3, 3)
ylim(-3, 3)
scatter(samples[:,1], samples[:,2])
