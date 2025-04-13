-- data cleaning

SELECT *
FROM layoffs
;

-- 1. removing dublicates
-- 2. standadize data eg spellings
-- 3. null values or blank values
-- 4. removing any columns that are irrevant

-- creating another table to avoid altering the original data

CREATE TABLE layoffs_staging
LIKE layoffs
;


SELECT *
FROM layoffs_staging
;

INSERT layoffs_staging
SELECT *
FROM layoffs
;

-- removing dublicates
SELECT * ,
ROW_NUMBER () OVER(PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM layoffs_staging
;


WITH dublicate_cte AS
(
SELECT * ,
ROW_NUMBER () OVER
(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off , `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM dublicate_cte
WHERE row_num > 1
;

-- checking if the dublicates are correct
SELECT *
FROM layoffs_staging
WHERE company = 'casper'
;


-- deleting the dublicates

WITH dublicate_cte AS
(
SELECT * ,
ROW_NUMBER () OVER
(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off , `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
DELETE  
FROM dublicate_cte
WHERE row_num > 1
;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

SELECT *
FROM layoffs_staging2
;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER () OVER
(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off , `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
;

-- Standadizing data 


SELECT company, TRIM(company)
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%'
;

SELECT distinct industry
FROM layoffs_staging2

;

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%'
;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1
;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1
;

SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;


SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y' )
FROM layoffs_staging2
;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y' )
;


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE 
;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
;




SELECT T1.industry, T2.industry
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
    AND T1.location = T2.location
WHERE ( T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL
;

UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company 
SET T1.industry = T2.industry
WHERE T1.industry IS NULL 
AND T2.industry IS NOT NULL
;


SELECT *
FROM layoffs_staging2
;

-- removing unecessary rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;





































