-- EDA - SQL Server Exploratory Data Analysis 

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT *
FROM layoffs_staging

-- Easier Queries
SELECT MAX(total_laid_off) AS [Max_Total_Laid_off]
FROM layoffs_staging

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off) AS [Max_percentage_laid_off], 
       MIN(percentage_laid_off) AS [Min_percentage_laid_off]
FROM layoffs_staging
WHERE percentage_laid_off IS NOT NULL

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_staging 
WHERE percentage_laid_off = 1 --> This means that these companies are closed

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
-- BritishVolt looks like an EV company, I recognize that company - raised like 2 billion dollars and went under 

------------------------------------------------------------------------------------------------------------------------------------
-- Companies with the biggest single Layoff
SELECT TOP(5)company, total_laid_off 
FROM layoffs_staging
ORDER BY 2 DESC
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT TOP(10)company, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY company
ORDER BY 2 DESC

-- by location
SELECT TOP(10)location, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY location
ORDER BY 2 DESC

-- this it total in the past 3 years or in the dataset

SELECT TOP(10)country, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC

SELECT YEAR(DATE) AS years, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY YEAR(DATE)
ORDER BY 2 DESC

SELECT TOP(10)industry, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC

SELECT TOP(10)stage, SUM(total_laid_off) AS [Sum_of_total_laid_off]
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC

------------------------------------------------------------------------------------------------------------------------------------
-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 
WITH Company_Year AS (
	SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS Sum_of_total_laid_off
	FROM layoffs_staging
	GROUP BY company, YEAR(date)
), Company_Year_Rank AS (
	SELECT company, years, Sum_of_total_laid_off,
	       DENSE_RANK() OVER(PARTITION BY years ORDER BY Sum_of_total_laid_off DESC) AS ranking
	FROM Company_Year
)
SELECT *
FROM Company_Year_Rank 
WHERE ranking <= 5 AND years IS NOT NULL
ORDER BY years ASC, Sum_of_total_laid_off DESC


-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(CONVERT(VARCHAR, DATE, 120), 1, 7) AS MonthYear, SUM(total_laid_off) AS TotalLaidOff
FROM layoffs_staging
GROUP BY SUBSTRING(CONVERT(VARCHAR, DATE, 120), 1, 7)
ORDER BY MonthYear ASC

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS (
    SELECT SUBSTRING(CONVERT(VARCHAR, DATE, 120), 1, 7) AS MonthYear, SUM(total_laid_off) AS TotalLaidOff
    FROM layoffs_staging
    GROUP BY SUBSTRING(CONVERT(VARCHAR, DATE, 120), 1, 7)
)
SELECT 
    MonthYear,
    (SELECT SUM(TotalLaidOff) FROM DATE_CTE t2 WHERE t2.MonthYear <= t1.MonthYear) AS RollingTotalLayoffs
FROM DATE_CTE t1
ORDER BY MonthYear
