## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, include=FALSE-----------------------------------------------------
library(kableExtra)
library(dplyr)
library(arsenal)
library(sjPlot)
library(ggplot2)

## ----kableextra-table---------------------------------------------------------
iris %>%
  group_by(Species) %>%
  summarise("Mean (SD)" = paste0(round(mean(Sepal.Length), 3), " (", 
                                 round(sd(Sepal.Length), 3), ")"),
            "Range" = paste0(round(min(Sepal.Length), 3), " - ", 
                             round(max(Sepal.Length), 3))) %>%
  t() %>%
  kable(caption = "Summary of sepal length by species.") %>%
  kable_styling()

## ----arsenal-table, results='asis'--------------------------------------------
summary(arsenal::tableby(Species ~ Sepal.Length, data = iris),
        title = "Summary of sepal lengths by species.")

## ----results='asis'-----------------------------------------------------------
summary(arsenal::tableby(Species ~ Sepal.Length, data = iris),
        title = "(\\#tab:tableby-table) Summary of sepal lengths by species.")

## -----------------------------------------------------------------------------
sjPlot::tab_model(lm(Sepal.Length ~ Species, data = iris),
                  title = "(\\#tab:sjplot-table) Results of linear regression model.")

## ----example-fig, fig.cap="Boxplot of sepal length by species."---------------
ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot() +
  theme_bw()

## ----fig.cap="(\\#fig:example-fig2) Boxplot of sepal length by species."------
ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot() +
  theme_bw()

