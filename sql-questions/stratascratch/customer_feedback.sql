use stratascratch;

select * from customer_feedback;

-- Capital One's marketing team is working on a project to analyze customer feedback from their feedback surveys.
-- The team sorted the words from the feedback into three different categories;
-- •	short_comments
-- •	mid_length_comments
-- •	long_comments
-- The team wants to find comments that are not short and that come from social media.
-- The output should include 'feedback_id,' 'feedback_text,' 'source_channel,' and a calculated category.
select
	feedback_id
    ,feedback_text
    ,source_channel
from customer_feedback
where
	source_channel = 'social_media'
	and comment_category <> 'short_comments'; 