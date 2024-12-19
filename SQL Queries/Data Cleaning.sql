-- SQL Project - Data Cleaning

-- Link Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT * 
FROM layoffs

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
SELECT * INTO layoffs_staging --> Copy from layoffs [data + structure]
FROM layoffs

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- 1. Remove Duplicates

-- First let's check for duplicates

WITH layoffsCTE AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, date 
							    ORDER BY total_laid_off DESC) AS RN
	FROM layoffs_staging
)
SELECT * 
FROM layoffsCTE
WHERE RN > 1

-- let's just look at oda to confirm

SELECT * 
FROM layoffs_staging
WHERE company = 'oda'

-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate.

-- these are our real duplicates 
WITH layoffsCTE AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date , stage, country, funds_raised_millions
								ORDER BY total_laid_off DESC) AS RN
	FROM layoffs_staging
)
SELECT * 
FROM layoffsCTE
WHERE RN > 1

SELECT *
FROM layoffs_staging 
WHERE company = 'Yahoo'

-- these are the ones we want to delete where the row number is > 1 or 2 or greater essentially

-- now you may want to write it like this:
WITH Delete_CTE AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
			  percentage_laid_off, date, stage, country, funds_raised_millions 
			  ORDER BY total_laid_off DESC) AS RN
	FROM layoffs_staging
)
DELETE FROM Delete_CTE 
WHERE RN > 1

-- 2. Standardize Data

SELECT *
FROM layoffs_staging

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry

SELECT *
FROM layoffs_staging
WHERE industry IS NULL OR industry = '' --> NULL OR '' as empty string
ORDER BY industry

-- let's take a look at these
SELECT * 
FROM layoffs_staging
WHERE company LIKE 'Bally%' --> 'NULL' as string 

-- nothing wrong here
SELECT *
FROM layoffs_staging
WHERE company LIKE 'airbnb%' --> NULL is nothing 

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = ''

-- now if we check those are all null
SELECT *
FROM layoffs_staging
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry

-- now we need to populate those nulls if possible
UPDATE T1
SET T1.industry = T2.industry
FROM layoffs_staging T1 INNER JOIN layoffs_staging T2
ON T1.company = T2.company
WHERE T1.industry IS NULL AND T2.industry IS NOT NULL

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT *
FROM layoffs_staging
WHERE industry IS NULL OR industry = ''

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency','CryptoCurrency')

-- now that's taken care of:
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry

-- we also need to look at 
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country

-- Method 1 --> Using UPDATE & WHERE 
UPDATE layoffs_staging
SET country = 'United States'
WHERE country = 'United States.'

-- Method 2 --> Using UPDATE & TRIM() 
UPDATE layoffs_staging
SET country = TRIM('.' FROM country)

-- now if we run this again it is fixed
SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country

-- Let's also fix the date columns:
SELECT *
FROM layoffs_staging

-- we can use string to date to update this field
UPDATE layoffs_staging
SET date = CONVERT(date, date, 103)

-- now we can convert the data type properly
ALTER TABLE layoffs_staging ALTER COLUMN date DATE

SELECT *
FROM layoffs_staging

-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values

SELECT *
FROM layoffs_staging

-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL

-- Delete Useless data we can't really use
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL

SELECT *
FROM layoffs_staging