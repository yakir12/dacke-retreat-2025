---
marp: true
theme: gaia
_class: lead
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
math: mathjax
---

$$\begin{aligned} & LM\\
G & LM\\
G& LMM \end{aligned}$$


*Yakir Gagnon - Dacke retreat 2025*

<!--
Hi my name is Yakir, I work as a Research Software/hardware Engineer at Marie Dacke's lab. 
Understanding Generalized Linear Models
I believe that today everyone of us will end this session with a deeper, more useful, understanding of GLMs!  
-->

---
<!-- paginate: true -->

# What?

1. Linear models
2. Generalized linear models
3. Generalized linear mixed model

PLEASE **stop me** as soon as you feel lost

<!--
We'll go step by step, understanding each step is important for understanding the next step, please please please stop when you feel unsure or uncertain. 
-->

---

# An independent variable affects a dependent one

$$y = intercept + slope*x$$

![bg right h:100%](media/1.svg)

<!-- footer: "G Linear M Models" -->

<!-- 
Independent: regressor, predictor, or explanatory variable.
Dependent: regressand, predicted, explained, or response variable.

So imagine a process that is literarily governed by this equation: you put 2 x-thingies in, you get 7 y-thingies out. Like a machine.
-->


---

# Measuring this process

- 30 measurements
- all at $x = 2$
- There is some variation from $3 + 2*2$ (i.e. 7)

![bg right h:100%](media/2.svg)


<!-- 
- we fuck up the measurement (read, report, write the wrong numbers)
- the device we use to measure with has some intrinsic error
- we think we are measuring things for a predictor value of (say) 2, but in actuality we're measuring it for a different value (2.1, 1.8, etc)
- the process is not governed by just one linear process that depends only on one predictor, the story might be more complicated than that...
-->

---

# Simulating


$$y = intercept + slope*x$$

![bg right h:100%](media/0.svg)


<!-- 
To best understand Linear models, we'll simulate some data. This will allow you to understand how we fit linear models to this kind of data.
So, let's try to simulate a process and our measurements of it. In this simulation we set the values of the parameters to some arbitrary values. We choose (as before):
intercept = 3
slope = 2
-->
---

# Simulating

```julia
function process(x)
    y = 3 + 2x
    return y
end

```

![bg right h:100%](media/0.svg)


<!-- 
OK, great. Here we have a function that given x, it returns "y"
That is all it does.
-->

---

# Simulating

```julia
function process(x)
    y = 3 + 2x
    return y
end

function measure(μ)
    d = Normal(μ, σ)
    rand(d)
end
```

![bg right h:100%](media/3.svg)


<!-- 
SLOW

Now we add the noise from the measurement itself.

- x goes into process
- process returns "y" (x goes in, y comes out)
- y is actually mu
- mu goes into measure
- here we build a distribution with mean mu (what is y)
- and some standard deviation, some variance, sigma
- we then sample from that distribution: we take one random number
- that's it, that's our measurement, the scatter points
- we can do that again and again, for different x values, for the same x values
- we will always get some spread that depends on two things: the mean, mu, which in itself directly and wholly depends on x, and on some standard deviation
-->

---

# Simulating

```julia
function process(x)
    y = 3 + 2x
    return y
end

function measure(μ)
    d = Normal(μ, 1)
    rand(d)
end
```

![bg right h:100%](media/3.svg)


<!-- 
In this simulation we arbitrarily set this standard deviation to 1.
So now there are no variables on the scree:
The intercept is 3
the slope is 2
the standard deviation is 1
-->

---

# Simulating

We created this data using two main functions:

1. `μ = 3 + 2x`
2. `rand(Normal(μ, 1))` 

![bg right h:100%](media/4.svg)


<!-- 
We created this data using two main functions, two main steps:
the process modeled by this simple linear equation with an intercept and slope
and a normal distribution whose mean depends on the process and whose standard deviation is 1.
-->

---

# Fitting

| Language |  Syntax                          |
| -------- |  --------------------------------------- |
| Julia    | `lm(@formula(measurement ~ x), data)`    |
| R        | `lm(measurement ~ x, data = data)`       |
| Python   | `LinearRegression().fit(x, measurement)` |
| Matlab   | `fitlm(x,measurement)`                   |


