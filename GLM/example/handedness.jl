using MixedModels, Distributions, DataFrames

nindividuals = 10
n = 10
p = 0.1
df = DataFrame(id = 1:nindividuals)
df.y .= Ref(Bool[])
for row in eachrow(df)
    p0 = rand(Bool) ? p : 1 - p
    row.y = rand(Bernoulli(p0), n)
end
df = flatten(df, :y)

transform!(groupby(df, :id), :y => (y -> count(y) > length(y)/2 ? .!y : y) => :y)


m = fit(MixedModel, @formula(y ~ 1 + (1 | id)), df, Binomial())
ndf = DataFrame(id = nindividuals + 1, y = false)
predict(m, ndf, new_re_levels = :population)


