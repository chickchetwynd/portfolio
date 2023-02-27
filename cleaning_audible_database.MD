# Cleaning an Audible database.

The purpose of this project is to clean a dataset so that there is a final table ready for analysis for a future project. I want to exclusively use SQL to clean and update the table with the intention of show casing skills such as __window functions__, __cleaning techniques__, and __data manipulation/wrangling__. Data cleaning is an essential component of analysis; without clean data the integrity of any conclusions drawn from analysis is compromised. This entire project will follow the steps I have taken to transform a dataset from raw data to a uniformly formatted, analysis-ready, reliable source.

<br>

## Project set up

I have previously been using Google's Big Query platform to store and query data but for this project, I wanted to move to a more commonly used Integrated Developer Environment (IDE) that used a more commonly used SQL dialect. I had planned to switch over to MySQL which required research into how to install MySQL, set up a local server to house the data, and then download and use MySQL Workbench to interact with it. After installation, I came across many issues with Workbench and after doing some research on [Stackoverflow](https://stackoverflow.com/) I fond that many other users had the same issue as me with Mac laptops that use the new M1 chip. I changed gears and was able to succesfully install SQLite and DB Browser instead. SQLite has some limitations but as you will see later in the project, I was able to overcome these.

The raw data is available [here](https://www.kaggle.com/datasets/snehangsude/audible-dataset?select=audible_uncleaned.csv) from Kaggle. I chose this data because it comes from a web scrapping project that resulted in particularly unclean data.

<br>

## The data


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

A problem encountered here is that there are instances where there are multiple rows with the same title, but it isn't a true duplicate- it is the same audiobook but a different version with a separate narrator. Let's try something else instead.

<br>

## Creating a Unique Row ID with Concatenation

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

The code above concatenates the name and the narrator of the book and then assigns a row number to rows partitioned on this new concatenation. Any duplicate rows will have a row number greater than 1. In the table above, you can see that the duplicate row has a row number (rn) of 2. All other non-duplicate rows have a rn of 1. There are **486** duplicates based on name and narrator in the main table. Lets use these new row numbers in a CTE to remove duplicate rows from the main table:


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

## String Manipulation


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

## Extracting time- Formatting the Column

<br>

Next, lets format the _time_ column so that it just displays the duration of the audiobook __in minutes only__. A problem that we have here is that SQlite  does __not__ have any datatype for dates or timestamps, all of the data is stored as a string. This means we can't use a function like EXTRACT() to extract just the number of minutes and we will have to parse the string and make calculations to get what we need.

<br>

First up, lets make sure that before we parse the column, it is formatted uniformly throughout. The format we want is: __n hrs and n mins__. However in the table below, we can see an instance of __'hr'__ rather than __'hrs'__. There are also instances of __'min'__ rather than __'mins'__. Lets fix this first:

<br>

<img width="394" alt="Screenshot 2023-02-23 at 11 47 52 AM" src="https://user-images.githubusercontent.com/121225842/221014288-e8881aa1-9b6e-48ff-8fad-d2e4e89b9982.png">


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

## Extracting Time- CASE WHEN

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

| time               | duration_mins |
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

## Extracting Time- Updating the Table

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


## Formatting _Releasedate_

<br>

![Screenshot 2023-02-23 at 12 50 19 PM](https://user-images.githubusercontent.com/121225842/221027650-b9c02089-f1f0-47af-9a08-5068fbb6c6a8.jpeg)


Now lets move on to the _releasedate_ column. Not too much to change here other than that it is currently formatted as DD-MM-YY. The standard way of formatting dates is the ISO 8601 standard which is YYYY-MM-DD. Lets see if we can change our column to this standard:

<br>

```sql
--Re-formating the releasedate column

UPDATE
  audible_cleaned
SET
  releasedate = (
    CASE 
      WHEN SUBSTR(releasedate, 7, 2) >= '00' AND SUBSTR(releasedate, 7, 2) <= '23' THEN '20' || SUBSTR(releasedate, 7, 2)
      ELSE '19' || SUBSTR(releasedate, 7, 2)
    END || '-' || SUBSTR(releasedate, 4, 2) || '-' || SUBSTR(releasedate, 1, 2)
  );
  
```

<br>

This code creates a case statement which adds the extra 2 digits to the 'YY' portion of the date to 'YYYY'. It makes sure to add '20' or '19' when needed. Then it concatenates the relevant sub-string for 'MM' and 'DD'. Lets look at the table now to check that it's correct:

<br>

| name                       | author          | narrator      | duration_mins | releasedate | language | stars                        | price  |
|----------------------------|-----------------|---------------|---------------|-------------|----------|------------------------------|--------|
| Geronimo Stilton #11 & #12 | GeronimoStilton | BillLobely    | 140           | 2008-08-04  | English  | 5 out of 5 stars34 ratings   | 468.00 |
| The Burning Maze           | RickRiordan     | RobbieDaymond | 788           | 2018-05-01  | English  | 4.5 out of 5 stars41 ratings | 820.00 |
| The Deep End               | JeffKinney      | DanRussell    | 123           | 2020-11-06  | English  | 4.5 out of 5 stars38 ratings | 410.00 |

<br>

Great, everything looks correct with the releasedate!

<br>

## Splitting up the _stars_ column

<br>

Next lets take a look at the _strars_ column. The rating (num of stars out of 5) is joined together with the number of ratings in the same column. These two pieces of information should be split into two columns as they are independant variables:

<br>

```sql
  --CASE statement that creates two columns by splitting up the stars column
  
 SELECT

	stars,

	CASE
		WHEN stars LIKE '%stars%'
			THEN SUBSTR(stars, 1, (INSTR(stars, 'out')-1))
		WHEN stars LIKE '%Not Rated Yet%'
			THEN 'Not rated yet'
		END AS avg_rating,
		
	CASE
		WHEN stars LIKE '%stars%'
			THEN SUBSTR(stars, INSTR(stars, 'ars')+3, 2)
		ELSE '0'
		END AS num_ratings
	
	
FROM audible_cleaned
```

<br>


| stars                        | avg_rating         | num_ratings |
|:----------------------------:|:------------------:|:-----------:|
| 5 out of 5 stars34 ratings   | 5   | 34          |
| 4.5 out of 5 stars41 ratings | 4.5 | 41          |
| 4.5 out of 5 stars38 ratings | 4.5  | 38          |

The code succesfully extracts the info we need. Now, lets update the main table so that these two new columns replace the now redundant column, _stars_:

<br>

```sql
--Creating two new columns for the audible_cleaned table

ALTER TABLE audible_cleaned
ADD COLUMN avg_rating TEXT;
ALTER TABLE audible_cleaned
ADD COLUMN num_ratings INTEGER;


--Adding data to the new column avg_rating

UPDATE audible_cleaned
SET avg_rating = (CASE
		WHEN stars LIKE '%stars%'
			THEN SUBSTR(stars, 1, (INSTR(stars, 'out')-1))
		WHEN stars LIKE '%Not Rated Yet%'
			THEN 'Not rated yet'
		END)
		
		
--Adding data to the new column num_ratings

UPDATE audible_cleaned
SET num_ratings = (CASE
		WHEN stars LIKE '%stars%'
			THEN SUBSTR(stars, INSTR(stars, 'ars')+3, 2)
		ELSE '0'
		END)

		
--Deleting the stars COLUMN

ALTER TABLE audible_cleaned
DROP COLUMN stars;

SELECT * FROM audible_cleaned
```
<br>

| name                                                                                                                                     | author          | narrator                                  | duration_mins | releasedate | language | price  | avg_rating         | num_ratings   |
|:----------------------------------------------------------------------------------------------------------------------------------------:|:---------------:|:-----------------------------------------:|:-------------:|:-----------:|:--------:|:------:|:------------------:|:-------------:|
| Geronimo Stilton #11 & #12                                                                                                               | GeronimoStilton | BillLobely                                | 140           | 2008-08-04  | English  | 468.00 | 5   | 34            |
| The Burning Maze                                                                                                                         | RickRiordan     | RobbieDaymond                             | 788           | 2018-05-01  | English  | 820.00 | 4.5 | 41            |
| The Deep End                                                                                                                             | JeffKinney      | DanRussell                                | 123           | 2020-11-06  | English  | 410.00 | 4.5 | 38            |
| Daughter of the Deep                                                                                                                     | RickRiordan     | SoneelaNankani                            | 676           | 2021-10-05  | English  | 615.00 | 4.5 | 12            |
| 14 Short Stories Bundle for Kids... | NayomiPhillips  | MonicaRachelle, JimD.Johnston, KatieOtten | 193           | 2019-01-22  | English  | 501.00 | Not rated yet      | 0 |

<br>

Everything looks good with the two new columns.

<br>

## Converting the _price_ column to :dollar: $USD :dollar: 

<br>

The last step in cleaning the data is the _price_ column. The audible database is from Audible-India, so prices are in Indian Rupees. Let's convert this column to US dollars. At the time of writing this, 1 IDR is equal to 0.012 USD. We'll use this amount to convert the column:

<br>

```SQL
--Converting price from IDR to USD. Also removing commas, casting as REAL (FLOAT), and rounding the result.

SELECT
	price,
	ROUND(CAST(REPLACE(price, ',', '') AS REAL) * 0.012, 2) AS price_usd

FROM
	audible_cleaned
```
<br>

| price    | price_usd |
|----------|-----------|
| 820.0    | 9.84      |
| 656.0    | 7.87      |
| 233.0    | 2.8       |
| 820.0    | 9.84      |
| 1,256.00 | 15.07     |

<br>

A problem that had to be solved was that I was getting incorrect results for values > 1000 in the price column. I noticed that, when the data was uploaded, it was mistakenly stored as a STRING data type, but even CASTING as REAL (this is the FLOAT equivalent in SQLite) I was getting incrrect results only for values > 1000. I noticed that these values all contained a comma ',' to separate 100s and 1000s. Doing some research, I learnt that SQLite treats commas kinda weird even when the data type is correctly set as REAL :cold_sweat: :poop:. No problem, as part of the query lets remove the comma, CAST it as REAL, AND ROUND the result to two decimals. As you can see in the above table, the results look good. Lets update the column in the main table:

<br>

```sql
--Updating the table with converted price
	
UPDATE audible_cleaned
SET price = 	ROUND(CAST(REPLACE(price, ',', '') AS REAL) * 0.012, 2)

ALTER TABLE audible_cleaned
RENAME COLUMN price TO price_usd
```

<br>

| name                       | author          | narrator       | duration_mins | releasedate | language | price_usd | avg_rating | num_ratings |
|----------------------------|-----------------|----------------|---------------|-------------|----------|-----------|------------|-------------|
| Geronimo Stilton #11 & #12 | GeronimoStilton | BillLobely     | 140           | 2008-08-04  | English  | 5.62      | 5          | 34          |
| The Burning Maze           | RickRiordan     | RobbieDaymond  | 788           | 2018-05-01  | English  | 9.84      | 4.5        | 41          |
| The Deep End               | JeffKinney      | DanRussell     | 123           | 2020-11-06  | English  | 4.92      | 4.5        | 38          |
| Daughter of the Deep       | RickRiordan     | SoneelaNankani | 676           | 2021-10-05  | English  | 7.38      | 4.5        | 12          |
| ...                        | ...             | ...            | ...           | ...         | ...      | ...       | ...        | ...         |

<br>

And that's the table cleaned! :cake: :confetti_ball: :tada: 

<br>

## Closing thoughts and Future Analysis

<br>

This project was a little long winded and in a real life scenario, not always 100% necessary. When working with a raw data source, it could be more beneficial to clean the data as it is needed rather than cleaning all of it, all at once in order to prevent doing unnecessary work. However, there are instances where such a thorough cleaning process is valid. For example, if I was passing this data onto a third party who wanted to use it for analysis or if this was company data that was regularly used. In these situations, it could be beneficial to have a completely clean data set. It would be important in these instances to communicate this to any future users. Generating a report, like this one, which details all steps taken to clean the data could be a very useful resource for any future users of this data.

<br>

Now that there is some clean data, it's ready for analysis. It could be cool to do some future analysis using Python instead of SQL. Some inspiration ideas:

* Top rated authors.
* Do authors with better ratings tend to have more books.
* Modelling to predict if a book is going to get good ratings.
