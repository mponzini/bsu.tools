# Create a new Quarto Document from Template

Create a new Quarto Document from Template

## Usage

``` r
new_quarto(filename = NULL, path = here::here(), gist = "no_logo_quarto")
```

## Arguments

- filename:

  Character string. The name of the file without the '.qmd' extension.
  Only letters, numbers, hyphens, and underscores are allowed.

- path:

  Character string. Directory where the file will be created. Defaults
  to the current project's base directory.

- gist:

  Character string. Qmd template file to create/open.

## Value

Opens file after creating the Quarto document.
