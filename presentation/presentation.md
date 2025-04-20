---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
---

# **GLMs**

*Understanding Generalized linear models*

<!--
Hi my name is Yakir, I work as a Research Software Engineer at Marie Dacke's lab, but I also work on hardware. Today I'll present an auto tracker I made for the Dacke Lab.  
-->

---

# What?

- Linear models → Generalized linear models → Generalized linear mixed model
- PLEASE stop me as soon as you feel lost

---

# An independent variable affects a dependent one

$$y = intercept + slope*x$$

![bg right h:100%](media/linear.svg)

<!-- 
Independent: regressor, predictor, or explanatory variable.
Dependent: regressand, predicted, explained, or response variable.
-->

---

# Measuring this relationship

- 30 measurements
- all at $x = 2$
- There is some variation from 3 + 2*2 (i.e. seven)

![bg right h:100%](media/linear+noise.svg)


---

# Measuring is never exact

- 1000 measurements of duck eggs
- mean of 7


![bg right h:100%](media/measurement.svg)

<!-- 
- Normal distribution
- standard deviation of 1/2 
- we fuck up the measurement (read, report, write the wrong numbers)
- the device we use to measure with has some intrinsic error
- we think we are measuring things for a predictor value of (say) 2, but in actuality we're measuring it for a different value 
- the process is not governed by just one linear process the depends only on one predictor
-->

---

# Simulation

```julia
model(x) = intercept + slope*x

function measure(μ)
    d = Normal(μ, σ)
    rand(d)
end
```

![bg right h:100%](media/model+measurement.svg)

<!-- 
intercept = 3
slope = 2
σ = 2
-->

---

# Simulation

```julia
model(x) = 3 + 2*x

function measure(μ)
    d = Normal(μ, 2)
    rand(d)
end
```

![bg right h:100%](media/model+measurement.svg)

<!-- 
intercept = 3
slope = 2
σ = 2
-->


--- 

![bg right h:100%](media/measurements.svg)