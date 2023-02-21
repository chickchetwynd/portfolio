# Cleaning an Audible database.

Raw data is available [here](https://www.kaggle.com/datasets/snehangsude/audible-dataset?select=audible_uncleaned.csv)

The purpose of this project is to clean a dataset ready for analysis using SQL. The data was downloaded as a CSV file and I used DB browser to run queries and edit the table.
<br>

The table contains data from a web scraping project fron Audible India. It contains 87,489 rows and 8 columns. Lets see a table extract:

```sql
SELECT  
  *
FROM audible_uncleaned

LIMIT 3
```

| name                                                                                        | author                                       | narrator                                                 | time              | releasedate | language | stars         | price |
|---------------------------------------------------------------------------------------------|----------------------------------------------|----------------------------------------------------------|-------------------|-------------|----------|---------------|-------|
| Billi Aur Moosarani [Cat and Musrani]                                                       | Writtenby:Shivani                            | Narratedby:SarahHashmi                                   | 26 mins           | 2021-10-14  | Hindi    | Not rated yet | Free  |
| Pariyon Ki Kahaniya [Fairy Tales]                                                           | Writtenby:JacobGrimm                         | Narratedby:AnuradhaChauhan                               | 2 hrs and 15 mins | 2021-12-08  | Hindi    | Not rated yet | Free  |
| Gebrüder Grimm: Dornröschen (aus: "Kinder- und Hausmärchen")                                | Writtenby:BrüderGrimm                        | Narratedby:Ernst-AugustSchepmann                         | 47 mins           | 2013-01-25  | german   | Not rated yet | Free  |


<br>
<br>
Calculating duplicate rows:

```sql
--duplicate rows

SELECT  

  (SELECT COUNT(1)
   FROM
    (SELECT name
     FROM
     audible_uncleaned)) AS total_rows,


  (SELECT
    COUNT(1)
  FROM
  (SELECT DISTINCT name
  FROM
    audible_uncleaned)) AS unique_rows,

    ((SELECT COUNT(1)
    FROM
    (SELECT name
    FROM
    audible_uncleaned))
     
     -
     
    (SELECT
    COUNT(1)
    FROM
    (SELECT DISTINCT name
    FROM
    audible_uncleaned))) AS num_duplicate_rows
```

| total_rows | unique_rows | num_duplicate_rows |
|------------|-------------|--------------------|
| 87489      | 82767       | 4722               |


<br>

A problem encountered here is that there are instances where there are multiple rows with the same title, but it isn't a true duplicate- it is the same audiobook but a different version with a separate narator. Let's try this instead:

<br>

```sql
SELECT
	ROW_NUMBER () OVER (PARTITION BY (name || narrator || language)  ORDER BY (name || narrator || language)) AS rn,
	name || narrator || language AS concat_column,
	name,
	narrator
FROM audible_uncleaned
```
This concatenates the name and the narrator of the book and then assigns a row number to rows partitioned on this new concatenation. Any duplicate rows will have a row number greater than 1. There are **486** duplicates based on name and narrator. Let's remove these rows from the table:


```sql
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
```
<br>

Now lets address the _author_ and _narrator_ columns. They contain the extra characters 'Writtenby:' and 'Narratedby:' before the actual information that we need. Lets format these columns correctly:

<br>

```sql
--Removing unwanted characters from the author column.
	
UPDATE audible_uncleaned
SET author = SUBSTR(author, 11)
```
<br>

```sql
--add a space ' ' after each comma ',' in the author column.

UPDATE audible_uncleaned
SET author = REPLACE(author, ',', ', ')
```
<br>

Removing unwanted characters from the _narrator_ column:
<br>

```sql
UPDATE audible_uncleaned
SET narrator = SUBSTR(narrator, 12)
```
<br>


```sql

--Add a space ' ' after each comma ',' in the _narrator_ column.
UPDATE audible_uncleaned
SET narrator = REPLACE(narrator, ',', ', ')
```

<br>

Next, lets format the _time_ column so that it just displays the duration of the audiobook in minutes only. A problem that we have here is that I am using SQlite which does not have any datatype for dates or timestamps, all of the data is stored as a string. This means we can't use a function like EXTRACT() to extract just the number of minutes and we will have to parse the string an make calculations to get what we want:

<br>


```sql

--parsing the time column to extract minutes

SELECT 
   CASE 
      WHEN time LIKE '%hrs%' AND time LIKE '%mins%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') - 1) AS INTEGER) * (60) + (CAST(SUBSTR(time, INSTR(time, 'and') + 1, INSTR(time, 'mins') -1) AS INTEGER))
			
	  WHEN time LIKE '%hrs%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') * 60) AS INTEGER)
			
	  WHEN time LIKE '%mins%'
			THEN CAST(SUBSTR(time, 1, (INSTR(time, 'mins') -1)) AS INTEGER)
	  END AS duration_mins
	  
FROM audible_uncleaned;
```
