# Data

Place the dataset here as **`employee_salary_data.csv`** (the file is git-ignored by default).

> If your data is non-sensitive and you want it in the repo, remove the `data/*.csv` line from `.gitignore`.

## Expected columns

| Column | Type | Description |
|---|---|---|
| Employee_ID | integer | Unique employee identifier |
| Name | text | Employee name |
| Gender | text | Gender |
| Race | text | Race group |
| Age | integer | Age in years |
| Department | text | Department (IT, HR, Finance, Marketing, Sales, Markets) |
| Occupational_Level | text | Junior / Mid / Senior |
| HR_Salary | numeric | Base salary recorded by HR |
| Payroll_Salary | numeric | Salary actually paid by payroll |
| Compa_Ratio | numeric | Salary relative to the market/pay-band midpoint |
| Performance_Rating | integer | Performance score (1-5) |
| Manager_ID | integer | Manager's Employee_ID (`NA` for top-level employees) |
| Manager_Level | text | Manager's occupational level (empty if no manager) |
