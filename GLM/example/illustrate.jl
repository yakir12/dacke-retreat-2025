using MixedModels, GLM, CairoMakie, DataFrames, AlgebraOfGraphics, Distributions, Random
model(intercept, slope, x) = intercept + slope*x
measure(μ) = rand(Normal(μ, σ))
function sample1(X, Y, x, slope)
    μ = model(0, slope, x - X)
    measure(μ) + Y
end

ngroups = 20
n = 5
intercept = 5
slope = 0.5
σ = 0.005

bad_intercept = -intercept
bad_slope = -1/2

df = DataFrame(X = range(-0.5, 0.5, ngroups), id = 1:ngroups)
# df = DataFrame(X = rand(Uniform(-0.5, 0.5), ngroups), id = 1:ngroups)
transform!(df, :X => (X -> bad_intercept .+ bad_slope*X) => :Y)
transform!(df, :X => ByRow(X -> rand(Truncated(Normal(X, 0.05), -0.5, 0.5), n)) => :x)
df0 = flatten(df, :x)
# df0 = flatten(select(df, Not(:X)), :x)
transform!(df0, [:X, :Y, :x] => ByRow((X, Y, x) -> sample1(X, Y, x, slope)) => :y)


m2 = fit(MixedModel, @formula(y ~ 1 + x + (1|id)), df0)
ndf2 = flatten(combine(groupby(df0, :id), :x => extrema => :x), :x)
ndf2.y .= 0.0
ndf2.y .= predict(m2, ndf2)
rand_inter_lines = combine(groupby(ndf2, :id), [:x, :y] => ((x, y) -> Pair(Point2.(x, y)...)) => :segments).segments



h = 400
fig = Figure(size = (h / slope, h), backgroundcolor = :transparent)
ax = Axis(fig[1,1], aspect = DataAspect(), backgroundcolor = :transparent)
hscatter = scatter!(ax, df0.x, df0.y, color = :black)
hidedecorations!(ax; grid = false, minorgrid = false)
save("../media/12.svg", fig)

hablines = ablines!(ax, bad_intercept, bad_slope, color = :red)
save("../media/13.svg", fig)

delete!(ax, hablines)
delete!(ax, hscatter)

scatter!(ax, df0.x, df0.y, color = df0.id, marker = ('a':'z')[df0.id], colormap = Makie.wong_colors())
save("../media/14.svg", fig)

for (i, g) in enumerate(groupby(df0, :id))
    m = lm(@formula(y ~ 1 + x), g)
    a, b = coef(m)
    x = [extrema(g.x)...]
    y = a .+ b*x
    lines!(ax, x, y, color = i, colorrange = (1, ngroups), colormap = Makie.wong_colors())
end
save("../media/15.svg", fig)



function sample2(X, Y, x, intercept)
    slope = (Y - intercept)/X
    μ = model(intercept, slope, x)
    measure(μ)
end

ngroups = 20
n = 5
intercept = -2
slope = 0.5
σ = 0.005

bad_intercept = -intercept
bad_slope = -1/2

df = DataFrame(X = range(0.5, 1.5, ngroups), id = 1:ngroups)
# df = DataFrame(X = rand(Uniform(-0.5, 0.5), ngroups), id = 1:ngroups)
transform!(df, :X => (X -> bad_intercept .+ bad_slope*X) => :Y)
transform!(df, :X => ByRow(X -> rand(Truncated(Normal(X, 0.05), 0.5, 1.5), n)) => :x)
df0 = flatten(df, :x)
# df0 = flatten(select(df, Not(:X)), :x)
transform!(df0, [:X, :Y, :x] => ByRow((X, Y, x) -> sample2(X, Y, x, intercept)) => :y)


m2 = fit(MixedModel, @formula(y ~ 1 + x + (1|id)), df0)
ndf2 = flatten(combine(groupby(df0, :id), :x => extrema => :x), :x)
ndf2.y .= 0.0
ndf2.y .= predict(m2, ndf2)
rand_inter_lines = combine(groupby(ndf2, :id), [:x, :y] => ((x, y) -> Pair(Point2.(x, y)...)) => :segments).segments




h = 400
fig = Figure(size = (h / slope, h), backgroundcolor = :transparent)
ax = Axis(fig[1,1], aspect = DataAspect(), backgroundcolor = :transparent)
hscatter = scatter!(ax, df0.x, df0.y, color = :black)
# hidedecorations!(ax; grid = false, minorgrid = false)
save("../media/16.svg", fig)

