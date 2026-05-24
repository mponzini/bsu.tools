#' @title Create a new Project Closeout Document from Template
#' @param filename Character string. The name of the file without the '.qmd' extension.
#'   Only letters, numbers, hyphens, and underscores are allowed.
#' @param path Character string. Directory where the file will be created. Defaults to
#'   the current project's base directory.
#' @returns Opens file after creating the Quarto document.
#' @export
#'
new_project_closeout <- function(
    filename = NULL,
    path = here::here()
) {

  # Validate path
  if (is.null(path) || !dir.exists(path)) {
    stop("Invalid `path`. Please enter a valid project directory.")
  }

  # Validate filename: part 1
  if (is.null(filename)) stop('Invalid filename. Please input a value.')

  # Remove .qmd if accidentally typed
  filename <- stringr::str_replace_all(filename, '.qmd$', '')

  # Validate filename: part 2
  if (!is.character(filename)) stop('Invalid filename: must be character.')
  if (!grepl('^[a-zA-Z0-9_-]+$', filename)) {
    stop('Invalid filename. Use only letters, numbers, hyphens, and underscores.')
  }

  # Normalize the path for consistency
  path <- normalizePath(path, mustWork = TRUE)

  if (file.access(path, mode = 2) != 0) {
    stop(sprintf(
      'You do not have permission to write to the path location: %s\nTry `new_project_closeout(filename = "", path = "")`',
      path
    ))
  }

  # Set up full file path
  the_quarto_file <- file.path(path, paste0(filename, '.qmd'))

  # Check for existing Quarto doc
  if (file.exists(the_quarto_file)) {
    stop(sprintf("%s.qmd already exists in the specified path.", filename))
  }

  # Write the Quarto file based on template
  gist <- "gists/project_closeout.qmd"
  template_path <- system.file(gist, package = 'bsu.tools')

  if (template_path == "") {
    stop("Could not find project closeout template in package installation")
  }

  file.copy(from = template_path, to = the_quarto_file, overwrite = FALSE)

  # Open the new template upon successful copy
  if (file.exists(the_quarto_file)) {
    usethis::edit_file(the_quarto_file)
  } else {
    stop("The file does not exist.")
  }

  invisible(NULL)
}
