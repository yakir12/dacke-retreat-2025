using CairoMakie

using Distributions

μ = 7
d = Normal(μ, 0.5)
n = 1000
x = rand(d, n)
filter!(x -> 5 < x < 9, x)
n = length(x)

w = 200
fig = Figure(backgroundcolor = :transparent, size = (w, 2*w))
ax = Axis(fig[1,1], xlabel = "measurement", ylabel = "#", xticks = 5:9, backgroundcolor = :transparent)
rainclouds!(ax, ones(n), x, plot_boxplots = false, orientation = :horizontal, clouds = hist)
vlines!(ax, μ, color = :red)
hideydecorations!(ax)

save("../media/measurement.svg", fig)



intercept = Observable(3)
slope = Observable(2)
x = 1:5
y = @lift $intercept .+ $slope * x

w = 200
fig = Figure(backgroundcolor = :transparent, size = (w, slope[]*w))
ax = Axis(fig[1,1], aspect = 1/slope[], xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
onany(ax.finallimits, intercept, slope) do lims, intercept, slope
    (xmin, ymin), (xmax, ymax) = extrema(lims)
    xtickvals, _ = Makie.get_ticks(ax.xticks[], ax.xscale[], ax.xtickformat[], xmin, xmax)
    ax.yticks = xtickvals .* slope .+ intercept
end
lines!(ax, x, y)
text!(ax, 2.5, intercept[] + slope[]*2.5; text = "$(intercept[]) + $(slope[])x", rotation = atan(slope[]), align = (:left, :bottom))
resize_to_layout!(fig)

save("../media/linear.svg", fig)



w = 200
fig = Figure(backgroundcolor = :transparent, size = (w, slope[]*w))
ax = Axis(fig[1,1], aspect = 1/slope[], xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
onany(ax.finallimits, intercept, slope) do lims, intercept, slope
    (xmin, ymin), (xmax, ymax) = extrema(lims)
    xtickvals, _ = Makie.get_ticks(ax.xticks[], ax.xscale[], ax.xtickformat[], xmin, xmax)
    ax.yticks = xtickvals .* slope .+ intercept
end
lines!(ax, x, y)
n = 30
x = fill(2, n)
y = intercept[] .+ slope[]*x .+ randn(n)/2
rainclouds!(ax, x, y, plot_boxplots = false, clouds = nothing, jitter_width = 0.2, color = (:red, 0.25), markersize = 7)
# scatter!(ax, x .+ randn(n)/20, y, color = (:red, 0.5), markersize = 7)
text!(ax, 2.5, intercept[] + slope[]*2.5; text = "$(intercept[]) + $(slope[])x", rotation = atan(slope[]), align = (:left, :bottom))
resize_to_layout!(fig)

save("../media/linear+noise.svg", fig)


# using Random
# using GLMakie, AlgebraOfGraphics, Distributions, DataFrames, Chain, DataFramesMeta
# using GLM, CoordinateTransformations, Rotations

using DataFrames, DataFramesMeta, Chain, AlgebraOfGraphics, Distributions

# using GLMakie

intercept = 3
slope = 2
σ = 2

model(x) = intercept + slope*x
function measure(μ)
    d = Normal(μ, σ)
    rand(d)
end

n = 100
x = 5rand(n)

# Random.seed!(0)
df = DataFrame(x = x)
@chain df begin
    @transform! :parameters = model.(:x)
    @transform! :measurement = measure.(:parameters)
end


w = 200
fig = Figure(backgroundcolor = :transparent, size = (w, slope*w))
ax = Axis(fig[1,1], aspect = 1/slope, xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
lines!(ax, df.x, df.parameters, label = "model")
scatter!(ax, x, df.measurement, color = (:red, 0.5), markersize = 7, label = "measurement")
# axislegend(ax, position = :lt)
resize_to_layout!(fig)

save("../media/model+measurement.svg", fig)

w = 200
fig = Figure(backgroundcolor = :transparent, size = (w, slope*w))
ax = Axis(fig[1,1], aspect = 1/slope, xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
scatter!(ax, x, df.measurement, color = (:red, 0.5), markersize = 7, label = "measurement")
# axislegend(ax, position = :lt)
resize_to_layout!(fig)

save("../media/measurements.svg", fig)
# fig = Figure()
# ax1 = Axis(fig[1,1], aspect = 1, xlabel = "predictor")
# hist!(ax1, df.predictor)
# ax2 = Axis(fig[1,2], aspect = 1, xlabel = "measurement")
# hist!(ax2, df.measurement)
# ax3 = Axis(fig[1,3], aspect = 1, xlabel = "ϵ")
# hist!(ax3, df.parameters - df.measurement)
#
#
