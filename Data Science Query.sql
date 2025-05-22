SELECT *
FROM us_fulltime_data_jobs;

-- Fix Abbreviations --
USE data_science_salaries;

CREATE TABLE us_fulltime_data_jobs_readable AS
SELECT us_fulltime_data_jobsE
    work_year,
    job_title,
    CASE experience_level
        WHEN 'EN' THEN 'Entry-Level'
        WHEN 'MI' THEN 'Mid-Level'
        WHEN 'SE' THEN 'Senior-Level'
        WHEN 'EX' THEN 'Executive-Level'
        ELSE 'Unknown'
    END AS experience_level_name,
    CASE employment_type
        WHEN 'FT' THEN 'Full-Time'
        WHEN 'PT' THEN 'Part-Time'
        WHEN 'CT' THEN 'Contract'
        WHEN 'FL' THEN 'Freelance'
        ELSE 'Unknown'
    END AS employment_type_name,
    CASE remote_ratio
        WHEN 0 THEN 'Onsite'
        WHEN 50 THEN 'Hybrid'
        WHEN 100 THEN 'Remote'
        ELSE 'Unknown'
    END AS remote_work_type,
    CASE company_size
        WHEN 'S' THEN 'Small'
        WHEN 'M' THEN 'Medium'
        WHEN 'L' THEN 'Large'
        ELSE 'Unknown'
    END AS company_size_name,
    employee_residence,
    company_location,
    salary_in_usd
FROM us_fulltime_data_jobs;

SELECT *
FROM us_fulltime_data_jobs_readable;

-- Average Salary by Experience Level for Data Scientist --
WITH ranked_salaries AS (
    SELECT
        experience_level_name,
        salary_in_usd,
        ROW_NUMBER() OVER (PARTITION BY experience_level_name ORDER BY salary_in_usd) AS rn_asc,
        COUNT(*) OVER (PARTITION BY experience_level_name) AS cnt
    FROM us_fulltime_data_jobs_readable
    WHERE job_title = 'Data Scientist'
)
SELECT
    experience_level_name,
    AVG(salary_in_usd) AS average_salary
FROM ranked_salaries
WHERE rn_asc IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY experience_level_name
ORDER BY FIELD(experience_level_name, 'Entry-Level', 'Mid-Level', 'Senior-Level', 'Executive-Level');

-- Average Salary by Company Size --
SELECT
    company_size_name,
    ROUND(AVG(salary_in_usd), 2) AS average_salary_usd
FROM us_fulltime_data_jobs_readable
GROUP BY company_size_name
ORDER BY FIELD(company_size_name, 'Small', 'Medium', 'Large');

SELECT 
    remote_work_type,
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_usd
FROM us_fulltime_data_jobs_readable
GROUP BY remote_work_type
ORDER BY FIELD(remote_work_type, 'Onsite', 'Hybrid', 'Remote');