<!-- 
The syntax is both unimportant and similar
If we were to have a tutorial
95% of the issues will not be with this one line of code
it will be with:
installing R, installing R-studio, prepping the data, interpreting it correctly. loading it, preprocessing it, installing all the packages, running that one line, understanding the results, plotting the results, exporting them.
I suggest you follow any of them hundreds of tutorials online, try things out, and call me for help on individual and specific issues you might have.
-->

---

# Fitting

| coefficients | fitted | original |
|--- |--- | --- |
| intercept | 3.16 | 3 |
| slope | 1.94 | 2 |


![bg right h:100%](media/5.svg)


<!-- 
So this is the fit for this specific data. You can see that the coefficients, the intercept and slope, we got are close to the ones we used to simulate the data with.
-->

---

# Fitting

With the residuals

![bg right h:100%](media/6.svg)


<!-- 

QUICK
Note the residuals, the distances from the measurements to the process, from the points to the line.

-->

---

# Fitting

Just the residuals

![bg right h:100%](media/7.svg)


<!-- 
QUICK

Here are their values...

-->

---

# Fitting

A histogram of the residuals

![bg right h:100%](media/8.svg)


<!-- 
QUICK
-->

---

# Fitting

* What is the standard deviation of this probability distribution?
* It's 1!

![bg right h:100%](media/9.svg)


<!-- 
In a Linear Model the distribution of the residuals, not the data it self, must be normal!
-->

---

# Multiple regression

There can be more than just one regressor


---

# GLM

- The residuals of the response variable don't have to be linearly distributed 
- Easy to interpret
- Able to deal with categorical predictors
- Deals fine with unbalanced datasets

<!-- footer: "Generalized L M M" -->

<!-- 
Generalized Linear Models
-->

---

#  ![h:100](https://upload.wikimedia.org/wikipedia/en/d/d2/Stitch_%28Lilo_%26_Stitch%29.svg) ʻohana
| Family | Support | Uses |
| --- | --- | --- |
| Normal | (-∞, +∞) | Linear response |
| Gamma | (0, +∞) | continuous, non-negative & positive-skewed |
| Poisson | integers | counts in fixed amount of time/space |
| Bernoulli | true/false | outcome of a yes-no result |
| Binomial | integers | counts of a yes-no result |


<!-- 
ʻohana means family (from the lilo and stitch movie)
Less "how is you data distributed" and more "what is your data"
-->

---

# Simulating

```julia
function process(x)
    y = intercept + slope*x
    return y # here, y is the mean of the normal distribution
end

function measure(μ)
    d = Normal(μ, σ) # μ can be between -∞ and ∞
    rand(d)
end
```


<!-- 

SLOW

Again, we will understand how to use GLMs by simulating data.
Here we have the same stuff we used to simulate the data for the Linear Model.
I'll just remind you how x goes in, y comes out, y is meant to be the mean for the normal distribution we use to produce samples at x. The normal distribution has mu as y, that's its mean. And a standard deviation (ours was 1, remember?). What process spits out can be any number, any goddamn number between negative infinity and positive infinity. That's totally fine for a Normal distribution.

-->

---

# Simulating

```julia
function process(x)
    y = intercept + slope*x
    return y
end

function measure(p)
    d = Bernoulli(p) # here, p must be between 0 and 1!!!
    rand(d)
end
```


<!--

But this is Generalized LM, not just LM, so we can and will PLUGIN a distribution other than normal. Here I used the bernoulli distribution. It takes "p". "p" is a probability of getting true or false (yes or no, up or down, clockwise, or counterclockwise, etc). So great, here measure accepts a p, p dictates the rate of getting success (yes, true, up, etc) from this d distribution, and we sample from it. But p must be between 0 and 1, it's a probability, and if we, as before, plug in y we might (and will) get p values that are lower than 0 and higher than 1. so...

-->

---

# Simulating

```julia
function process(x)
    y = intercept + slope*x
    return normalize_to_01(y) # so we must normalize y
end

function measure(p)
    d = Bernoulli(p) # here, p must be between 0 and 1!!!
    rand(d)
end
```


<!-- 
we normalize y to be between 0 and 1. This is the link function. This is all it does.
normalize_to_01: return ranges between zero and one

I wrote normalize_to_01, but common link functions are: logit, log, negative inverse, and... identity (the normal case in LM)
-->
---

# Simulating

```julia
function process(x)
    y = -6 + 2*x
    return normalize_to_01(y)
end


```

![bg right h:100%](media/10.svg)


