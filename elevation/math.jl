using GLMakie, CoordinateTransformations, FileIO, GeometryBasics, Rotations, LinearAlgebra

fig = Figure()

n = 101

ax = Axis3(fig[1, 1], aspect = :data, limits = ((-0.1, 1.2), (-1, 1), (-0.1, 1.2)))

sg = SliderGrid(
    fig[2, 1],
    (label = "Elevation", range = 0:90, format = "{:n}°", startvalue = 0),
    (label = "Error", range = 0:180, format = "{:n}°", startvalue = 0),
    tellwidth = false)

θdeg, ϵdeg = [s.value for s in sg.sliders]
θ, ϵ = [map(deg2rad, s.value) for s in sg.sliders]

sector = map(θ, ϵ) do θ, ϵ
    xyz = [zero(Point3f), Point3f.(CartesianFromSpherical().(Spherical.(1, range(-ϵ/2, ϵ/2, n - 2), 0)))..., zero(Point3f)]
    rot = LinearMap(RotY(-θ))
    rot.(xyz)
end
sectorc = @lift $sector[n ÷ 2 + 1]

shadow = map(x -> Point2f.(x), sector)
shadowc = @lift Point3f($shadow[n ÷ 2 + 1]..., 0)

trianglev = @lift [zero(Point3f), $shadowc, $sectorc, zero(Point3f)]
triangleh = @lift [zero(Point2f), $shadow[2], $shadow[end-1], zero(Point2f)]

Εdeg = @lift round(Int, 2atand(tan($ϵ/2)/cos($θ)))

lines!(ax, sector, color = :black)
lines!(ax, shadow, color = :red)
lines!(ax, trianglev, color = :gray)
lines!(ax, triangleh, color = :gray)

sectorh = text!(ax, zero(Point3f), text = @lift(string($ϵdeg, " °")), color = :black, align = (:center, :center), markerspace = :data, fontsize = 0.1, transform_marker = true, overdraw = true)

sectorc0 = sectorc[]
on(sectorc) do sectorc
    quat = Makie.rotation_between(Vec3f(sectorc0), Vec3f(sectorc))
    Makie.rotate!(sectorh, quat)
    Makie.rotate!(Accum, sectorh, -pi/2)
    Makie.translate!(sectorh, 0.9sectorc...)
end

shadowh = text!(ax, zero(Point3f), text = @lift(string($Εdeg, " °")), color = :red, align = (:center, :center), markerspace = :data, fontsize = 0.1, transform_marker = true, overdraw = true)

shadowc0 = shadowc[]
on(shadowc) do shadowc
    quat = Makie.rotation_between(Vec3f(shadowc0), Vec3f(shadowc))
    Makie.rotate!(shadowh, -pi/2)
    Makie.translate!(shadowh, 0.9shadowc)
end

on(shadow) do shadow
    p1 = shadow[end-1]
    @show 2atand(reverse(p1)...)
end


hidedecorations!(ax)

fig











# sun = @lift CartesianFromSpherical()(Spherical(1, 0, $θ))
#
# xyz0 = @lift Point3f.(CartesianFromSpherical().(Spherical.(0.5, range(-$ϵ/2, $ϵ/2, 100), 0)))
#
# xyz = map(θ, xyz0) do θ, xyz0
#     rot = LinearMap(RotY(-θ))
#     xyz = rot.(xyz0)
#     pushfirst!(xyz, zero(Point3f))
#     push!(xyz, zero(Point3f))
# end
#
# extrinsic = map(x -> Point2f.(x), xyz)
#
# Ε = @lift 2atan(tan($ϵ/2)/cos($θ))
#
# actual = map(Ε) do Ε
#     xy = Point2f.(CartesianFromSpherical().(Spherical.(1, range(-Ε/2, Ε/2, 100), 0)))
#     pushfirst!(xy, zero(Point2f))
#     push!(xy, zero(Point2f))
# end
#
# # actual = map(extrinsic) do xy
# #     p1 = normalize(xy[2])
# #     p2 = normalize(xy[end - 1])
# #     [zero(Point2f), p1, p2, zero(Point2f)]
# # end
#
# intrinsic = map(xyz) do xyz
#     xy = Point2f.(xyz)
#     f =  faces(Polygon(xy))
#     GeometryBasics.Mesh(xyz, f)
# end
#
# # extrinsic = map(θ, xyz0) do θ, xyz0
# #     rot = LinearMap(RotY(-θ))
# #     xyz = rot.(xyz0)
# #     pushfirst!(xyz, zero(Point3f))
# #     push!(xyz, zero(Point3f))
# #     xy = Point2f.(xyz)
# # end
# #
# # intrinsic = map(extrinsic) do xy
# #     f =  faces(Polygon(xy))
# #     GeometryBasics.Mesh(xyz, f)
# # end
#
#
#
# # w, h = size(img)
# # ratio = 10000
# # x = range(-w/ratio, w/ratio, w)
# # y = range(-h/ratio, h/ratio, h)
# # z = zeros(w, h)
# # surface!(ax, x, y, z, color = img)
#
# # poly!(ax, @lift(Sphere(Point3f($sun), 0.1)), color = :yellow)
# mesh!(ax, intrinsic, color = :red, backlight = 0.5)
# mesh!(ax, extrinsic, color = :gray, backlight = 0.5)
# lines!(ax, actual)
# text!(ax, [Point3f(1,0,0)], text = @lift([string(round(Int, rad2deg($Ε)), " °")]), rotation = -π/2, fontsize = .1, markerspace = :data)
# # lines!(ax, intrinsic, color = :red)
#
# hidedecorations!(ax)
# # hidespines!(ax)
#
# fig
#
#
# #################
#
# using Distributions
#
# function rand_on_sphere(d)
#     u = rand()
#     ϕ = rand(d)
#     θ = 2π*u
#     CartesianFromSpherical()(Spherical(1, θ, ϕ))
# end
# d = VonMises(π/2, 100)
# n = 100000
# xyz = [rand_on_sphere(d) for _ in 1:n];
# hist(rand((-1, 1), n) .* (getfield.(SphericalFromCartesian().(xyz), :ϕ) .- π/2) .+ π/2, bins = 1000, normalization = :pdf)
# lines!(d)
# rot = LinearMap(RotX(0.9-π/2))
# xyz .= rot.(xyz)
# scatter()
# scatter!(zero(Point3f))
#
# hist(splat(atan).(reverse.(Point2f.(xyz))), bins = 1000, normalization = :pdf)
#
#
#
