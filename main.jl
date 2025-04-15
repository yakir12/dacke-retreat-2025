using GLMakie, AlgebraOfGraphics, Distributions, DataFrames, Chain, DataFramesMeta
using GLM, CoordinateTransformations, Rotations

function model(x, slope, intercept)
    μ = slope*x + intercept
    # identity(μ)
end

sample1 = rand ∘ Normal

n = 100
x = 10rand(n)
slope, intercept = (5, 15)
σ = 2

Random.seed!(0)
df = DataFrame(x = x)
@chain df begin
    @transform! :parameters = model.(:x, slope, intercept)
    @transform! :measurement = sample1.(:parameters, σ)
end

fig = Figure()
ax1 = Axis(fig[1,1], aspect = 1, xlabel = "x")
hist!(ax1, df.x)
ax2 = Axis(fig[1,2], aspect = 1, xlabel = "measurement")
hist!(ax2, df.measurement)
ax3 = Axis(fig[1,3], aspect = 1, xlabel = "ϵ")
hist!(ax3, df.parameters - df.measurement)

data(df) * (mapping(:x, :parameters) * visual(Lines; color = :red, label = "$slope*x + $intercept") + mapping(:x, :measurement) * visual(Scatter; label = "noisy data")) |> draw()

m = lm(@formula(measurement ~ x), df)
fitted_intercept, fitted_slope = coef(m)

Random.seed!(0)
@chain df begin
    @transform! :fitted_parameters = model.(:x, fitted_slope, fitted_intercept)
    @transform! :ϵ̂ = :measurement .- :fitted_parameters
end

@assert df.fitted_parameters == predict(m)
@assert df.ϵ̂ == residuals(m)

d = Distributions.fit(Normal, residuals(m))

fig = Figure()
ax = Axis(fig[1,1], xlabel = "x", ylabel = "measurement")
lines!(ax, df.x, df.parameters, label = "parameters", color = :black)

scatter!(ax, df.x, df.measurement, label = "measurements", color = :green)

lines!(ax, df.x, df.fitted_parameters, label = "fit", color = :red)

rangebars!(ax, df.x, df.measurement, df.fitted_parameters, label = "residuals", color = :gray)
axislegend(ax, position = :lt)

function generate(x)
    μ = model(x, slope, intercept)
    sample1(μ, σ)
end

scatter!(ax, x, generate.(x))

####

function model(x, slope, intercept)
    μ = slope*x + intercept
    GLM.linkinv.(LogitLink(), μ)
end

sample1 = rand ∘ Bernoulli

n = 300
x = 5sort(rand(n) .- 0.5)
slope, intercept = (2, 1)

Random.seed!(0)
df = DataFrame(x = x)
@chain df begin 
    @transform! :y0 = model.(:x, slope, intercept)
    @transform! :success = sample1.(:y0)
end

data(df) * mapping(:x, :success) * visual(Scatter; label = "noisy data") |> draw()

m = glm(@formula(success ~ x), df, Binomial(), LogitLink())

fitted_intercept, fitted_slope = coef(m)

df.y = predict(m)

data(df) * (mapping(:x, :y0) * visual(Lines; label = "model") + mapping(:x, :y) * visual(Lines; color = :red, label = "fitted")) |> draw()

Random.seed!(0)
@chain df begin 
    @transform! :y0_predicted = model.(:x, fitted_slope, fitted_intercept)
    @transform! :success_predicted = sample1.(:y0_predicted)
    @transform! :same = :success_predicted .== :success
end

data(df) * mapping(:x, :success, color = :same) * visual(Scatter; alpha = 0.5) |> draw()
