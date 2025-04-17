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
-->

---

# Lets simulate some measurements

```julia
intercept = 3
slope = 2
σ = 2

function measure(x)
    μ = intercept + slope*x
    dist = Normal(μ, σ)
    rand(dist)
end

```