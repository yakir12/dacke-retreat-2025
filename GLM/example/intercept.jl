using MixedModels, GLM, GLMakie, DataFrames, AlgebraOfGraphics, Distributions, Random

ngroups = 6
n = 10
intercept = 5
slope = 2
σ = 0.1


df = DataFrame(seed = rand(ngroups) .- 0.5, id = 1:ngroups)
transform!(df, :seed => ByRow(seed -> rand(Truncated(Normal(seed, 0.2), -0.5, 0.5), n)) => :x)
df0 = flatten(select(df, Not(:seed)), :x)

ndf2 = flatten(combine(groupby(df0, :id), :x => extrema => :x), :x)
ndf2.y .= 0.0

model(intercept, slope, x) = intercept + slope*x
measure(μ) = rand(Normal(μ, σ))

function individual_noise(σ)
    rand(Normal(0, σ), ngroups)
end

function sample1(x, id, individual_intercepts)
    μ = model(individual_intercepts[id] + intercept, slope, x)
    measure(μ)
end

fig = Figure()
sg = SliderGrid(fig[1, 1:2], (label = "intercept std", range = 0:0.1:10, startvalue = 0))

intercept_sigma = sg.sliders[].value

individual_intercepts = map(individual_noise, intercept_sigma)

df = @lift transform(df0, [:x, :id] => ByRow((x, id) -> sample1(x, id, $individual_intercepts)) => :y)

datapoints = @lift Point2.($df.x, $df.y)

m1 = @lift lm(@formula(y ~ 1 + x), $df)

m1p = @lift round(ftest($m1.model).pval, digits = 2)

m1ab = @lift round.(coef($m1), digits = 2)

m2 = @lift fit(MixedModel, @formula(y ~ 1 + x + (1|id)), $df)

rand_inter_lines = map(m2) do m2
    ndf2.y .= predict(m2, ndf2)
    combine(groupby(ndf2, :id), [:x, :y] => ((x, y) -> Pair(Point2.(x, y)...)) => :segments).segments
end

m2p = @lift round($m2.pvalues[2], digits = 2)

m2ab = @lift round.(fixef($m2), digits = 2)

ax1 = Axis(fig[2,1], title = "Fixed only")
ablines!(ax1, intercept, slope, color = :gray, linewidth = 4)
ablines!(ax1, map(first, m1ab), map(last, m1ab), color = :red)
scatter!(ax1, datapoints, color = :black)

ax2 = Axis(fig[2,2], title = "Random intercept")
ablines!(ax2, intercept, slope, color = :gray, linewidth = 4)
ablines!(ax2, map(first, m2ab), map(last, m2ab), color = :red)
scatter!(ax2, datapoints, color = @lift($df.id), colorrange = (1, ngroups))
linesegments!(ax2, rand_inter_lines, color = 1:ngroups, colorrange = (1, ngroups))
hideydecorations!(ax2; grid = false, minorgrid = false)

Label(fig[3,1], @lift(string("P = ", $m1p, ", intercept = ", round(Int, $m1ab[1]), ", slope = ", round(Int, $m1ab[2]))), tellwidth = false)
Label(fig[3,2], @lift(string("P = ", $m2p, ", intercept = ", round(Int, $m2ab[1]), ", slope = ", round(Int, $m2ab[2]))), tellwidth = false)
Label(fig[4,1:2], "intercept = $intercept, slope = $slope")

linkaxes!(ax1, ax2)

on(datapoints) do _
    autolimits!(ax1)
end

display(fig)

