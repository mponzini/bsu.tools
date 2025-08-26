#' @export

html_bsu <- function(...) {
  css_path <- system.file(
    "styling/template_css.css",
    package = "bsu.tools"
  )

  bookdown::html_document2(
    css = css_path,
    ...
  )
}
