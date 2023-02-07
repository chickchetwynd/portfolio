# :soccer:Football Across The Ages:soccer:
<br/><br/>

Football (soccer) isn't one of the most common team sports in the USA. Globally however, due to it's accesibilty and simplicity, the sport has mass appeal and is pervasive in the culture and even identity of many countres. With an estimated [250 million](https://en.wikipedia.org/wiki/Association_football) amateur players globally and a cumilative viewership of 5.4 billion people at the recent 2022 Qatar World Cup, football's popularity dwarves all other sports.

[This kaggle dataset](https://www.kaggle.com/datasets/martj42/international-football-results-from-1872-to-2017?select=goalscorers.csv) contains international football match results going back to 1872. It lists games played, along with goal scorers, across many different international tournaments. It's a great tool for finding global trends given football's prevailling international popularity.


In this project, my goal is to use this dataset to demonstrate some basic SQL skills by addressing the following:


* Conduct some basic exploratory analaysis of the data and vizualise the reults.
* What parts of the world are most succesful at football?
* Who are the top goal scorers of all time?
* When a team hosts a tournament, are they more succesful than when they compete in foreign-hosted tournaments?



<br/><br/>
## The data...


<img width="734" alt="Screen Shot 2023-02-07 at 2 18 37 PM" src="https://user-images.githubusercontent.com/121225842/217379634-39179c7d-761a-4a48-b445-2c557a145b1d.png">

The data is split across three tables. Notice how team names are listed. In the *results* table, an example of a team is *Italy*. *Italy* can appear in both the *home_team*, *away_team*, or *country* columns. This can make the data a little tricky to work with as the same variable is listed in multiple columns, but as we shall see later this can be worked around in SQL.

## Some broad analysis

The data was uploaded to Google's Big Query platform where queries were run. All queries fir this section can be found [here](https://github.com/chickchetwynd/football_across_the_ages/blob/main/sqlcode.md)


| Total numbers of games played | 44,353 |
|-------------------------------|--------|
| Number of teams               | 316    |
| Number of tournaments         | 141    |

