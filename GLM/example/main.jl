using MixedModels, GLM, GLMakie, DataFrames, AlgebraOfGraphics, Distributions

ngroups = 10
n = 10
intercept = 5
slope = 1
σ = 0.1

individual_intercepts = randn(ngroups)
individual_slopes = randn(ngroups)

df = DataFrame(seed = rand(ngroups) .- 0.5, id = 1:ngroups)
transform!(df, :seed => ByRow(seed -> rand(Truncated(Normal(seed, 0.1), -0.5, 0.5), n)) => :x)
df0 = flatten(select(df, Not(:seed)), :x)

# df0 = DataFrame(x = rand(n), id = rand(1:ngroups, n))
ndf2 = flatten(combine(groupby(df0, :id), :x => extrema => :x), :x)
ndf2.y .= 0.0
ndf2pop = DataFrame(x = -0.5:0.5, y = zeros(2), id = fill(ngroups + 1, 2))
ndf3 = flatten(combine(groupby(df0, :id), :x => extrema => :x), :x)
ndf3.y .= 0.0
ndf3pop = DataFrame(x = -0.5:0.5, y = zeros(2), id = fill(ngroups + 1, 2))

random_effects(id, intercept_factor, slope_factor) = (intercept_factor * individual_intercepts[id], slope_factor * individual_slopes[id])
model(intercept, slope, x) = intercept + slope*x
measure(μ) = rand(Normal(μ, σ))
function sample1(x, id, intercept_factor, slope_factor)
    individual_intercept, individual_slope = random_effects(id, intercept_factor, slope_factor)
    μ = model(individual_intercept + intercept, individual_slope + slope, x)
    measure(μ)
end

fig = Figure()
sg = SliderGrid(fig[1, 1:3], (label = "intercept factor", range = 0:0.1:10, startvalue = 0), (label = "slope factor", range = 0:0.1:10, startvalue = 0))

intercept_factor, slope_factor = [s.value for s in sg.sliders]

df = @lift transform(df0, [:x, :id] => ByRow((x, id) -> sample1(x, id, $intercept_factor, $slope_factor)) => :y)

datapoints = @lift Point2.($df.x, $df.y)

m1 = @lift lm(@formula(y ~ 1 + x), $df)

lmline = map(m1) do m1
    ndf = DataFrame(x = -0.5:0.5, y = zeros(2))
    ndf.y .= predict(m1, ndf)
    Point2.(ndf.x, ndf.y)
end

m1p = @lift ftest($m1.model).pval

m2 = @lift fit(MixedModel, @formula(y ~ 1 + x + (1|id)), $df)

rand_inter_lines = map(m2) do m2
    ndf2.y .= predict(m2, ndf2)
    combine(groupby(ndf2, :id), [:x, :y] => ((x, y) -> Pair(Point2.(x, y)...)) => :segments).segments
end

ndf2pop_line = map(m2) do m2
    ndf2pop.y .= predict(m2, ndf2pop, new_re_levels=:population)
    Point2.(ndf2pop.x, ndf2pop.y)
end

m2p = @lift $m2.pvalues[2]

m3 = @lift fit(MixedModel, @formula(y ~ 1 + x + (1+x|id)), $df)

rand_inter_slope_lines = map(m3) do m3
    ndf3.y .= predict(m3, ndf3)
    combine(groupby(ndf3, :id), [:x, :y] => ((x, y) -> Pair(Point2.(x, y)...)) => :segments).segments
end

ndf3pop_line = map(m3) do m3
    ndf3pop.y .= predict(m3, ndf3pop, new_re_levels=:population)
    Point2.(ndf3pop.x, ndf3pop.y)
end

m3p = @lift $m3.pvalues[2]

ax1 = Axis(fig[2,1], title = @lift(string("Fixed only\nP = ", $m1p)))#round($m1p, digits = 2))))
ablines!(ax1, intercept, slope, color = :gray, linewidth = 4)
scatter!(ax1, datapoints)
lines!(ax1, lmline, linewidth = 4)

ax2 = Axis(fig[2,2], title = @lift(string("Random intercept\nP = ", $m2p)))# round($m2p, digits = 2))))
ablines!(ax2, intercept, slope, color = :gray, linewidth = 4)
scatter!(ax2, datapoints, color = @lift($df.id), colorrange = (1, ngroups))
linesegments!(ax2, rand_inter_lines, color = 1:ngroups, colorrange = (1, ngroups))
lines!(ax2, ndf2pop_line, color = :black, linewidth = 4)
hideydecorations!(ax2; grid = false, minorgrid = false)

ax3 = Axis(fig[2,3], title = @lift(string("Random intercept & slope\nP = ", $m3p)))# round($m3p, digits = 2))))
ablines!(ax3, intercept, slope, color = :gray, linewidth = 4)
scatter!(ax3, datapoints, color = @lift($df.id), colorrange = (1, ngroups))
linesegments!(ax3, rand_inter_slope_lines, color = 1:ngroups, colorrange = (1, ngroups))
lines!(ax3, ndf3pop_line, color = :black, linewidth = 4)
hideydecorations!(ax3; grid = false, minorgrid = false)

linkaxes!(ax1, ax2)
linkaxes!(ax2, ax3)

on(datapoints) do _
    autolimits!(ax1)
end


display(fig)



