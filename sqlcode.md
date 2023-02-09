```sql
--Number of games played
SELECT 
  COUNT(date)
FROM `football-across-the-ages.football.results`
```

44,353


```sql
--Number of unique teams 
WITH home AS
(
    SELECT DISTINCT(home_team) AS home_teams
    FROM `football-across-the-ages.football.results`
),

away AS
(
    SELECT DISTINCT(away_team) AS away_teams
    FROM `football-across-the-ages.football.results`
),

homeaway AS
(
  SELECT * FROM home
  UNION DISTINCT
  SELECT * FROM away
)

SELECT COUNT(*)
FROM homeaway
```
316

```sql
--Number of unique tournaments
SELECT  
  COUNT(DISTINCT tournament)
FROM `football-across-the-ages.football.results`
```

141

```sql
--Average goals scored per game
SELECT 
  ROUND(AVG(home_score + away_score), 2) AS avg_goals_per_game
 FROM `football-across-the-ages.football.results`
 ```
 2.92
 
 
 ```sql
 --Average goals scored per scorer across all games
 SELECT 
  ROUND(AVG(goals_scored), 2) AS avg_goals_per_scorer
FROM
(SELECT
  scorer,
  COUNT(date) AS goals_scored
FROM `football-across-the-ages.football.goalscorers`
WHERE scorer IS NOT NULL
GROUP BY scorer
ORDER BY COUNT(date) DESC)
```
3.07


```sql
--Percentage of games that ended in a penalty shootout
WITH count_of_draws AS
(SELECT
    COUNT(date)
  FROM
    `football-across-the-ages.football.results`
  WHERE 
    home_score = away_score),

count_of_games AS
  (SELECT
    COUNT(date)
  FROM `football-across-the-ages.football.results`)


SELECT 
  ROUND((SELECT * FROM count_of_draws)/(SELECT * FROM count_of_games)
  * 100, 2) AS perc_games_shootout

FROM `football-across-the-ages.football.results`
```
23.02%
 
```sql
--Better code for percentage of games that ended in a penalty shootout
WITH counted_games AS
(SELECT
    COUNTIF(home_score = away_score) AS count_draw,
   COUNT(date) AS count_all
  FROM
    `football-across-the-ages.football.results`
)

SELECT 
  ROUND(count_draw / count_all
  * 100, 2) AS perc_games_shootout

FROM
  counted_games
```
 
 
```sql
--Countries with the most number of touraments
SELECT 
  country,
  COUNT(DISTINCT tournament) AS distinct_tournaments 
FROM `football-across-the-ages.football.results`
GROUP BY country
ORDER BY distinct_tournaments DESC
LIMIT 10
```

| country       | distinct_tournaments |
|---------------|----------------------|
| Argentina     | 16                   |
| United States | 14                   |
| Uruguay       | 13                   |
| England       | 12                   |
| France        | 12                   |
| South Africa  | 12                   |
| Brazil        | 12                   |
| Mexico        | 10                   |
| India         | 10                   |
| Chile         | 10                   |

```sql
--Distribution of which minute goals are scored in.
SELECT 
  CAST(minute AS numeric) AS min_of_game,
  COUNT(CAST(minute AS numeric)) AS num_of_goals

FROM `football-across-the-ages.football.goalscorers`

/* The minute column is a string Type in the table. CASTing the column as numeric fixes this except for one value whose result is the letters 'NA'. I am assuming that when this value is present it is an error and possibly stands for 'N/A'. The below line of code filters this value out. Once grouped, there is also a suspicious value for the 90th minute as it is much higher than surrounding values. I assumed that values have been rounded somehow as the 90th minute is the last minute of regular full time in football. I also filtered this value out. */

WHERE
  minute <> 'NA'
  AND minute <> '90'
GROUP BY minute
ORDER BY min_of_game DESC
```

