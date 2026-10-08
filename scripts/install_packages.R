# Installs the R packages required by the project.
pkgs <- c("dplyr")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")
