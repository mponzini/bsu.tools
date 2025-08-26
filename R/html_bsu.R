#' @export

html_bsu <- function(...) {
  css_path <- system.file(
    "styling/template_css.css",
    package = "bsu.tools"
  )

  bookdown::html_document2(
    css = css_path,
    number_sections = TRUE,
    toc = TRUE,
    toc_float = TRUE,
    toc_depth = 3
  )
}
