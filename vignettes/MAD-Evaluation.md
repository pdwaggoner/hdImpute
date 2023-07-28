---
title: "MAD Evaluation"
date: "`r format(Sys.time(), '%B %d, %Y')`"
---

## Introductory Remarks 

A central question in any imputation effort is whether the imputed values you came up with are any good or not. 

Though several metrics for evaluating imputations exist, a common one is mean absolute differences (MAD scores) between original and imputed values. This gives a very practical look at how close or far off the imputations were from the original data. 

MAD scores are computed at the variable level through the calculation of mean absolute differences between the original distribution of cases and the imputed version of those same cases. Practically, MAD shows aggregate error when imputing over individual variables. Lower percentages mean less error/differences compared to higher percentages, which mean greater overall error/differences across all variables between original and imputed data sets.

For example, suppose you had a nominal variable with three potential values A, B, and C. The distribution of the variable across each category was A = 40%, B = 30%, and C = 30% when considering only complete cases. Then, after imputing this variable, you observed the distribution A = 43%, B = 28%, and C = 29%. We would calculate the mean absolute difference as $(|40-43| + |30-28| + |30-29|) / 3 = 2$, or 2% average difference between the original and imputed versions of the same variable. The logic is easily scaled up to accommodate high dimensional data spaces, with identical interpretation making it a very intuitive and helpful evaluative metric for imputations tasks. *Note*: the bigger the data space, the slower the computation. 

Let's see this in action in the following section via the `mad()` function from the latest release of `hdImpute`. 

## Computing MAD Scores

First, load the library along with the `tidyverse` library for some additional helpers in setting up the sample data space. 

```{r setup, warning = FALSE, message = FALSE}
library(hdImpute)
library(tidyverse)
```

Next, set up the data and introduce missingness completely at random (MCAR) via the `prodNA()` function from the `missForest` package. Take a look at the synthetic data with missingness introduced.

```{r data}
d <- data.frame(X1 = c(1:6), 
                X2 = c(rep("A", 3), 
                       rep("B", 3)), 
                X3 = c(3:8),
                X4 = c(5:10),
                X5 = c(rep("A", 3), 
                       rep("B", 3)), 
                X6 = c(6,3,9,4,4,6))

set.seed(1234)

data <- missForest::prodNA(d, noNA = 0.30) %>% 
  as_tibble()

data
```

*Note*: This is a tiny sample set, but hopefully the usage is clear enough. 

First, impute this simple data set via `hdImpute()`:

```{r imp1}
imputed = hdImpute(data = data, batch = 2)
```

Now, we have an imputed versions of the original data space with no more missingness. 

```{r imp2}
imputed
```

But how good is this at capturing the original distribution of the data (pre-imputation)? Let's find out by computing MAD scores for each variable via `mad()`

```{r mad}
mad(original = data,
    imputed = imputed,
    round = 1)
```

We can see we did best on `X3` and `X4` with scores at 5.3% mean difference for each, and worst on `X1` with a score of 16.7% mean difference. Importantly, precisely what defines "best" or "worst" MAD is entirely project-dependent. Users should interpret results with care.

By default, the function returns a tibble. This can easily be stored in an object for later use:

```{r mad2}
mad_scores <- mad(original = data,
    imputed = imputed,
    round = 1)
```

Now, with our `mad_scores` as a tidy tibble, we can continuing working with it to, e.g., visualize the distribution of error across this full data space with only a few lines of code (*remember*: lower MAD is better, meaning fewer average differences in the distribution of imputations compared to the original data). 

First, a histogram:

```{r viz}
mad_scores %>%
  ggplot(aes(x = mad)) +
  geom_histogram(fill = "dark green") +
  labs(x = "MAD Scores (%)", y = "Count of Variables", title = "Distribution of MAD Scores") +
  theme_minimal() +
  theme(legend.position = "none")
```

Or a boxplot: 

```{r viz2}
mad_scores %>%
  ggplot(aes(x = mad)) +
  geom_boxplot(fill = "dodgerblue") +
  labs(x = "MAD Scores (%)", title = "Distribution of MAD Scores") +
  theme_minimal() +
  theme(legend.position = "none")
```

## Concluding Remarks 

This software is being actively developed, with many more features to come. Wide engagement with it and collaboration is welcomed! Here's a sampling of how to contribute:

  - Submit an [issue](https://github.com/pdwaggoner/hdImpute/issues) reporting a bug, requesting a feature enhancement, etc. 

  - Suggest changes directly via a [pull request](https://github.com/pdwaggoner/hdImpute/pulls)

  - [Reach out directly](https://pdwaggoner.github.io/) with ideas if you're uneasy with public interaction

Thanks for using the tool. I hope its useful.
