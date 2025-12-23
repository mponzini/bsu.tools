# Tables-Figures-vignette

## Tables

There are three packages I recommend for generating tables:
`kableExtra`, `arsenal`, and `sjPlot`.

- `kable` from the `kableExtra` package for printing tables from data
  frames.
- `tableby` from the `arsenal` package for creating summary tables.
- `tab_model` from the `sjPlot` package for creating HTML tables with
  model results.

We are currently aware of two packages that should be avoided for table
generation when using the template: `table1` and `DT`. The tables that
result from these packages do not work with the auto-numbering and
cross-referencing functionality of
[bookdown](https://bookdown.org/yihui/rmarkdown-cookbook/cross-ref.html).

### kableExtra

Use `kable(data.frame)` or pipe a data frame into `kable` to create a
table using `kableExtra`. To cross-reference a `kableExrta` table,
reference the chunk name (`\@ref(tab:chunk-name)`). An example is shown
in Table @ref(tab:kableextra-table). For more information on using and
modifying tables with kableExtra see their
[vignette](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html).

``` r
iris |>
  group_by(Species) |>
  summarise("Mean (SD)" = paste0(round(mean(Sepal.Length), 3), " (", 
                                 round(sd(Sepal.Length), 3), ")"),
            "Range" = paste0(round(min(Sepal.Length), 3), " - ", 
                             round(max(Sepal.Length), 3))) |>
  t() |>
  kable(caption = "Summary of sepal length by species.") |>
  kable_styling()
```

|           |               |               |               |
|:----------|:--------------|:--------------|:--------------|
| Species   | setosa        | versicolor    | virginica     |
| Mean (SD) | 5.006 (0.352) | 5.936 (0.516) | 6.588 (0.636) |
| Range     | 4.3 - 5.8     | 4.9 - 7       | 4.9 - 7.9     |

Summary of sepal length by species.

### arsenal

Create a summary table using
[`arsenal::tableby`](https://mayoverse.github.io/arsenal/reference/tableby.html).
Make sure to set the chunk option `results='asis'` for the results to
look nice within the report. To cross-reference a `tableby` object,
reference the chunk name (`\@ref(tab:chunk-name)`). An example is show
in Table @ref(tab:arsenal-table). For more information on using
`tableby` see their
[vignette](https://cran.r-project.org/web/packages/arsenal/vignettes/tableby.html).

``` r
summary(arsenal::tableby(Species ~ Sepal.Length, data = iris),
        title = "Summary of sepal lengths by species.")
```

|                  | setosa (N=50) | versicolor (N=50) | virginica (N=50) | Total (N=150) |  p value |
|:-----------------|:-------------:|:-----------------:|:----------------:|:-------------:|---------:|
| **Sepal.Length** |               |                   |                  |               | \< 0.001 |
|    Mean (SD)     | 5.006 (0.352) |   5.936 (0.516)   |  6.588 (0.636)   | 5.843 (0.828) |          |
|    Range         | 4.300 - 5.800 |   4.900 - 7.000   |  4.900 - 7.900   | 4.300 - 7.900 |          |

Summary of sepal lengths by species.

The `tableby` vignette says to add `(\\#tab:table-label)` at the
beginning of the title in order to reference with `bookdown` but I’ve
found this causes the table to be numbered twice, as seen in table
@ref(tab:tableby-table).

``` r
summary(arsenal::tableby(Species ~ Sepal.Length, data = iris),
        title = "(\\#tab:tableby-table) Summary of sepal lengths by species.")
```

|                  | setosa (N=50) | versicolor (N=50) | virginica (N=50) | Total (N=150) |  p value |
|:-----------------|:-------------:|:-----------------:|:----------------:|:-------------:|---------:|
| **Sepal.Length** |               |                   |                  |               | \< 0.001 |
|    Mean (SD)     | 5.006 (0.352) |   5.936 (0.516)   |  6.588 (0.636)   | 5.843 (0.828) |          |
|    Range         | 4.300 - 5.800 |   4.900 - 7.000   |  4.900 - 7.900   | 4.300 - 7.900 |          |

(#tab:tableby-table) Summary of sepal lengths by species.

### sjPlot

The `tab_model` function from the `sjPlot` package will create an HTML
summary table of a model object. To cross-reference a `tab_model` table,
add `(\\#tab:table-label)` at the beginning of the title. An example is
shown in Table @ref(tab:sjplot-table). For more information on using
`tab_model` see their
[vignette](https://strengejacke.github.io/sjPlot/articles/tab_model_estimates.html).

``` r
sjPlot::tab_model(lm(Sepal.Length ~ Species, data = iris),
                  title = "(\\#tab:sjplot-table) Results of linear regression model.")
```

|                        | Sepal.Length  |             |             |
|:----------------------:|:-------------:|:-----------:|:-----------:|
|       Predictors       |   Estimates   |     CI      |      p      |
|      (Intercept)       |     5.01      | 4.86 – 5.15 | **\<0.001** |
| Species \[versicolor\] |     0.93      | 0.73 – 1.13 | **\<0.001** |
| Species \[virginica\]  |     1.58      | 1.38 – 1.79 | **\<0.001** |
|      Observations      |      150      |             |             |
|    R² / R² adjusted    | 0.619 / 0.614 |             |             |

(#tab:sjplot-table) Results of linear regression model.

## Figures

As of this writing I am not aware of any figure packages that should be
avoided. Each figure should be in its own chunk with a figure caption
when being printed. As with the `kableExtra` and `tableby` tables,
reference the figures using the chunk name (`\@ref(fig:chunk-name)`).
Figure @ref(fig:example-fig) is an example.

``` r
ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot() +
  theme_bw()
```

![Boxplot of sepal length by
species.](Tables-Figures-vignette_files/figure-html/example-fig-1.png)

Boxplot of sepal length by species.

As with the `tableby` table, including `(\\#fig:fig-label)` at the
beginning of the figure caption will result in double numbering, as
shown in Figure @ref(fig:example-fig2).

``` r
ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot() +
  theme_bw()
```

![(\\fig:example-fig2) Boxplot of sepal length by
species.](Tables-Figures-vignette_files/figure-html/unnamed-chunk-4-1.png)

(#fig:example-fig2) Boxplot of sepal length by species.
