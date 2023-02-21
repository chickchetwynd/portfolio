--Assigning row numbers to duplicate audio books who have the same name and narrator. Then removing these duplicate rows from the main table.

WITH CTE AS
(
SELECT
	ROW_NUMBER () OVER (PARTITION BY (name || narrator || language)  ORDER BY (name || narrator || language)) AS rn,
	name || narrator || language AS concat_column,
	name,
	narrator,
	time,
	releasedate,
	language,
	stars,
	price
FROM audible_uncleaned
)


DELETE FROM audible_uncleaned
	WHERE (name || narrator || language) IN
	(SELECT concat_column FROM CTE WHERE rn > 1);
	
	
	
--Removing unwanted characters from the author column.
	
UPDATE audible_uncleaned
SET author = SUBSTR(author, 11)


--add a space ' ' after each comma ',' in the author column.

UPDATE audible_uncleaned
SET author = REPLACE(author, ',', ', ')
	
	
--Remove unwanted characters from the narrator column
	
UPDATE audible_uncleaned
SET narrator = SUBSTR(narrator, 12)


--add a space ' ' after each comma ',' in the narrator column.

UPDATE audible_uncleaned
SET narrator = REPLACE(narrator, ',', ', ')
	
	
