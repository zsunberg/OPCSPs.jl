using OPCSPs
using OPCSPs.MVNTools

r = [0, 10.1, 5, 5, 5, 0]
cov = Float64[ 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 2 2 -2 0; 0 0 2 4 0 0; 0 0 -2 0 4 0; 0 0 0 0 0 0]

dist = MVN(r,cov)

# BAD NOTATION delta is not what it usually is
M = 1000000
rewards = Array(Float64, M)
rng = MersenneTwister(1)
for i = 1:M
    delta = rand(dist)
    if delta[3] >= 5.0
        rewards[i] = delta[3] + delta[4]
    else
        rewards[i] = delta[3] + delta[5]
    end
end

#=
using Gadfly
p = plot(rewards, Geom.histogram)
draw(SVG("not_gaussian.svg", 6inch, 3inch), p)
=#

import PyPlot
PyPlot.plt[:clf]()
PyPlot.plt[:hist](rewards, 100)

# not gaussian
