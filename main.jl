using Random
using GLMakie, AlgebraOfGraphics, Distributions, DataFrames, Chain, DataFramesMeta
using GLM, CoordinateTransformations, Rotations

function model(predictor, slope, intercept)
    μ = slope*predictor + intercept
    # identity(μ)
end

sample1 = rand ∘ Normal

n = 100
predictor = 10rand(n)
intercept, slope = (15, 5)
σ = 2

Random.seed!(0)
df = DataFrame(predictor = predictor)
@chain df begin
    @transform! :parameters = model.(:predictor, slope, intercept)
    @transform! :measurement = sample1.(:parameters, σ)
end

fig = Figure()
ax1 = Axis(fig[1,1], aspect = 1, xlabel = "predictor")
hist!(ax1, df.predictor)
ax2 = Axis(fig[1,2], aspect = 1, xlabel = "measurement")
hist!(ax2, df.measurement)
ax3 = Axis(fig[1,3], aspect = 1, xlabel = "ϵ")
hist!(ax3, df.parameters - df.measurement)

data(df) * (mapping(:predictor, :parameters) * visual(Lines; color = :red, label = "parameters") + mapping(:predictor, :measurement) * visual(Scatter; label = "measurement")) |> draw()

m = lm(@formula(measurement ~ 1 + predictor), df)
fitted_intercept, fitted_slope = coef(m)
fitted_sigma = std(residuals(m))

Random.seed!(0)
@chain df begin
    @transform! :fitted_parameters = model.(:predictor, fitted_slope, fitted_intercept)
    @transform! :fitted_measurement = sample1.(:fitted_parameters, fitted_sigma)
    @transform! :ϵ̂ = :parameters .- :fitted_parameters
end

@assert df.fitted_parameters == predict(m)

fig = Figure()
ax = Axis(fig[1,1], xlabel = "predictor", ylabel = "measurement")
lines!(ax, df.predictor, df.parameters, label = "parameters", color = :red)

scatter!(ax, df.predictor, df.measurement, label = "measurements", color = :black)

lines!(ax, df.predictor, df.fitted_parameters, label = "fit", color = :green)

rangebars!(ax, df.predictor, df.measurement, df.fitted_parameters, label = "residuals", color = :gray)

scatter!(ax, df.predictor, df.fitted_measurement, label = "fitted measurements", color = :green)

axislegend(ax, position = :lt)

function generate(predictor)
    μ = model(predictor, slope, intercept)
    sample1(μ, σ)
end

scatter!(ax, predictor, generate.(predictor))

#### Binomial

function model(predictor, slope, intercept)
    μ = slope*predictor + intercept
    GLM.linkinv.(LogitLink(), μ)
end

sample1 = rand ∘ Bernoulli

n = 300
predictor = 5sort(rand(n) .- 0.5)
intercept, slope = (2, 1)

Random.seed!(0)
df = DataFrame(predictor = predictor)
@chain df begin 
    @transform! :parameters = model.(:predictor, slope, intercept)
    @transform! :success = sample1.(:parameters)
end

data(df) * mapping(:predictor, :success) * visual(Scatter; label = "data") |> draw()

m = glm(@formula(success ~ predictor), df, Binomial(), LogitLink())

fitted_intercept, fitted_slope = coef(m)

Random.seed!(0)
@chain df begin 
    @transform! :fitted_parameters = model.(:predictor, fitted_slope, fitted_intercept)
    @transform! :fitted_sucesss = sample1.(:fitted_parameters)
    @transform! :same = :fitted_sucesss .== :success
end

@assert df.fitted_parameters ≈ predict(m)

data(df) * (mapping(:predictor, :parameters) * visual(Lines; label = "model") + mapping(:predictor, :fitted_parameters) * visual(Lines; color = :red, label = "fitted")) |> draw()

data(df) * mapping(:predictor, :success, color = :same) * visual(Scatter; alpha = 0.5) |> draw()

####

using Turing

@model function bmodel(predictor, measurement)
    s² ~ InverseGamma(2, 3)
    slope ~ Normal(0, 10)
    intercept ~ Normal(10, 10)
    μ = intercept .+ slope*predictor
    measurement ~ MvNormal(μ, sqrt(s²))
end

function model(predictor, slope, intercept)
    μ = slope*predictor + intercept
    # identity(μ)
end

sample1 = rand ∘ Normal

n = 100
predictor = 10rand(n)
intercept, slope = (15, 5)
σ = 2

Random.seed!(0)
df = DataFrame(predictor = predictor)
@chain df begin
    @transform! :parameters = model.(:predictor, slope, intercept)
    @transform! :measurement = sample1.(:parameters, σ)
end

chain = sample(bmodel(df.predictor, df.measurement), NUTS(), 1000, progress=false)

fig = Figure()
for (i, var_name) in enumerate((:s², :slope, :intercept))
    draw!(
        fig[i, 1],
        data(chain) *
        mapping(var_name; color=:chain => nonnumeric) *
        AlgebraOfGraphics.density() *
        visual(fillalpha=0)
    )
end
