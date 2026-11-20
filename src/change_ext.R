# Functions from https://github.com/robitalec/targets-parameterized-bookdown

# Change extension from md to Rmd
#  since (at the moment) bookdown ignores md files unless explicitly stated in
#  rmd_files
#  https://github.com/rstudio/bookdown/issues/956
change_ext <- function(file, inext, outext) {
  newfile <- gsub(inext, outext, file)
  file.rename(file, newfile)

  # Strip local absolute repo root (raw and URL-encoded) from knitted asset paths
  lines <- readLines(newfile, warn = FALSE)
  repo_root <- paste0(normalizePath(getwd(), winslash = "/"), "/")
  repo_root_enc <- utils::URLencode(repo_root, reserved = FALSE)
  lines <- gsub(repo_root_enc, "", lines, fixed = TRUE)
  lines <- gsub(repo_root, "", lines, fixed = TRUE)
  writeLines(lines, newfile)

  newfile
}


# Bookdown render, but with explicitly defined dependencies
render_with_deps <- function(index, deps) {
  out <- render_book(
    index,
    # This is how you introduce code folding in gitbook
    output_format = gitbook(code_folding = "hide", self_contained = TRUE)
  )

  # Sync static parameter figures and knitted chapter figure folders into docs/
  param_dirs <- list.dirs("in", full.names = FALSE, recursive = FALSE)
  for (param_dir in param_dirs) {
    pngs <- list.files(file.path("in", param_dir), pattern = "\\.png$", full.names = TRUE)
    if (length(pngs) > 0) {
      dest_dir <- file.path("docs", "in", param_dir)
      dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
      file.copy(pngs, dest_dir, overwrite = TRUE)
    }
  }

  chapter_fig_dirs <- list.files("chapters", pattern = "_files$", full.names = TRUE)
  if (length(chapter_fig_dirs) > 0) {
    dest_chapters <- file.path("docs", "chapters")
    dir.create(dest_chapters, recursive = TRUE, showWarnings = FALSE)
    file.copy(chapter_fig_dirs, dest_chapters, recursive = TRUE, overwrite = TRUE)
  }

  out
}