using CairoMakie

intercept = 3
slope = 2

independent = 1:5
dependent = intercept .+ slope*independent

w = 200
fig = Figure(size = (w, slope*w))
ax = Axis(fig[1,1], aspect = 1/slope, xlabel = "independent", ylabel = "dependent", yticks = )
lines!(ax, independent, dependent)
text!(2.5, intercept + slope*2.5; text = "$intercept + $slope*independent", rotation = atan(slope), align = (:left, :bottom))
resize_to_layout!(fig)

save("../media/linear.svg", fig)

fig
