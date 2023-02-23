# Cleaning an Audible database.

Raw data is available [here](https://www.kaggle.com/datasets/snehangsude/audible-dataset?select=audible_uncleaned.csv)

The purpose of this project is to clean a dataset ready for analysis using SQL. The data was downloaded as a CSV file and I used DB browser to run queries and edit the table.
<br>

# Project set up

db browser and mysql


<br>
The table contains data from a web scraping project from Audible India. It contains 87,489 rows and 8 columns. Lets see a table extract:

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

A problem encountered here is that there are instances where there are multiple rows with the same title, but it isn't a true duplicate- it is the same audiobook but a different version with a separate narrator. Let's try this instead:

<br>

```sql
SELECT
	ROW_NUMBER () OVER (PARTITION BY (name || narrator || language)  ORDER BY (name || narrator || language)) AS rn,
	name || narrator || language AS concat_column,
	name,
	narrator
FROM audible_uncleaned
```
<br>

| rn | concat_column                                                                              | name                                             | narrator                   |
|----|--------------------------------------------------------------------------------------------|--------------------------------------------------|----------------------------|
| 1  | 100 quotes by Albert EinsteinNarratedby:PaulSperaEnglish                                   | 100 quotes by Albert Einstein                    | Narratedby:PaulSpera       |
| 1  | 100 quotes by Benjamin FranklinNarratedby:PaulSperaEnglish                                 | 100 quotes by Benjamin Franklin                  | Narratedby:PaulSpera       |
| 2  | 100 quotes by Benjamin FranklinNarratedby:PaulSperaEnglish                                 | 100 quotes by Benjamin Franklin                  | Narratedby:PaulSpera       |
| 1  | 100 quotes by Mahatma Gandhi in Chinese MandarinNarratedby:LucieTengDuvertmandarin_chinese | 100 quotes by Mahatma Gandhi in Chinese Mandarin | Narratedby:LucieTengDuvert |
| 1  | 100 quotes by Mahatma GandhiNarratedby:PaulSperaEnglish                                    | 100 quotes by Mahatma Gandhi                     | Narratedby:PaulSpera       |

<br>

This concatenates the name and the narrator of the book and then assigns a row number to rows partitioned on this new concatenation. Any duplicate rows will have a row number greater than 1. In the table above, you can see that the duplicate row has a row number (rn) of 2. All other non-duplicate rows have a rn of 1. There are **486** duplicates based on name and narrator in the main table. Lets use these new row numbers in a CTE to remove duplicate rows from the main table:


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

Great, that's all the duplicates taken care of :sunglasses: :star_struck:

<br>

Now lets address the _author_ and _narrator_ columns. They contain the extra characters 'Writtenby:' and 'Narratedby:' before the actual information that we need. Lets format these columns correctly:

<br>

![Screenshot 2023-02-22 at 12 24 22 PM](https://user-images.githubusercontent.com/121225842/220752985-f3727c9d-0e62-41d2-bb02-a5bfcf90d666.jpeg)



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

| name                                                | author                  | narrator   | time               | releasedate | language | stars                       | price  |
|-----------------------------------------------------|-------------------------|------------|--------------------|-------------|----------|-----------------------------|--------|
| A Course in Miracles: Text, Vol. 1                  | Dr.HelenSchucman-scribe | JimStewart | 37 hrs and 26 mins | 25-07-12    | English  | 4.5 out of 5 stars6 ratings | 938.00 |
| A Course in Miracles: Workbook for Students, Vol. 2 | Dr.HelenSchucman-scribe | JimStewart | 19 hrs and 57 mins | 05-07-12    | English  | Not rated yet               | 938.00 |

<br>


Next, lets format the _time_ column so that it just displays the duration of the audiobook __in minutes only__. A problem that we have here is that I am using SQlite which does __not__ have any datatype for dates or timestamps, all of the data is stored as a string. This means we can't use a function like EXTRACT() to extract just the number of minutes and we will have to parse the string and make calculations to get what we need.

<br>

First up, lets make sure that before we parse the column that it is formatted uniformly throughout. The format we want is: __n hrs and n mins__. However in the table below, we can see an instance of __'hr'__ rather than __'hrs'__. There are also instances of __'min'__ rather than __'mins'__. Lets fix this first:

<br>

| name                          | time               |
|:-----------------------------:|:------------------:|
| The Red Pyramid               | 13 hrs and 44 mins |
| Mystery of the Griefer's Mark | 1 hr and 53 mins   |
| Geronimo Stilton #17          | 2 hrs and 28 mins  |
| ...                           | ...                |
| The Skeletons Strike Back     | 2 hrs and 1 min    |
| Dragonslayer                  | 12 hrs and 44 mins |
| A Bear Called Paddington      | 2 hrs and 39 mins  |

<br>

```sql
--Replacing 'hr' with 'hrs' in the time column.

UPDATE
	audible_uncleaned
SET
	time = REPLACE(time, 'hr ', 'hrs ')
WHERE time LIKE '%hr %'


--Replacing 'min' with 'mins' in time column

UPDATE
	audible_uncleaned
SET
	time = REPLACE(time, 'min', 'mins')
WHERE time LIKE '%min%';
	
--The above query converted some rows to 'minss'. Convert all these instances back to 'mins'
	
UPDATE
	audible_uncleaned
SET
	time = REPLACE(time, 'minss', 'mins')
WHERE time LIKE '%minss%';
```

<br>

Now that the _time_ column is formatted uniformly, lets create a new column where we parse the _time_ column and extract just the total number of minutes:

```sql

--parsing and calculation on time column to extract the duration in mins.

SELECT 

   time, 
   CASE 
      WHEN time LIKE '%hrs%' AND time LIKE '%min%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') - 1) AS INTEGER) * (60) + (CAST(SUBSTR(time, INSTR(time, 'and') + 3, INSTR(time, 'min') -1) AS INTEGER))
			
	  WHEN time LIKE '%hrs%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') -1) AS INTEGER) * 60
			
	  WHEN time LIKE '%min%'
			THEN CAST(SUBSTR(time, 1, (INSTR(time, 'min') -1)) AS INTEGER)
	  END AS duration_mins
	   
FROM audible_uncleaned;
```
<br>

| time               | duration |
|:------------------:|:--------:|
| 2 hrs and 3 mins   | 123      |
| 11 hrs and 16 mins | 676      |
| 10 hrs             | 600      |
| ...                | ...      |
| 43 mins            | 43       |
| 9 mins             | 9        |
| 2 hrs and 6 mins   | 126      |


<br>

The query above creates a case statement with three types of cases: case when there are hrs and mins, only hrs, and only mins. Each case statement extracts the correct portion of the string from which we can create the _duration column_ which contains the audiobook length in minutes.

<br>

Lets update the main table with this new column, called _duration_mins_, and omit the _time_ column:

<br>

```sql

	
--Create a new table called audible_cleaned with the new column called duration_mins and omitting the old column called time.

CREATE TABLE audible_cleaned AS

	SELECT
	name,
	author,
	narrator,
   CASE 
      WHEN time LIKE '%hrs%' AND time LIKE '%min%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') - 1) AS INTEGER) * (60) + (CAST(SUBSTR(time, INSTR(time, 'and') + 3, INSTR(time, 'min') -1) AS INTEGER))
			
	  WHEN time LIKE '%hrs%'
			THEN CAST(SUBSTR(time, 1, INSTR(time, 'hrs') -1) AS INTEGER) * 60
			
	  WHEN time LIKE '%min%'
			THEN CAST(SUBSTR(time, 1, (INSTR(time, 'min') -1)) AS INTEGER)
	  END AS duration_mins,
	  releasedate,
	  language,
	  stars,
	  price
	   
FROM audible_uncleaned; 
```
<br>

Checking to make sure everything worked...

<br>

```sql
SELECT *
FROM audible_cleaned
LIMIT 5
```

<br>

| name                                       | author          | narrator       | duration_mins | releasedate | language | stars                         | price  |
|:------------------------------------------:|:---------------:|:--------------:|:-------------:|:-----------:|:--------:|:-----------------------------:|:------:|
| Geronimo Stilton #11 & #12                 | GeronimoStilton | BillLobely     | 140           | 04-08-08    | English  | 5 out of 5 stars34 ratings    | 468.00 |
| The Burning Maze                           | RickRiordan     | RobbieDaymond  | 788           | 01-05-18    | English  | 4.5 out of 5 stars41 ratings  | 820.00 |
| The Deep End                               | JeffKinney      | DanRussell     | 123           | 06-11-20    | English  | 4.5 out of 5 stars38 ratings  | 410.00 |
| Daughter of the Deep                       | RickRiordan     | SoneelaNankani | 676           | 05-10-21    | English  | 4.5 out of 5 stars12 ratings  | 615.00 |
| The Lightning Thief: Percy Jackson, Book 1 | RickRiordan     | JesseBernstein | 600           | 13-01-10    | English  | 4.5 out of 5 stars181 ratings | 820.00 |

<br>

Success! :partying_face: :nerd_face: :muscle: The new _duration_mins_ column looks accurate. __SIDE NOTE__ this portion of the project was surprisingly tricky and took a few attempts. Creating this column could have been easier using Python instead as I could have used a for loop to iterate every row in order to calculate duration. I had tried to use a __correlated sub query__ using SQL but the query took too long to execute and never finished. An alternative method might have been to use a version of SQL (such as MySQL) that supports date datatypes. FUNctions such as EXTRACT() or DATEPART() would have come in real handy here :sleepy: :raised_eyebrow:

<br>

Now lets move on to the _releasedate_ column. Not too much to change here other than that it is currently formatted as DD-MM-YY. A more common way of formatting dates in databases is YYYY-MM-DD. Lets see if we can change this.




