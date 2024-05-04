use `stratascratch`;
show tables;

alter table twitch
rename twitch_sessions;

show full columns from twitch_sessions;

alter table twitch_sessions
modify session_start datetime,
modify session_end datetime;

/*
List the top 10 users who accumulated the most sessions where they had more streaming sessions than viewing.
Return the user_id, number of streaming sessions, and number of viewing sessions.
*/
with cte as (
	select
		user_id
		,sum(session_type='streamer') streamer
		,sum(session_type='viewer') viewer
	from twitch_sessions
	group by user_id
    )
select
	user_id
    ,streamer
    ,viewer
from cte
where streamer > viewer;

/*
Find users who are both a viewer and streamer.
*/
select
	user_id
from (
	select
		user_id
		,sum(session_type='viewer') viewer
		,sum(session_type='streamer') streamer
	from twitch_sessions
	group by user_id) t
where viewer > 0 and streamer > 0;

/*
Calculate the average session duration for each session type?
results: s: 411, v: 986 <- unable to achieve this result
*/
select * from twitch_sessions;

select
	session_type
    ,avg(session_end - session_start) as duration
from twitch_sessions
group by 1;

-- solution provided by the platform
SELECT session_type,
             avg(session_end -session_start) AS duration
FROM twitch_sessions
GROUP BY session_type;

/*
From users who had their first session as a viewer, how many streamer sessions have they had?
Return the user id and number of sessions in descending order.
In case there are users with the same number of sessions, order them by ascending user id.
*/
select * from twitch_sessions
-- where session_type = 'streamer'
order by user_id;

select
	user_id
    ,count(*) n_sessions
from twitch_sessions
where user_id in (
	select
		user_id
	from (
		select
			user_id
			,session_type
			,rank() over (partition by user_id order by session_start) ranking
		from twitch_sessions
		) t
	where ranking = 1 and session_type = 'viewer'
    )
    and session_type = 'streamer'
group by 1
order by 2 desc, 1;

