```sql
--Number of games played
SELECT 
  COUNT(date)
FROM `football-across-the-ages.football.results`
```

44,353



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

316


--Number of unique tournaments
SELECT  
  COUNT(DISTINCT tournament)
FROM `football-across-the-ages.football.results`

141


--Countries with the most number of touraments
SELECT 
  country,
  COUNT(DISTINCT tournament) AS distinct_tournaments 
FROM `football-across-the-ages.football.results`
GROUP BY country
ORDER BY distinct_tournaments DESC
LIMIT 10

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


```
