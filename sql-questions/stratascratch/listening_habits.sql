use stratascratch;

select *
from listening_habits;

-- You're tasked with analyzing a Spotify-like dataset that captures user listening habits.
-- For each user, calculate the total listening time and the count of unique songs they've listened to.
-- In the database duration values are displayed in seconds. Round the total listening duration to the nearest whole minute.
-- The output should contain three columns: 'user_id', 'total_listen_duration', and 'unique_song_count'.
select
	user_id
    ,round(sum(listen_duration)/60) total_listen_duration
    ,count(distinct song_id) unique_song_count
from listening_habits
group by user_id
order by 1;