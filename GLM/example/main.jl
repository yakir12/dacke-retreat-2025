using MixedModels, GLM, GLMakie, DataFrames, AlgebraOfGraphics

n = 100
ngroups = 6
global_intercept = 1
global_slope = 1

individual_intercepts = randn(ngroups)
individual_slopes = randn(ngroups)

function random_effect(id, intercept_factor, slope_factor)
    intercept = global_intercept + intercept_factor * individual_intercepts[id]
    slope = global_slope + slope_factor * individual_slopes[id]
    return (intercept, slope)
end

intercept_factor = 0.9
slope_factor = 0.9
df = DataFrame(x = rand(n), id = rand(1:ngroups, n))
transform!(df, :id => ByRow(id -> random_effect(id, intercept_factor, slope_factor)) => [:intercept, :slope])
transform!(df, [:x, :intercept, :slope] => ByRow((x, intercept, slope) -> intercept + slope*x + randn()/10) => :y)

m1 = lm(@formula(y ~ 1 + x), df)
ndf1 = DataFrame(x = 0:1, y = zeros(2))
ndf1.y .= predict(m1, ndf1)

fig = Figure()
ax1 = Axis(fig[1,1], title = string("P = ", round(ftest(m1.model).pval, digits = 2)))
scatter!(ax1, df.x, df.y)
lines!(ndf1.x, ndf1.y)

m2 = fit(MixedModel, @formula(y ~ 1 + x + (1|id)), df)
ndf2 = flatten(combine(groupby(df, :id), :x => extrema => :x), :x)
ndf2.y .= 0.0
ndf2.y .= predict(m2, ndf2)
ndf2pop = DataFrame(x = 0:1, y = zeros(2), id = fill(ngroups + 1, 2))
ndf2pop.y .= predict(m2, ndf2pop, new_re_levels=:population)

ax2 = Axis(fig[1,2], title = string("P = ", round(m2.pvalues[2], digits = 2)))
scatter!(ax2, df.x, df.y, color = df.id)
for g in groupby(ndf2, :id)
    lines!(g.x, g.y, colorrange = (1, ngroups), color = g.id)
end
lines!(ndf2pop.x, ndf2pop.y, colorrange = (1, ngroups), color = :black)


m3 = fit(MixedModel, @formula(y ~ 1 + x + (1 + x|id)), df)
ndf3 = flatten(combine(groupby(df, :id), :x => extrema => :x), :x)
ndf3.y .= 0.0
ndf3.y .= predict(m3, ndf3)
ndf3pop = DataFrame(x = 0:1, y = zeros(2), id = fill(ngroups + 1, 2))
ndf3pop.y .= predict(m3, ndf3pop, new_re_levels=:population)

ax3 = Axis(fig[1,3], title = string("P = ", round(m3.pvalues[2], digits = 2)))
scatter!(ax3, df.x, df.y, colorrange = (1, ngroups), color = df.id)
for g in groupby(ndf3, :id)
    lines!(g.x, g.y, colorrange = (1, ngroups), color = g.id)
end
lines!(ndf3pop.x, ndf3pop.y, color = :black)

linkaxes!(ax1, ax2)
linkaxes!(ax2, ax3)

fig
