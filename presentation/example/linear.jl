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

