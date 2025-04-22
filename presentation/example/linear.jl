using CairoMakie
using Distributions

slope = 2
intercept = 3
σ = 1
x = 1:5
model(x) = intercept + slope*x
measure(μ) = rand(Normal(μ, σ))
y = model.(x)
w = 200
fig = Figure(size = (w, slope * w), backgroundcolor = :transparent);
ax = Axis(fig[1,1], xlabel = "x", ylabel = "y", backgroundcolor = :transparent, aspect = 1/slope, xticks = x, yticks = y, limits = ((x[1] - 1, x[end] + 1), (y[1] - 1, y[end] + 1)))
modelh = lines!(ax, x, y)

save("../media/0.svg", fig)

xtext = mean(x)
texth = text!(ax, xtext, model(xtext); text = "$intercept + $(slope)x", rotation = atan(slope), align = (:center, :bottom))

save("../media/1.svg", fig)
delete!(ax, texth)

n = 30
x2 = fill(2, n)
y2 = measure.(model.(x2))
noise2h = rainclouds!(ax, x2, y2, plot_boxplots = false, clouds = nothing, jitter_width = 0.2, color = (:red, 0.25), markersize = 7)
n = 30
xr = 1 .+ 4rand(n)
yr = measure.(model.(xr))

save("../media/2.svg", fig)
delete!(ax, noise2h)

measurementsh = scatter!(ax, xr, yr, color = (:red, 0.5), markersize = 7, label = "measurement")

save("../media/3.svg", fig)
delete!(ax, modelh)

save("../media/4.svg", fig)


# LM

using GLM
df = (; x = xr, y = yr)
m = lm(@formula(y ~ 1 + x), df)
fitted_intercept, fitted_slope = coef(m)
fitted_sigma = std(residuals(m))

yl = fitted_intercept .+ fitted_slope * x
modelh = lines!(ax, x, yl, color = :green)

save("../media/5.svg", fig)

residualsh = rangebars!(ax, xr, yr, predict(m), color = :gray)

save("../media/6.svg", fig)

delete!(ax, measurementsh)
delete!(ax, modelh)

save("../media/7.svg", fig)

fig = Figure(size = (w, slope * w), backgroundcolor = :transparent);
ax = Axis(fig[1,1], xlabel = "residuals", ylabel = "#", backgroundcolor = :transparent, limits = ((-3, 3), nothing))
hist!(ax, residuals(m); normalization = :pdf)

save("../media/8.svg", fig)

dist = Normal(0, 1)

lines!(ax, dist, color = :red)

save("../media/9.svg", fig)

intercept, slope = (-1, 2)

function model(x)
    μ = intercept + slope*x
    GLM.linkinv.(LogitLink(), μ)
end

function measure(p)
    dist = Bernoulli(p)
    rand(dist)
end

n = 300
x = 4sort(rand(n)) .+ 1

y = intercept .+ slope*(x)
p = GLM.linkinv.(LogitLink(), y)
tf = measure.(p)

function count





