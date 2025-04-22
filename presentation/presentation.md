---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
---

# **GLMs**

Understanding Generalized Linear Models

*Yakir Gagnon - Dacke retreat 2025*

<!--
Hi my name is Yakir, I work as a Research Software/hardware Engineer at Marie Dacke's lab. 
I believe that today everyone of us will end this session with a deeper, more useful, understanding of GLMs!  
-->

---

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
    3 + 2x
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
    3 + 2x
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
    3 + 2x
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

What is the standard deviation of this probability distribution?

![bg right h:100%](media/9.svg)

<!-- 

-->

---

# Simulating a non-normal process

```julia
function process(x)
    intercept + slope*x
end

function measure(μ)
    d = Normal(μ, σ)
    rand(d)
end
```

<!-- 

-->

---

# Simulating a non-normal process

```julia
function process(x)
    intercept + slope*x
end

function measure(p)
    d = Bernoulli(p)
    rand(d)
end
```

<!-- 

-->

---

# Simulating a non-normal process

```julia
function process(x)
    μ = intercept + slope*x
    normalize_to_01(μ)
end

function measure(p)
    d = Bernoulli(p)
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
    μ = 3 + 2*x
    normalize_to_01(μ)
end

function measure(p)
    d = Bernoulli(p)
    rand(d)
end
```

![bg right h:100%](media/10.svg)

<!-- 
normalize_to_01: return ranges between zero and one
-->