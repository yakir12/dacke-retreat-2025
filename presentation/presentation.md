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
function model(x)
    3 + 2x
end





```

![bg right h:100%](media/0.svg)

<!-- 
OK, great. Here we have a function that given x, it returns y
-->

---

# Simulation

```julia
function model(x)
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
IMPORTANT!!!!

-->

---

# Simulation

```julia
function model(x)
    3 + 2x
end

function measure(μ)
    d = Normal(μ, 1)
    rand(d)
end
```

![bg right h:100%](media/3.svg)

<!-- 
intercept = 3
slope = 2
σ = 2
-->

---

# Simulation

```julia
function model(x)
    3 + 2x
end

function measure(μ)
    d = Normal(μ, 1)
    rand(d)
end
```

![bg right h:100%](media/4.svg)

<!-- 
intercept = 3
slope = 2
σ = 2
-->

---