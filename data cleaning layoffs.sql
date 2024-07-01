-- Data Cleaning

SELECT * 
FROM layoffs;  

-- 1. remove duplicates if any
-- 2. standardize the data
-- 3. Null values or bland values
-- 4. Remove any columns

Create Table layoffs_staging
like layoffs;

insert layoffs_staging
select  *
from layoffs;

select * from 
layoffs_staging;

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicates_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 
funds_raised_millions) AS row_num
FROM layoffs_staging
)

SELECT * 
FROM duplicates_cte
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Lendingkart';


CREATE TABLE `layoffs_staging2` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, 
funds_raised_millions) AS row_num
FROM layoffs_staging;


select * from 
layoffs_staging2
where row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardize data

Select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
SET company = TRIM(company);


Select DISTINCT(industry)
from layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%' ;

select * 
from layoffs_staging2
where industry like 'Crypto%';

Select DISTINCT country, TRIM(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = TRIM(TRAILING '.' FROM country)
where country like 'United States%' ;

select `date`
-- STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'AirBnb';  

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