#
# # set_theme!(Theme(Figure(size = (200, 400), backgroundcolor = :transparent), Axis(
#
# μ = 7
# d = Normal(μ, 0.5)
# n = 1000
# x = rand(d, n)
# filter!(x -> 5 < x < 9, x)
# n = length(x)
#
# fig = Figure(figure...)
# ax = Axis(fig[1,1], xlabel = "measurement", ylabel = "#", xticks = 5:9, backgroundcolor = :transparent)
# rainclouds!(ax, ones(n), x, plot_boxplots = false, orientation = :horizontal, clouds = hist)
# vlines!(ax, μ, color = :red)
# hideydecorations!(ax)
#
# save("../media/measurement noise.svg", fig)
#
#
#
# intercept = Observable(3)
# slope = Observable(2)
# x = 1:5
# y = @lift $intercept .+ $slope * x
#
#
# fig = Figure(figure...)
# ax = Axis(fig[1,1], aspect = 1/slope[], xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
# onany(ax.finallimits, intercept, slope) do lims, intercept, slope
#     (xmin, ymin), (xmax, ymax) = extrema(lims)
#     xtickvals, _ = Makie.get_ticks(ax.xticks[], ax.xscale[], ax.xtickformat[], xmin, xmax)
#     ax.yticks = xtickvals .* slope .+ intercept
# end
# lines!(ax, x, y)
# # resize_to_layout!(fig)
#
# save("../media/model.svg", fig)
#
#
#
# w = 200
# fig = Figure(backgroundcolor = :transparent, size = (w, slope[]*w))
# ax = Axis(fig[1,1], aspect = 1/slope[], xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
# onany(ax.finallimits, intercept, slope) do lims, intercept, slope
#     (xmin, ymin), (xmax, ymax) = extrema(lims)
#     xtickvals, _ = Makie.get_ticks(ax.xticks[], ax.xscale[], ax.xtickformat[], xmin, xmax)
#     ax.yticks = xtickvals .* slope .+ intercept
# end
# lines!(ax, x, y)
# text!(ax, 2.5, intercept[] + slope[]*2.5; text = "$(intercept[]) + $(slope[])x", rotation = atan(slope[]), align = (:left, :bottom))
# # resize_to_layout!(fig)
#
# save("../media/linear.svg", fig)
#
#
#
# w = 200
# fig = Figure(backgroundcolor = :transparent, size = (w, slope[]*w))
# ax = Axis(fig[1,1], aspect = 1/slope[], xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
# onany(ax.finallimits, intercept, slope) do lims, intercept, slope
#     (xmin, ymin), (xmax, ymax) = extrema(lims)
#     xtickvals, _ = Makie.get_ticks(ax.xticks[], ax.xscale[], ax.xtickformat[], xmin, xmax)
#     ax.yticks = xtickvals .* slope .+ intercept
# end
# lines!(ax, x, y)
# n = 30
# x = fill(2, n)
# y = intercept[] .+ slope[]*x .+ randn(n)/2
# rainclouds!(ax, x, y, plot_boxplots = false, clouds = nothing, jitter_width = 0.2, color = (:red, 0.25), markersize = 7)
# # scatter!(ax, x .+ randn(n)/20, y, color = (:red, 0.5), markersize = 7)
# text!(ax, 2.5, intercept[] + slope[]*2.5; text = "$(intercept[]) + $(slope[])x", rotation = atan(slope[]), align = (:left, :bottom))
# # resize_to_layout!(fig)
#
# save("../media/linear+noise.svg", fig)
#
#
# # using Random
# # using GLMakie, AlgebraOfGraphics, Distributions, DataFrames, Chain, DataFramesMeta
# # using GLM, CoordinateTransformations, Rotations
#
# using DataFrames, DataFramesMeta, Chain, AlgebraOfGraphics, Distributions
#
# # using GLMakie
#
# intercept = 3
# slope = 2
# σ = 2
#
# model(x) = intercept + slope*x
# function measure(μ)
#     d = Normal(μ, σ)
#     rand(d)
# end
#
# n = 100
# x = 5rand(n)
#
# # Random.seed!(0)
# df = DataFrame(x = x)
# @chain df begin
#     @transform! :parameters = model.(:x)
#     @transform! :measurement = measure.(:parameters)
# end
#
#
# w = 200
# fig = Figure(backgroundcolor = :transparent, size = (w, slope*w))
# ax = Axis(fig[1,1], aspect = 1/slope, xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
# lines!(ax, df.x, df.parameters, label = "model")
# scatter!(ax, x, df.measurement, color = (:red, 0.5), markersize = 7, label = "measurement")
# # axislegend(ax, position = :lt)
# resize_to_layout!(fig)
#
# save("../media/model+measurement.svg", fig)
#
# w = 200
# fig = Figure(backgroundcolor = :transparent, size = (w, slope*w))
# ax = Axis(fig[1,1], aspect = 1/slope, xlabel = "x", ylabel = "y", backgroundcolor = :transparent)
# scatter!(ax, x, df.measurement, color = (:red, 0.5), markersize = 7, label = "measurement")
# # axislegend(ax, position = :lt)
# resize_to_layout!(fig)
#
# save("../media/measurements.svg", fig)
# # fig = Figure()
# # ax1 = Axis(fig[1,1], aspect = 1, xlabel = "predictor")
# # hist!(ax1, df.predictor)
# # ax2 = Axis(fig[1,2], aspect = 1, xlabel = "measurement")
# # hist!(ax2, df.measurement)
# # ax3 = Axis(fig[1,3], aspect = 1, xlabel = "ϵ")
# # hist!(ax3, df.parameters - df.measurement)
# #
# #
