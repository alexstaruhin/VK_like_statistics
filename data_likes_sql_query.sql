##### data_likes SQL Project  

#Создаем вспомогательную таблицу

create table data_csv(
	publication_date TIMESTAMPTZ,
	like_count int
);

#С помощью SQL Shell заполняем таблицу собранными данными

\COPY data_csv FROM 'D:\python\VK_like_statistics\src\data.csv' DELIMITER ',' CSV HEADER;

#Создаем основную таблицу

create table likes(
	likes_id BIGSERIAL PRIMARY KEY,
	publication_date TIMESTAMPTZ,
	like_count int
);

#Копируем данные из вспомогательной таблицы

INSERT INTO likes (publication_date, like_count) SELECT publication_date, like_count FROM data_csv;

#Удаляем вспомогательную таблицу

drop table data_csv;

#Создаем и заполняем столбец - временной промежуток между постами

ALTER TABLE likes
ADD COLUMN interval_between_posts interval;

WITH cte AS (
  SELECT
	likes_id,
    publication_date,
    LAG(publication_date) OVER (ORDER BY publication_date DESC) AS prev_timestamp
  FROM likes
)
UPDATE likes AS ta
SET interval_between_posts = cte.prev_timestamp - ta.publication_date
FROM cte
WHERE ta.likes_id = cte.likes_id;

#Запрос на поиск минимального промежутка между публикациями и максимального

SELECT MIN(interval_between_posts) AS min_interval, MAX(interval_between_posts) AS max_interval
FROM likes;

#Запрос на анализ влияния времени суток публикации на количество лайков

SELECT 'Утро' AS times_of_day, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(HOUR FROM publication_date) BETWEEN 0 AND 5
UNION ALL
SELECT 'День' AS times_of_day, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(HOUR FROM publication_date) BETWEEN 6 AND 11
UNION ALL
SELECT 'Вечер' AS times_of_day, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(HOUR FROM publication_date) BETWEEN 12 AND 17
UNION ALL
SELECT 'Ночь' AS times_of_day, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(HOUR FROM publication_date) BETWEEN 18 AND 23;

#Запрос на анализ влияния дня недели публикации на количество лайков

SELECT 'Понедельник' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 1
UNION ALL
SELECT 'Вторник' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 2
UNION ALL
SELECT 'Среда' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 3
UNION ALL
SELECT 'Четверг' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 4
UNION ALL
SELECT 'Пятница' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 5
UNION ALL
SELECT 'Суббота' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 6
UNION ALL
SELECT 'Воскресенье' AS times_of_week, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DOW FROM publication_date) = 0;

#Запрос на анализ влияния промежутка между постами публикации на количество лайков

SELECT 'До 1 дня' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) < 1
UNION ALL
SELECT 'От 1 до 2 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 1 AND EXTRACT(DAY FROM interval_between_posts) < 2
UNION ALL
SELECT 'От 2 до 3 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 2 AND EXTRACT(DAY FROM interval_between_posts) < 3
UNION ALL
SELECT 'От 3 до 4 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 3 AND EXTRACT(DAY FROM interval_between_posts) < 4
UNION ALL
SELECT 'От 4 до 5 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 4 AND EXTRACT(DAY FROM interval_between_posts) < 5
UNION ALL
SELECT 'От 5 до 6 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 5 AND EXTRACT(DAY FROM interval_between_posts) < 6
UNION ALL
SELECT 'От 6 до 7 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 6 AND EXTRACT(DAY FROM interval_between_posts) < 7
UNION ALL
SELECT 'От 7 до 8 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) >= 7 AND EXTRACT(DAY FROM interval_between_posts) < 8
UNION ALL
SELECT 'От 8 до 9 дней' AS interval_posts, COUNT(like_count) AS number_of_posts, SUM(like_count) AS amount_of_likes, ROUND(AVG(like_count)) AS average_likes, MIN(like_count) AS min_post_likes, MAX(like_count) AS max_post_likes
FROM likes
WHERE EXTRACT(DAY FROM interval_between_posts) > 8;