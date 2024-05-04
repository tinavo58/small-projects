use stratascratch;

show tables;

/*
You are analyzing a social network dataset at Google. Your task is to find mutual friends between two users, Karl and Hans.
There is only one user named Karl and one named Hans in the dataset.
The output should contain 'user_id' and 'user_name' columns.
*/
select * from users;
select * from friends;
with karl as (
	select
		user_id
        ,friend_id
	from friends
    where user_id = (select user_id from users where user_name = 'karl')
    ),
    hans as (
    select
		user_id
        ,friend_id
	from friends
    where user_id = (select user_id from users where user_name = 'hans')
    )
select
	k.friend_id
    ,user_name
from karl k
left join users u on k.friend_id = u.user_id
where k.friend_id in (select friend_id from hans);


/*
You have access to Facebook's database which includes several tables relevant to user interactions.
For this task, you are particularly interested in tables that store data about user posts, friendships, and likes.
Calculate the total number of likes made on friend posts on Friday.
The output should contain two different columns 'likes' and 'date'.
*/
select * from likes;
select * from user_post;
select * from friendships;

select
	u.user_name user_post
    ,l.post_id
	,dayofweek(str_to_date(date_liked, '%d/%m/%Y')) dow
    ,l.user_name user_like_post
from likes l
join user_post u using (post_id)
where dayofweek(str_to_date(date_liked, '%d/%m/%Y')) = 6;

with sub as (
	select
		post_id
		,u.user_name
		,f.user_name2
	from user_post u
	left join friendships f on user_name = user_name1
	where user_name1 <> user_name2
	)
select
	str_to_date(date_liked, '%d/%m/%Y') date_liked
	,count(*)
from likes l
left join sub s on s.post_id = l.post_id
and s.user_name2 = l.user_name
where dayofweek(str_to_date(date_liked, '%d/%m/%Y')) = 6
group by 1     ;