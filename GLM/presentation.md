---
marp: true
theme: gaia
_class: lead
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
math: mathjax
---

# **LM, GLM, & GLMM**

Understanding Generalized Linear Models

*Yakir Gagnon - Dacke retreat 2025*

<!--
Hi my name is Yakir, I work as a Research Software/hardware Engineer at Marie Dacke's lab. 
I believe that today everyone of us will end this session with a deeper, more useful, understanding of GLMs!  
-->

---
<!-- paginate: true -->

# What?

- Linear models → Generalized linear models → Generalized linear mixed model
- PLEASE **stop me** as soon as you feel lost

<!--
We'll go step by step, understanding each step is important for understanding the next step, please please please stop when you feel unsure or uncertain. 
-->

---

# An independent variable affects a dependent one

$$y = intercept + slope*x$$

![bg right h:100%](media/1.svg)

<!-- 
Independent: regressor, predictor, or explanatory variable.
Dependent: regressand, predicted, explained, or response variable.

So image a process that is literarily governed by this equation: you put 2 x-thingies in, you get 7 y-thingies out. Like a machine. 
-->

---

# Measuring this relationship

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

# Simulation


$$y = intercept + slope*x$$

![bg right h:100%](media/0.svg)

<!-- 
So, let's try to simulate a process and measurements. In this simulation we set the values of the parameters. We choose (as before):
intercept = 3
slope = 2
-->
---

# Simulation

```julia
function process(x)
    y = 3 + 2x
    return y
end





```

![bg right h:100%](media/0.svg)

<!-- 
OK, great. Here we have a function that given x, it returns "y"
-->

---

# Simulation

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
Now we add the noise from the measurement itself.
IMPORTANT!!! Take your time here

- x goes into process
- process returns "y" 
- y is lambda
- lambda goes into measure
- here we build a distribution with mean lambda (what is y)
- and some standard deviation, sigma
- we then sample from that distribution, we take one random number
- that's it, that's our measurement, the scatter points
- we can do that again and again, for different x values, for the same x values
- we will always get some spread that depends on two things: the mean, lambda, which in itself directly and wholly depends on x, and on some standard deviation
-->

---

# Simulation

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
In this simulation we arbitrarily set this standard deviation to 1  
-->

---

# Simulation

We created this data using two main functions:

1. `μ = 3 + 2x`
2. `rand(Normal(μ, 1))` 

![bg right h:100%](media/4.svg)

<!-- 

-->

---

# Fitting a LM

| Language |  Syntax                          |
| -------- |  --------------------------------------- |
| Julia    | `lm(@formula(measurement ~ x), data)`    |
| R        | `lm(measurement ~ x, data = data)`       |
| Python   | `LinearRegression().fit(x, measurement)` |
| Matlab   | `fitlm(x,measurement)`                   |

<!-- 
The syntax is both unimportant and similar
95% of the issues will not be with this one line of code
it will be with prepping the data
loading it
preprocessing it
interpreting it correctly
understanding the results 
plotting and reporting
-->

---

# Fitting a LM


| coefficients | fitted | original |
|--- |--- | --- |
| intercept | 3.16 | 3 |
| slope | 1.94 | 2 |


![bg right h:100%](media/5.svg)

<!-- 

-->

---

# Fitting a LM

With the residuals

![bg right h:100%](media/6.svg)

<!-- 

-->

---

# Fitting a LM

Just the residuals

![bg right h:100%](media/7.svg)

<!-- 

-->

---

# Fitting a LM

A histogram of the residuals

![bg right h:100%](media/8.svg)

<!-- 

-->

---

# Fitting a LM

* What is the standard deviation of this probability distribution?
* It's 1!

![bg right h:100%](media/9.svg)

<!-- 

-->

---

# GLM

- The residuals of the response variable don't have to be linearly distributed 
- Easy to interpret
- Able to deal with categorical predictors
- Deals fine with unbalanced datasets

---

# ʻohana

| Family | Support | Uses |
| --- | --- | --- |
| Normal | (-∞, +∞) | Linear response data |
| Gamma | (0, +∞) | continuous, non-negative and positive-skewed data |
| Poisson | integers | counts in fixed amount of time/space |
| Bernoulli | true/false | outcome of a yes-no result |
| Binomial | integers | counts of a yes-no result |

<!-- 
ʻohana means family (from the lilo and stitch movie)
-->

---

# Simulating a non-normal process

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

-->

---

# Simulating a non-normal process

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

-->

---

# Simulating a non-normal process

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
normalize_to_01: return ranges between zero and one
-->
---

# Simulating a non-normal process

```julia
function process(x)
    y = -6 + 2*x
    return normalize_to_01(y)
end





```

![bg right h:100%](media/10.svg)

<!-- 
normalize_to_01: return ranges between zero and one
-->

---

# Simulating a non-normal process

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
normalize_to_01: return ranges between zero and one
-->

---

# Fitting a GLM

| Language |  Syntax                          |
| -------- |  --------------------------------------- |
| Julia    | `glm(@formula(measurement ~ x), data, Binomial())`    |
| R        | `glm(measurement ~ x, data = data, family = binomial)`       |
| Python   | `smf.glm('measure ~ x', family=sm.families.Binomial(), data=data).fit()` |
| Matlab   | `glmfit(x,measurement,'binomial')`                   |
<!-- 
The syntax is both unimportant and similar
-->

---

# Fitting a GLM


| coefficients | fitted | original |
|--- |--- | --- |
| intercept | -4.7 | -6 |
| slope | 1.6 | 2 |


<!-- 

-->

---

# GLMM
## Advantages

- Factors out between-group variation
- So deals with repeated measures or longitudinal data

---

# GLMM

![bg right:70% w:100%](media/12.svg)

<!-- 

-->

---
# GLMM

![bg right:70% w:100%](media/13.svg)

<!-- 

-->

---
# GLMM

![bg right:70% w:100%](media/14.svg)

<!-- 

-->

---
# GLMM

![bg right:70% w:100%](media/15.svg)

<!-- 

-->

---
# GLMM

![bg right:70% w:100%](media/19.svg)

<!-- 

-->

---

# Demo time!