--Creating the table called public.attacks 
CREATE TABLE IF NOT EXISTS public.attacks ( 
	case_number VARCHAR(300), 
	date VARCHAR(300), 
	year VARCHAR(300), 
	type VARCHAR(300), 
	country VARCHAR(300), 
	area VARCHAR(300), 
	location VARCHAR(300), 
	activity VARCHAR(300), 
	name VARCHAR(300), 
	sex VARCHAR(300), 
	age VARCHAR(300), 
	injury VARCHAR(300), 
	fatal_yn VARCHAR(300), 
	time VARCHAR(300),  
	species VARCHAR(300), 
	investigator_or_source VARCHAR(300), 
	original_order VARCHAR(300)
);

--Importing the data set from the path "C:\Data\df_attacks.csv". 
COPY attacks(case_number, 
			 date, 
			 year, 
			 type, 
			 country, 
			 area, 
			 location, 
			 activity, 
			 name, 
			 sex, 
			 age, 
			 injury, 
			 fatal_yn, 
			 time, 
			 species, 
			 investigator_or_source, 
			 original_order)
FROM 'C:\Data\df_attacks.csv'
DELIMITER ','
CSV HEADER ; -- This data can be found Kaggle -> https://www.kaggle.com/datasets/felipeesc/shark-attack-dataset

--Let's view the data. 
SELECT * FROM public.attacks

/*Let's remove the null values from the data. */
SELECT * 
FROM public.attacks
WHERE case_number IS NULL

DELETE FROM public.attacks --Removing nulls from case_number. 
WHERE 
	case_number IS NULL 

DELETE FROM public.attacks --Removing nulls from date. 
WHERE 
	date IS NULL

SELECT * 
FROM public.attacks 
WHERE species IS NULL OR species = ' '; --So There are 724 rows that has null values and blanks in it. 

UPDATE public.attacks
SET species = 'Unknown'
WHERE species IS NULL OR species = ' ';

--Let's just check the manipulation.
SELECT DISTINCT species, count(*) AS count
FROM public.attacks
GROUP BY species 
ORDER BY count DESC

-----------------------------------------------------------------------------------------------------------------------
/*Cleaning type column*/
--Lets clean type column.
SELECT DISTINCT type
FROM public.attacks ; --There is nothing wrong with this column. 

UPDATE public.attacks
SET type = 'Boat'
WHERE type = 'Boatomg' OR type = 'Boating' ; 

--We have to replace nulls from 'Others' in type column.  
UPDATE public.attacks
SET type = 'Others'
WHERE type IS NULL
-----------------------------------------------------------------------------------------------------------------------

/*Cleaning country column*/
--We have country name in UPPER CASE, we have to change it into Camel Case. 
SELECT DISTINCT country
FROM public.attacks ORDER BY country

SELECT 
	INITCAP(CONCAT(UPPER(LEFT(country, 1)), LOWER(SUBSTRING(country, 2))))
FROM public.attacks

UPDATE public.attacks --mainipulating the country coulumn 
SET country = INITCAP(CONCAT(UPPER(LEFT(country, 1)), LOWER(SUBSTRING(country, 2))))

--now lets see any nulls and blanks in the country table.
SELECT country
FROM public.attacks
WHERE country = '' OR country IS NULL  -- There are 50 rows.

UPDATE public.attacks
SET country = 'Unknown'
WHERE country = '' OR country IS NULL

-----------------------------------------------------------------------------------------------------------------------
/*Let's clean the area table*/ 
SELECT DISTINCT area,
	COUNT(*)
FROM public.attacks
WHERE area IS NULL OR area = ' '
GROUP BY area -- there are 455 null values. We will replace it to 'Not Defined'

UPDATE public.attacks
SET area = 'Not Defined'
WHERE area IS NULL OR area = ' '

-----------------------------------------------------------------------------------------------------------------------
/*let's clean the location column*/
SELECT location, count(*)
FROM public.attacks
GROUP BY location --There are 540 rows that are null, we will again replace it to 'Not Defined'

UPDATE public.attacks
SET location = 'Not Defined'
WHERE location IS NULL

-----------------------------------------------------------------------------------------------------------------------
/*let's clean the activity column*/
SELECT distinct activity, count(*) AS count
FROM public.attacks
WHERE activity IS NULL OR activity =' ' OR activity = '.'
GROUP BY activity -- There are total of 548 rows. 

UPDATE public.attacks
SET activity = 'Others'
WHERE 
	activity IS NULL 
	OR activity =' ' 
	OR activity = '.'

-----------------------------------------------------------------------------------------------------------------------
/*let's clean the sex column*/
SELECT sex, count(*) AS count
FROM public.attacks
GROUP BY sex
ORDER BY count DESC
-- Let's see if we can fill these null values to the designated genders. Since we have some Sex in name column. 
SELECT sex, name
FROM public.attacks
WHERE 
	name like '%male%' 
	OR name like '%female%'
	OR name like '%boy%'
	OR name like '%girl%'
	AND sex IS NULL 
