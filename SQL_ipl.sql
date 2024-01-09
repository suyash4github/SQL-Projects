create database ipl;
use ipl

drop table if exists #ipls

create table #ipls
(
	id float,
	inning float,
	overr float,
	ball float,
	batsman nvarchar(255),
	non_striker nvarchar(255),
	bowler nvarchar(255),
	batsman_runs float,
	extra_runs float,
	total_runs float,
	non_boundry float,
	is_wicket float,
	dismissal_kind nvarchar(255),
	player_dismissed nvarchar(255),
	fielder nvarchar(255),
	extras_type nvarchar(255),
	batting_team nvarchar(255),
	bowling_team nvarchar(255)

)

insert into #ipls
select * from ipl1$
union
select * from ipl2$
union
select * from ipl3$
union
select * from ipl4$

select count(*) from #ipls

select * from ['IPL Matches 2008-2020$']

-- matches per Season.

select  year(date) as season_year,count(id) matches_per_season from ['IPL Matches 2008-2020$']
group by year(date)
order by 1;

--most player of match
select * from 
(select *,rank() over(order by cnt desc) as rnk from
(select player_of_match,count(id) as cnt from ['IPL Matches 2008-2020$']
group by player_of_match)b) c
where rnk=1;

--most player of match/season

select * from 
(select *,rank() over( partition by season_year order by cnt desc) rnk from 
(select player_of_match,year(date) as season_year,count(id) as cnt from ['IPL Matches 2008-2020$']

group by player_of_match,year(date)) t) y
where rnk=1;

-- most wins by any team

select winner,count(id) from ['IPL Matches 2008-2020$']
group by winner

-- most runs by any batsman
select * from #ipls

select top 10 batsman, sum(batsman_runs) runs_by_btsman from #ipls
group by batsman
order by sum(batsman_runs) desc

--total runs scored in ipl

select sum(batsman_runs) from #ipls

-- most 6's by any batsman

select a.batsman, count(batsman_runs) no_of_sixes from
(select batsman, batsman_runs from #ipls
where batsman_runs=6)a
group by batsman
order by count(batsman_runs) desc

-- 3000 runs club, max strike rate

select batsman, runs, strike_rate from
(select batsman, (runs*1.0*100/balls) strike_rate,runs  from 
(select batsman, sum(batsman_runs) runs , count(batsman) balls from #ipls group by batsman) a) b
where runs > 3000
order by strike_rate desc




