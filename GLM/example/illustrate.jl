using CairoMakie, DataFrames, AlgebraOfGraphics, Distributions, CoordinateTransformations, Rotations

rot = LinearMap(Angle2d(π/4))

n = 1000
w = 3.5
x = rand(Uniform(-w, w), n)
y = rand(Uniform(-1, 1), n)
c0 = (3, -2)
trans = Translation(c0...) ∘ rot
xy = trans.(Point2f.(x, y))
fig = Figure()
ax = Axis(fig[1,1], aspect = DataAspect())
scatter!(ax, xy, color = :black)
save("../media/12.svg", fig)

fig = Figure()
ax = Axis(fig[1,1], aspect = DataAspect())
c = round.(Int, x)
scatter!(ax, xy, color = c, colormap = Makie.wong_colors())
save("../media/13.svg", fig)

c = [round(Int, 13atan(reverse(xy)...)/π) for xy in xy]
fig = Figure()
ax = Axis(fig[1,1], aspect = DataAspect())
scatter!(ax, xy, color = c, colormap = Makie.wong_colors())
save("../media/14.svg", fig)