ORDER BY sex DESC


UPDATE public.attacks
SET sex = 'M'
WHERE 	name like '%male%' 
	OR name like '%female%'
	OR name like '%boy%'
	OR name like '%girl%' 
	AND sex IS NULL

UPDATE public.attacks
SET sex = null
WHERE name = 'a male & a female'

--Let's deal with null values, and other outliers and replace them with 'Not Defined'.
UPDATE public.attacks 
SET sex = 'not defined'
WHERE sex IN ('N', '.', 'lli')
 
UPDATE public.attacks 
SET sex = 'not defined'
WHERE sex IS NULL

UPDATE public.attacks 
SET sex = 'M'
WHERE sex = 'M '

-----------------------------------------------------------------------------------------------------------------------
/*let's clean the age column*/
SELECT DISTINCT age
FROM public.attacks

SELECT DISTINCT age,  LEFT(age, 2) AS new_age, count(*) AS number_of_people
FROM public.attacks
GROUP BY age, new_age
ORDER BY number_of_people DESC

UPDATE public.attacks
SET age = 'Not Defined'
WHERE age IS NULL

UPDATE public.attacks
SET age = 'Not Defined'
WHERE age = 'N/A'

UPDATE public.attacks
SET age = 'Not Defined'
WHERE age = ' ' OR age = '  '

SELECT
	DISTINCT age, 
  	CASE
    WHEN age ~ '[0-9]+' THEN substring(age from 1 for 2)
    ELSE ''
  END AS new_age, COUNT(*)
FROM public.attacks
GROUP BY 1,2
ORDER BY new_age ;

UPDATE public.attacks
SET age = CASE
    WHEN age ~ '[0-9]+' THEN SUBSTRING(age from 1 for 2)
    ELSE ''
  END ;

SELECT DISTINCT age, count(*)
FROM public.attacks GROUP BY age
ORDER BY age DESC;

UPDATE public.attacks
SET age = null
WHERE age IN ('', '?', 'mi', '>5', 'Bo', 'Ca', '? ');

UPDATE public.attacks
SET age = 2
WHERE age = '2½';

UPDATE public.attacks
SET age = 6
WHERE age = '6½';

ALTER TABLE public.attacks ALTER COLUMN age TYPE INTEGER USING(age::INTEGER);

UPDATE public.attacks 
SET age = CAST (age AS INT); --Check!!

SELECT DISTINCT age FROM public.attacks; -- Age column is now cleaned and casted as an integer. 
---------------------------------------------------------------------------------
/*let's clean the injury column*/
SELECT DISTINCT injury
FROM public.attacks ;

--We have FATAL in UPPER CASE, we need to change it into Camel Case. 
SELECT LEFT(injury, 5)
FROM public.attacks
WHERE injury LIKE 'FATAL%' OR injury LIKE 'fatal%';

UPDATE public.attacks
SET injury = LEFT(injury, 5)
WHERE injury LIKE 'FATAL%' OR injury LIKE 'fatal%';

UPDATE public.attacks
SET injury = 'Fatal'
WHERE injury = 'FATAL';

SELECT LEFT(injury, 9)
FROM public.attacks
WHERE injury LIKE 'No injury%' OR injury LIKE 'no injury%' OR injury LIKE 'NO INJURY%'  ;

UPDATE public.attacks
SET injury = LEFT(injury, 9)
WHERE injury LIKE 'No injury%' OR injury LIKE 'no injury%' OR injury LIKE 'NO INJURY%'  ;

---------------------------------------------------------------------------------
/*let's clean the fatal_yn column*/
SELECT DISTINCT fatal_yn, COUNT(*)
FROM public.attacks 
GROUP BY fatal_yn
ORDER BY 2 DESC

SELECT injury, fatal_yn, 
    CASE
        WHEN injury = 'No injury' THEN 'N'
        WHEN injury = 'Fatal' THEN 'Y'
        ELSE fatal_yn
    END AS Fatal
FROM public.attacks;

UPDATE public.attacks
SET fatal_yn = CASE
        WHEN injury = 'No injury' THEN 'N'
        WHEN injury = 'Fatal' THEN 'Y'
        ELSE fatal_yn 
		END  

SELECT DISTINCT fatal_yn, count(*)
FROM  public.attacks
GROUP BY fatal_yn

UPDATE public.attacks
SET fatal_yn = TRIM(fatal_yn)

DELETE FROM public.attacks
WHERE fatal_yn IN ('M', '2017')

UPDATE public.attacks
SET fatal_yn = 'N/A'
WHERE fatal_yn IS NULL 

UPDATE public.attacks
SET fatal_yn = 'Unknown'
WHERE fatal_yn = 'UNKNOWN'