<!-- 
here's what it looks like! 
it takes out process and normalizes it to be between 0 and 1.
-->

---

# Simulating

```julia
function process(x)
    y = -6 + 2*x
    return normalize_to_01(y)
end

function measure(p)
    d = Bernoulli(p)
    rand(d)
end
```

![bg right h:100%](media/11.svg)


<!-- 
and now we can sample from that bernoulli distribution. Each vertical line represents a measure, and you can tell that as X increases so does the probability of getting true.
-->

---

# Fitting

| Language |  Syntax                          |
| -------- |  --------------------------------------- |
| Julia    | `glm(@formula(measurement ~ x), data, Binomial())`    |
| R        | `glm(measurement ~ x, data = data, family = binomial)`       |
| Python   | `smf.glm('measure ~ x', family=sm.families.Binomial(), data=data).fit()` |
| Matlab   | `glmfit(x,measurement,'binomial')`                   |


<!-- 
The syntax is both unimportant and similar. This is exactly the same thing here as before.
-->

---

# Fitting


| coefficients | fitted | original |
|--- |--- | --- |
| intercept | -4.7 | -6 |
| slope | 1.6 | 2 |


<!-- 

and done, we get coefficients that are similar to the ones we used to create the data with.

-->

---

# GLMM

- Factors out between-group variation
- So deals with repeated measures or longitudinal data

<table>
  <col>
  <colgroup span="2"></colgroup>
  <tr>
    <td colspan="2" rowspan="2"></td>
    <th colspan="2" scope="colgroup">Reality</th>
  </tr>
  <tr>
    <th scope="col">True</th>
    <th scope="col">False</th>
  </tr>
  <tr>
  <th rowspan="2" scope="rowgroup">Test</th>
    <th scope="row">True</th>
    <td>Correct</td>
    <td>Type I error</td>
  </tr>
  <tr>
    <th scope="row">False</th>
    <td>Type II error</td>
    <td>Correct</td>
  </tr>
</table>

<!-- footer: "G L Mixed M" -->

<!-- 
For whatever reason you might have:
you sampled from the same individual, and these measures, you believe, will be correlated to each other so the test will result in what-really-is-false significance (type 1 error)
or each individual/ patch / tree/ grouping factor might have a very different intercept or slope such that it might obscure the phenomenon you are looking at (you get a type 2 error).
-->

---

# GLMM

![bg right:70% w:100%](media/12.svg)


<!-- 
QUICK
If I asked you to test what is the relationship between the predictor and the predicted variable, you'd say:
-->

---

# GLMM

![bg right:70% w:100%](media/13.svg)


<!-- 

Looks pretty significant to me. What if I added to this data the individual data points' groupings?
-->

---

# GLMM

![bg right:70% w:100%](media/14.svg)


<!-- 

Here you see (in the form of letters and colors) which group each measure comes from (this can be individual beetle, patch, tree, day, etc)
-->

---

# GLMM

![bg right:70% w:100%](media/15.svg)


<!-- 
Now you can tell that the relationship between the x and y is very different than what it looked like not knowing the groupings. 
indeed, the slope is almost the opposite of what you initially believed. But note how each group has a very different intercept. They all have very similar slopes, i.e. the slope is a global phenomenon that affects everyone equally, but they all have different y's at x = 0. A GLMM would allow for that and result in high significance and the correct slope.
-->

---

# GLMM

![bg right:70% w:100%](media/16.svg)


<!-- 
What about now? what do you think is going on here? Looks like:

-->

---

# GLMM

![bg right:70% w:100%](media/17.svg)


<!-- 
A clear regression with an intercept of about 2.

-->

---

# GLMM

![bg right:70% w:100%](media/18.svg)


<!-- 
again, if we add the groupings we see that none of the groups would really intercept with 2.
-->

---

# GLMM

![bg right:70% w:100%](media/19.svg)


<!-- 
Quick
Now you can tell that the relationship between the x and y is very different than what it looked like not knowing the groupings. 
-->

---

# GLMM

![bg right:70% w:100%](media/20.svg)


<!-- 

indeed, the intercept is almost the opposite of what you initially believed (-2 not, 2). But note how each group has a different slope this time. They all have very similar intercepts, i.e. the intercept is a global phenomenon, but they all have different slopes. A GLMM would allow for that and result in high significance and the correct intercept.
-->

---

# Demo time!


---


# The end

Thank you for listening

<!-- footer: "" -->
