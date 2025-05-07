using MixedModels, GLM, GLMakie, DataFrames, AlgebraOfGraphics, Distributions, Random

const intercept = 1
const slope = 1

model(intercept, slope, x) = intercept + slope*x
measure(μ, σ) = rand(Normal(μ, σ))

function sample1(x, id, individual_intercepts, individual_slopes, σ)
    μ = model(individual_intercepts[id] + intercept, individual_slopes[id] + slope, x)
    measure(μ, σ)
end

function fun(ngroups, n, σ, intercept_sigma, slope_sigma)
    df = DataFrame(seed = rand(ngroups) .- 0.5, id = 1:ngroups)
    transform!(df, :seed => ByRow(seed -> rand(Truncated(Normal(seed, 1), -0.5, 0.5), n)) => :x)
    df0 = flatten(select(df, Not(:seed)), :x)
    individual_intercepts = rand(Normal(0, intercept_sigma), ngroups)
    individual_slopes = rand(Normal(0, slope_sigma), ngroups)
    df = transform(df0, [:x, :id] => ByRow((x, id) -> sample1(x, id, individual_intercepts, individual_slopes, σ)) => :y)
    m1 = lm(@formula(y ~ 1 + x), df)
    m1a, m1b = coef(m1)
    m1Δ = sqrt((m1a - intercept)^2 + (m1b - slope)^2)
    m2 = fit(MixedModel, @formula(y ~ 1 + x + (1 + x|id)), df)
    m2a, m2b = fixef(m2)
    m2Δ = sqrt((m2a - intercept)^2 + (m2b - slope)^2)
    return m1Δ, m2Δ
end

ngroupss = round.(Int, range(5, 100, 5))
ns = round.(Int, range(5, 100, 5))
σs = range(0.01, 10, 5)
intercept_sigmas = range(0.01, 100, 5)
slope_sigmas = range(0.01, 100, 5)
df = DataFrame(ngroups = Int[], n = Int[], σ = Float64[], intercept_sigma = Float64[], slope_sigma = Float64[], m1Δ = Float64[], m2Δ = Float64[])
for (i, ngroups) in enumerate(ngroupss), (j, n) in enumerate(ns), (k, σ) in enumerate(σs), (l, intercept_sigma) in enumerate(intercept_sigmas), (l, slope_sigma) in enumerate(slope_sigmas)
    m1Δ, m2Δ = fun(ngroups, n, σ, intercept_sigma, slope_sigma)
    push!(df, (; ngroups, n, σ, intercept_sigma, slope_sigma, m1Δ, m2Δ))
end

transform!(df, [:m1Δ, :m2Δ] => ByRow(-) => :Δ)
data(df) * mapping(:σ, :Δ, row = :ngroups => nonnumeric, col = :n => nonnumeric) * visual(Lines) |> draw()#; axis = (; limits = (nothing, (-4, 0))))

# df = stack(df, [:m1Δ, :m2Δ])
# data(df) * mapping(:σ, :value, color = :variable, row = :ngroups => nonnumeric, col = :n => nonnumeric) * visual(Scatter) |> draw(; axis = (; limits = (nothing, (0, 1))))
