using Base.Test

using OPCSPs.MVNTools

rho = 0.1*rand()
mu1 = rand()
mu2 = rand()
mu3 = rand()
x3 = rand()

sigma = eye(3)
sigma[1,2] = sigma[2,1] = rho
sigma[1,3] = sigma[3,1] = rho^2

@assert isposdef(sigma)

d = MVN([mu1,mu2,mu3], sigma)
apply_measurement!(d, 3, x3)

@test_approx_eq d.mean[1] mu1+rho^2*(x3-mu3)
@test_approx_eq d.mean[2] mu2
@test_approx_eq d.covariance[1,1] 1-rho^4
@test_approx_eq d.covariance[1,2] rho
@test_approx_eq d.covariance[2,1] rho
@test_approx_eq d.covariance[2,2] 1.0
