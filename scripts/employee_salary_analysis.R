# =============================================================================
# Employee Salary Analysis in R
# Author : Shaima Nabeel Albokhari
# Usage  : Rscript scripts/employee_salary_analysis.R [path/to/employee_salary_data.csv]
#          (run from the project root; default path: data/employee_salary_data.csv)
# Output : figures -> outputs/figures/, summary tables -> outputs/tables/
# =============================================================================

suppressPackageStartupMessages(library(dplyr))

# ---- 1-2. Import the dataset & create a data frame --------------------------
args <- commandArgs(trailingOnly = TRUE)
file <- if (length(args) > 0) args[1] else file.path("data", "employee_salary_data.csv")
if (!file.exists(file)) {
  stop("Dataset not found: ", file, "\nSee data/README.md for the expected file.")
}
data <- read.csv(file)

fig_dir <- file.path("outputs", "figures")
tab_dir <- file.path("outputs", "tables")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

save_plot <- function(name, expr) {
  png(file.path(fig_dir, paste0(name, ".png")), width = 900, height = 600, res = 120)
  on.exit(dev.off())
  expr
}

# ---- 3. Explore the dataset --------------------------------------------------
cat("\n--- First rows ---\n");   print(head(data))
cat("\n--- Dimensions ---\n");   print(dim(data))
cat("\n--- Column names ---\n"); print(names(data))
cat("\n--- Structure ---\n");    str(data)

# ---- 4. Clean the dataset ----------------------------------------------------
# Missing values are only in Manager_ID (employees with no manager); they are
# kept because all salary values are complete and valid.
cat("\n--- Missing values per column ---\n"); print(colSums(is.na(data)))

data$HR_Salary      <- as.numeric(data$HR_Salary)
data$Payroll_Salary <- as.numeric(data$Payroll_Salary)

data <- unique(data)                                          # remove duplicates
data <- data[!is.na(data$HR_Salary) & data$HR_Salary > 0, ]   # keep valid salaries
cat("\nRows after cleaning:", nrow(data), "\n")

# ---- 5. Descriptive statistics (HR_Salary) ----------------------------------
salary_stats <- data.frame(
  Statistic = c("Mean", "Median", "Min", "Max", "SD", "Q1", "Q3"),
  Value = c(mean(data$HR_Salary), median(data$HR_Salary),
            min(data$HR_Salary),  max(data$HR_Salary),
            sd(data$HR_Salary),
            quantile(data$HR_Salary, 0.25, names = FALSE),
            quantile(data$HR_Salary, 0.75, names = FALSE))
)
cat("\n--- Salary statistics ---\n"); print(salary_stats)
write.csv(salary_stats, file.path(tab_dir, "salary_statistics.csv"), row.names = FALSE)

# ---- 6. Overtime statistics --------------------------------------------------
# Overtime = Payroll_Salary - HR_Salary (can be negative when payroll paid less).
data$Overtime <- data$Payroll_Salary - data$HR_Salary
cat("\n--- Overtime summary ---\n"); print(summary(data$Overtime))

# ---- 7. Group by department --------------------------------------------------
dept_summary <- data %>%
  group_by(Department) %>%
  summarise(
    Number_of_Employees = n(),
    Average_Salary      = mean(HR_Salary, na.rm = TRUE),
    Median_Salary       = median(HR_Salary, na.rm = TRUE),
    Total_Overtime      = sum(Overtime, na.rm = TRUE),
    .groups = "drop"
  )
cat("\n--- Summary by department ---\n"); print(dept_summary)
write.csv(dept_summary, file.path(tab_dir, "department_summary.csv"), row.names = FALSE)

# ---- 8. Group by job title ---------------------------------------------------
data$Job_Title <- paste(data$Department, data$Occupational_Level)
job_summary <- data %>%
  group_by(Job_Title) %>%
  summarise(Average_Salary = mean(HR_Salary, na.rm = TRUE), .groups = "drop")
cat("\n--- Average salary by job title ---\n"); print(job_summary)
write.csv(job_summary, file.path(tab_dir, "job_title_summary.csv"), row.names = FALSE)

# ---- 9-11. Highest salaries & filtering -------------------------------------
cat("\n--- Highest salary ---\n");       print(data[data$HR_Salary == max(data$HR_Salary), ])
cat("\n--- Salary > 80,000 ---\n");      print(data[data$HR_Salary > 80000, ])
cat("\n--- Overtime > 500 ---\n");       print(filter(data, Overtime > 500))

# ---- 12. Histogram -----------------------------------------------------------
save_plot("01_salary_histogram",
  hist(data$HR_Salary, main = "Distribution of Employee Salaries",
       xlab = "Salary", ylab = "Frequency", col = "steelblue", border = "white"))

# ---- 13. Bar chart -----------------------------------------------------------
avg_salary <- data %>%
  group_by(Department) %>%
  summarise(Average_Salary = mean(HR_Salary, na.rm = TRUE), .groups = "drop")
save_plot("02_avg_salary_by_department",
  barplot(avg_salary$Average_Salary, names.arg = avg_salary$Department,
          main = "Average Salary by Department", xlab = "Department",
          ylab = "Average Salary", col = "steelblue"))

# ---- 14. Boxplot -------------------------------------------------------------
save_plot("03_salary_boxplot_by_department",
  boxplot(HR_Salary ~ Department, data = data,
          main = "Salary Distribution by Department",
          xlab = "Department", ylab = "Salary", col = "lightblue"))

# ---- 15. Scatter plot --------------------------------------------------------
save_plot("04_salary_vs_overtime",
  plot(data$HR_Salary, data$Overtime, main = "Base Salary vs Overtime Pay",
       xlab = "Base Salary", ylab = "Overtime Pay", pch = 3))

# ---- 16. Correlation ---------------------------------------------------------
corr <- cor(data$HR_Salary, data$Overtime, use = "complete.obs")
cat("\nCorrelation (HR_Salary vs Overtime):", round(corr, 3), "\n")

# ---- 17. Additional graph: average salary by occupational level -------------
level_salary <- data %>%
  group_by(Occupational_Level) %>%
  summarise(Average_Salary = mean(HR_Salary, na.rm = TRUE), .groups = "drop")
print(level_salary)
write.csv(level_salary, file.path(tab_dir, "level_summary.csv"), row.names = FALSE)
save_plot("05_avg_salary_by_level",
  barplot(level_salary$Average_Salary, names.arg = level_salary$Occupational_Level,
          main = "Average Salary by Occupational Level",
          xlab = "Occupational Level", ylab = "Average Salary", col = "steelblue"))

cat("\nDone. Figures saved to", fig_dir, "and tables to", tab_dir, "\n")
