using GLMakie, AlgebraOfGraphics, Distributions, DataFrames, Chain, DataFramesMeta
using GLM, CoordinateTransformations, Rotations

function model(x, a, b)
    μ = a*x + b
    # identity(μ)
end

sample1 = rand ∘ Normal

n = 100
x = 10rand(n)
a, b = (5, 15)
σ = 2

df = DataFrame(x = x)
@chain df begin
    @transform! :y0 = model.(:x, a, b)
    @transform! :y = sample1.(:y0, σ)
end

fig = Figure()
ax1 = Axis(fig[1,1], aspect = 1, xlabel = "x")
hist!(ax1, df.x)
ax2 = Axis(fig[1,2], aspect = 1, xlabel = "y")
hist!(ax2, df.y)
ax3 = Axis(fig[1,3], aspect = 1, xlabel = "ϵ")
hist!(ax3, df.y0 - df.y)

data(df) * (mapping(:x, :y0) * visual(Lines; color = :red, label = "$a*x + $b") + mapping(:x, :y) * visual(Scatter; label = "noisy data")) |> draw()

m = lm(@formula(y ~ x), df)
b̂, â = coef(m)

@chain df begin
    @transform! :ŷ = â * :x .+ b̂
    @transform! :ϵ̂ = :y .- :ŷ
end

@assert df.ŷ == predict(m)
@assert df.ϵ̂ == residuals(m)

d = Distributions.fit(Normal, residuals(m))

fig = Figure()
ax = Axis(fig[1,1], xlabel = "x", ylabel = "y")
lines!(ax, df.x, df.y0, label = "phenomenon", color = :black)

scatter!(ax, df.x, df.y, label = "measurements", color = :green)

lines!(ax, df.x, df.ŷ, label = "fit", color = :red)

rangebars!(ax, df.x, df.y, df.ŷ, label = "residuals", color = :gray)
axislegend(ax, position = :lt)

function generate(x)
    μ = model(x, a, b)
    sample1(μ, σ)
end

scatter!(ax, x, generate.(x))

####

function model(x, a, b)
    μ = a*x + b
    GLM.linkinv.(LogitLink(), μ)
end

sample1 = rand ∘ Bernoulli

n = 300
x = 5sort(rand(n) .- 0.5)
a, b = (2, 1)

Random.seed!(1234)
df = DataFrame(x = x)
@chain df begin 
    @transform! :y0 = model.(:x, a, b)
    @transform! :success = sample1.(:y0)
end

data(df) * mapping(:x, :success => Float64) * visual(Scatter; label = "noisy data") |> draw()

m = glm(@formula(success ~ x), df, Binomial(), LogitLink())

b̂, â = coef(m)

df.y = predict(m)

data(df) * (mapping(:x, :y0) * visual(Lines; label = "model") + mapping(:x, :y) * visual(Lines; color = :red, label = "fitted")) |> draw()

Random.seed!(1234)
