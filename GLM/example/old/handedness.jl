using MixedModels, Distributions, DataFrames, GLM

nindividuals = 10
n = 10
df = DataFrame(id = 1:nindividuals)
df.p = rand(nindividuals)
# df.p .= 0.5
transform!(df, :p => ByRow(p -> rand(Bernoulli(p), n)) => :success)
df = flatten(df, :success)
df2 = combine(groupby(df, :id), :success => count => :n, nrow)
transform!(df2, [:nrow, :n] => ByRow(\) => :p)

m = fit(MixedModel, @formula(success ~ 1 + (1 | id)), df, Binomial())

m = glm(@formula(p ~ 1), df2, Binomial(), wts = df2.nrow)


n = 6
m = glm(@formula(p ~ 1), DataFrame(p = rand(n)), Binomial(), wts = fill(2, n))

using HypothesisTests

nindividuals = 10
n = 10
df = DataFrame(id = 1:nindividuals)
# df.p = rand(nindividuals)
df.p .= 0.5
transform!(df, :p => ByRow(p -> rand(Bernoulli(p), n)) => :success)
df = flatten(df, :success)
df2 = combine(groupby(df, :id), :success => count => :n, nrow)
transform!(df2, [:nrow, :n] => ByRow((nrow, n) -> n < nrow/2 ? nrow - n : n) => :n)
transform!(df2, [:n, :nrow] => ByRow((n, nrow) -> confint(BinomialTest(n, nrow), tail = :both)) => :p)

# transform!(df2, [:nrow, :n] => ByRow(\) => :p)

using GLMakie
nindividuals = 10
n = 10
df = DataFrame(id = 1:nindividuals)
# df.p = rand(nindividuals)
df.p .= 0.5
transform!(df, :p => ByRow(p -> rand(Bernoulli(p), n)) => :success)

barplot(df




newdf = DataFrame(success = zeros(1), id = 99)
μ = predict(m, newdf, new_re_levels=:population)

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