---------------------------------------------------------------------------------
/*let's clean the time column*/
SELECT DISTINCT time,
	COUNT(*)
FROM public.attacks
GROUP BY time ORDER BY 2 DESC

--Dealing with null values.
UPDATE public.attacks
SET time = 'Not Recorded'
WHERE time IS NULL
--Extracting one first 2 values and adding a new column in the data. 

SELECT distinct time, SUBSTRING(time, 1,2)
FROM public.attacks 

SELECT time, SUBSTRING(time, 1,2),
	CASE
		WHEN SUBSTRING(time, 1,2) < '04' THEN 'Pre-dawn'
		WHEN SUBSTRING(time, 1,2) >= '04' AND SUBSTRING(time, 1,2) < '07' THEN 'Early Morning'
		WHEN SUBSTRING(time, 1,2) >= '07' AND SUBSTRING(time, 1,2) < '10' THEN 'Morning'
		WHEN SUBSTRING(time, 1,2) >= '10' AND SUBSTRING(time, 1,2) < '12' THEN 'Early Noon'
		WHEN SUBSTRING(time, 1,2) >= '12' AND SUBSTRING(time, 1,2) < '15' THEN 'Afternoon'
		WHEN SUBSTRING(time, 1,2) >= '15' AND SUBSTRING(time, 1,2) < '19' THEN 'Evening'
		WHEN SUBSTRING(time, 1,2) >= '19' AND SUBSTRING(time, 1,2) < '20' THEN 'Late Evening'
		WHEN SUBSTRING(time, 1,2) >= '20' AND SUBSTRING(time, 1,2) < '24' THEN 'Night'
		ELSE time
		END AS attack_time
FROM public.attacks  

ALTER TABLE public.attacks 
ADD grouped_time VARCHAR(150)

UPDATE public.attacks
SET grouped_time = CASE
		WHEN SUBSTRING(time, 1,2) < '04' THEN 'Pre-dawn'
		WHEN SUBSTRING(time, 1,2) >= '04' AND SUBSTRING(time, 1,2) < '07' THEN 'Early Morning'
		WHEN SUBSTRING(time, 1,2) >= '07' AND SUBSTRING(time, 1,2) < '10' THEN 'Morning'
		WHEN SUBSTRING(time, 1,2) >= '10' AND SUBSTRING(time, 1,2) < '12' THEN 'Early Noon'
		WHEN SUBSTRING(time, 1,2) >= '12' AND SUBSTRING(time, 1,2) < '15' THEN 'Afternoon'
		WHEN SUBSTRING(time, 1,2) >= '15' AND SUBSTRING(time, 1,2) < '19' THEN 'Evening'
		WHEN SUBSTRING(time, 1,2) >= '19' AND SUBSTRING(time, 1,2) < '20' THEN 'Late Evening'
		WHEN SUBSTRING(time, 1,2) >= '20' AND SUBSTRING(time, 1,2) < '24' THEN 'Night'
		ELSE time
		END
		
SELECT distinct grouped_time, count(*) FROM public.attacks group by grouped_time order by 2 desc

UPDATE public.attacks
SET grouped_time = 'Afternoon'
WHERE grouped_time IN ('Late afternoon', 'After noon', 'Late afternon')

UPDATE public.attacks
SET grouped_time = 'Early Noon'
WHERE grouped_time IN ('midday', 'Early afternoon')

UPDATE public.attacks
SET grouped_time = 'Morning'
WHERE grouped_time IN ('Early morning', 'Dawn')

DELETE FROM public.attacks
WHERE grouped_time NOT IN (
    'Not Recorded',
    'Afternoon',
    'Evening',
    'Early Noon',
    'Morning',
    'Night',
    'Late Evening',
    'Early Morning',
    'Pre-dawn',
    'Dusk'
);

---------------------------------------------------------------------------------
/*let's clean the investigator_or_source column*/
UPDATE public.attacks
SET investigator_or_source = TRIM(investigator_or_source)

---------------------------------------------------------------------------------
/*let's clean the original_order column*/
SELECT DISTINCT original_order
FROM public.attacks
WHERE original_order IS NULL OR original_order = '' OR original_order = ' ' --This column is alresdy cleaned. 

ALTER TABLE public.attacks ALTER COLUMN original_order 
TYPE NUMERIC USING(original_order::NUMERIC) --Changing the datatype.

---------------------------------------------------------------------------------
/*let's clean the date and year columns*/
SELECT date 
FROM public.attacks
WHERE date LIKE '%Reported %'

DELETE FROM public.attacks
WHERE date LIKE '%Reported %'

SELECT year FROM public.attacks ORDER BY year

--Deleting the years that have value '0'
DELETE FROM public.attacks
WHERE year = '0'

ALTER TABLE public.attacks ALTER COLUMN year TYPE NUMERIC USING(year::NUMERIC)

--Here we have the cleaned data on which we will do analysis. 
SELECT * FROM public.attacks