hablines = ablines!(ax, bad_intercept, bad_slope, color = :red)
save("../media/17.svg", fig)

delete!(ax, hablines)
delete!(ax, hscatter)

scatter!(ax, df0.x, df0.y, color = df0.id, marker = ('a':'z')[df0.id], colormap = Makie.wong_colors())
save("../media/18.svg", fig)

h = Vector{Any}(undef, ngroups)
for (i, g) in enumerate(groupby(df0, :id))
    m = lm(@formula(y ~ 1 + x), g)
    a, b = coef(m)
    x = [extrema(g.x)...]
    y = a .+ b*x
    h[i] = lines!(ax, x, y, color = i, colorrange = (1, ngroups), colormap = Makie.wong_colors())
end
save("../media/19.svg", fig)

for hi in h
    delete!(ax, hi)
end

for (i, g) in enumerate(groupby(df0, :id))
    m = lm(@formula(y ~ 1 + x), g)
    a, b = coef(m)
    x = [extrema(g.x)...]
    x[1] = 0.0
    y = a .+ b*x
    lines!(ax, x, y, color = i, colorrange = (1, ngroups), colormap = Makie.wong_colors())
end
save("../media/20.svg", fig)


























#
# df = @lift transform(df0, [:x, :id] => ByRow((x, id) -> sample1(x, id, $individual_intercepts)) => :y)
#
# datapoints = @lift Point2.($df.x, $df.y)
#
# m1 = @lift lm(@formula(y ~ 1 + x), $df)
#
# m1p = @lift round(ftest($m1.model).pval, digits = 2)
#
# m1ab = @lift round.(coef($m1), digits = 2)
#
# m2 = @lift fit(MixedModel, @formula(y ~ 1 + x + (1|id)), $df)
#
# m2p = @lift round($m2.pvalues[2], digits = 2)
#
# m2ab = @lift round.(fixef($m2), digits = 2)
#
# ax1 = Axis(fig[2,1], title = "Fixed only")
# ablines!(ax1, intercept, slope, color = :gray, linewidth = 4)
# ablines!(ax1, map(first, m1ab), map(last, m1ab), color = :red)
# scatter!(ax1, datapoints, color = :black)
#
# ax2 = Axis(fig[2,2], title = "Random intercept")
# ablines!(ax2, intercept, slope, color = :gray, linewidth = 4)
# ablines!(ax2, map(first, m2ab), map(last, m2ab), color = :red)
# scatter!(ax2, datapoints, color = @lift($df.id), colorrange = (1, ngroups))
# linesegments!(ax2, rand_inter_lines, color = 1:ngroups, colorrange = (1, ngroups))
# hideydecorations!(ax2; grid = false, minorgrid = false)
#
# Label(fig[3,1], @lift(string("P = ", $m1p, ", intercept = ", round(Int, $m1ab[1]), ", slope = ", round(Int, $m1ab[2]))), tellwidth = false)
# Label(fig[3,2], @lift(string("P = ", $m2p, ", intercept = ", round(Int, $m2ab[1]), ", slope = ", round(Int, $m2ab[2]))), tellwidth = false)
# Label(fig[4,1:2], "intercept = $intercept, slope = $slope")
#
# linkaxes!(ax1, ax2)
#
# on(datapoints) do _
#     autolimits!(ax1)
# end
#
# display(fig)
#
#
#
#
#
#
#
#
# ∞ 
# …
#
#
#
#
#
# using CairoMakie, DataFrames, AlgebraOfGraphics, Distributions, CoordinateTransformations, Rotations
#
# rot = LinearMap(Angle2d(π/4))
#
# n = 1000
# w = 3.5
# x = rand(Uniform(-w, w), n)
# y = rand(Uniform(-1, 1), n)
# c0 = (3, -2)
# trans = Translation(c0...) ∘ rot
# xy = trans.(Point2f.(x, y))
# fig = Figure()
# ax = Axis(fig[1,1], aspect = DataAspect())
# scatter!(ax, xy, color = :black)
# save("../media/12.svg", fig)
#
# fig = Figure()
# ax = Axis(fig[1,1], aspect = DataAspect())
# c = round.(Int, x)
# scatter!(ax, xy, color = c, colormap = Makie.wong_colors())
# save("../media/13.svg", fig)
#
# c = [round(Int, 13atan(reverse(xy)...)/π) for xy in xy]
# fig = Figure()
# ax = Axis(fig[1,1], aspect = DataAspect())
# scatter!(ax, xy, color = c, colormap = Makie.wong_colors())
# save("../media/14.svg", fig)
