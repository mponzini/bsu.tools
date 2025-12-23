## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
# library(bsu.tools)

## ----setup2-------------------------------------------------------------------
knitr::opts_chunk$set(fig.width=12, fig.height=8,
                      echo=TRUE, warning=FALSE, message=FALSE)

# list default packages to load, add additional packages as necessary
pacman::p_load(dplyr, tidyr, ggplot2, kableExtra, knitr)

# update 'asis' chunk to allow inline code
knit_engines$set(asis = function(options) {
  if (options$echo && options$eval) knit_child(text = options$code)
})


internal <- TRUE

## ----source-analyses, include=internal----------------------------------------
# source any external analysis scripts

# if analysis is computationally intensive there are a few options.
#   1) run analysis and save all results to load here
#   2) run analysis here and set chunk option cache=TRUE. A cached chunk will
#      automatically load output and objects from a previous run.
#         see https://bookdown.org/yihui/rmarkdown-cookbook/cache.html for more 
#         information

# check distribution of measurements by group
ggplot(iris, aes(sample = Petal.Length)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = 'Petal Length') +
  facet_wrap(.~Species) +
  theme_bw()
                   
ggplot(iris, aes(sample = Petal.Width)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = 'Petal Width') +
  facet_wrap(.~Species) +
  theme_bw()

ggplot(iris, aes(sample = Sepal.Length)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = 'Sepal Length') +
  facet_wrap(.~Species) +
  theme_bw()
                   
ggplot(iris, aes(sample = Sepal.Width)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = 'Sepal Width') +
  facet_wrap(.~Species) +
  theme_bw()


## ----sysinfo, include=internal------------------------------------------------
# displays R version, platform, base packages, attached packages, and packages
# loaded via a namespace
sessionInfo()

## ----table-demo-kable, eval=TRUE----------------------------------------------
# demo table by piping data into kable()
iris %>%
  group_by(Species) %>%
  summarize(Sepal_Length = paste0(round(mean(Sepal.Length), 2), " \u00B1 ", 
                                  round(sd(Sepal.Length), 2)),
            Sepal_Width = paste0(round(mean(Sepal.Width), 2), " \u00B1 ", 
                                 round(sd(Sepal.Width), 2)),
            Petal_Length = paste0(round(mean(Petal.Length), 2), " \u00B1 ", 
                                  round(sd(Petal.Length), 2)),
            Petal_Width = paste0(round(mean(Petal.Width), 2), " \u00B1 ", 
                                  round(sd(Petal.Width), 2))) %>%
  kable(caption = "Summary of Sepal and Petal Lengths and Widths by Species",
        col.names = c("Species", "Sepal Length", "Sepal Width", "Petal Length", "Petal Width")) %>%
  kable_styling()

## ----table-demo-arsenal, eval=TRUE, results='asis'----------------------------
summary(arsenal::tableby(Species ~ Sepal.Length + Sepal.Width + Petal.Length +
                           Petal.Width, data = iris, 
                         numeric.stats = c('meansd', 'Nmiss')), 
        pfootnote = TRUE, title = 'Results by Species')

## ----figure-demo, fig.cap="\\label{fig:figs}Demo Figure Caption", eval=TRUE----
iris %>%
  pivot_longer(cols = c(Sepal.Length, Sepal.Width, Petal.Length, 
                        Petal.Width),
               values_to = "Measurements", names_to = "Part") %>%
  ggplot(aes(x = Part, y = Measurements, color = Species)) +
  geom_boxplot() + 
  labs(y = "Length or Width (cm)", x = "Plant Part") +
  theme_bw()

