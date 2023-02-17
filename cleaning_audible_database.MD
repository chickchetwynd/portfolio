# Cleaning an Audible database.

Raw data is available [here](https://www.kaggle.com/datasets/snehangsude/audible-dataset?select=audible_uncleaned.csv)

The purpose of this project is to clean a dataset ready for analysis using SQL. The data was downloaded as a CSV file and then uploaded to Google's Big Queary where I will then use SQL quearies to format the table.

<br>

The table contains data from a web scraping project fron Audible India. It contains 87,489 rows and 8 columns. Lets see a table extract:

```sql
SELECT  
  *
FROM `audible-378119.audible.books`

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
     `audible-378119.audible.books`)) AS total_rows,


  (SELECT
    COUNT(1)
  FROM
  (SELECT DISTINCT name
  FROM
    `audible-378119.audible.books`)) AS unique_rows,

    ((SELECT COUNT(1)
    FROM
    (SELECT name
    FROM
    `audible-378119.audible.books`))
     
     -
     
    (SELECT
    COUNT(1)
    FROM
    (SELECT DISTINCT name
    FROM
    `audible-378119.audible.books`))) AS num_duplicate_rows
```

| total_rows | unique_rows | num_duplicate_rows |
|------------|-------------|--------------------|
| 87489      | 82767       | 4722               |


<br>

Removing duplicate rows




