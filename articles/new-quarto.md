# How to create a qmd from gists

``` r
library(bsu.tools)
```

Borrowing from the `rUM` package, the
[`new_quarto()`](https://mponzini.github.io/bsu.tools/reference/new_quarto.md)
function enables you to create a new Quarto qmd file utilizing one of
our built in templates.

The function has three arguments:  
- filename: the name of your new file. If you forget the `.qmd` ending
the function will automatically add it for you.  
- path: where should the file be created. Uses
[`here::here()`](https://here.r-lib.org/reference/here.html) by
default.  
- gist: the template you want to use (see below).

As of 2025-12-24 there are currently 3 qmd gists available:  
- “no_logo_quarto”,  
- “ctsc_quarto”,  
- and “hac_quarto”.

Simply call
`new_quarto(filename = "your-new-qmd", gist = "<one-of-the-three>")` in
the console to create and open your new qmd file from the template.
