/* Basic EDA of the data */
SELECT *
FROM popular_movies;

SELECT *
FROM movie_genre;

SELECT *
FROM movie_keywords;

SELECT *
FROM top_billed_cast;

/* Querying the Genres that is the most popular */
SELECT MAX(vote_average), genre_names,movie_title
FROM popular_movies m
INNER JOIN movie_genres g
ON m.title = g.movie_title 
GROUP BY genre_names,movie_title
ORDER BY MAX(vote_average) DESC;

/* Updating the genre_name of one Reacher Second Season Prime Premier*/
UPDATE movie_genres
SET genre_names =  'Action, Crime, Drama'
WHERE movie_title = 'Reacher Second Season Prime Premier';

/* Querying the highest rated movie by the users */
SELECT userId, MAX(rating),title,release_date,genre_names
FROM ratings r
INNER JOIN popular_movies m 
ON
r.movieID = m.id
INNER JOIN movie_genres g 
ON 
m.title = g.movie_title
GROUP BY userId,title,release_date,genre_names
ORDER BY MAX(rating) DESC;

/*Any Actor who's name is Anthony*/
SELECT 
  Title,
  `Cast Member`
FROM 
  top_billed_cast
WHERE 
  `Cast Member` LIKE 'Anthony%';
  
/* The Most voted movie in the Action,Horror, Drama genres*/
SELECT movie_title,
       genre_names,
       vote_average,
       DENSE_RANK() OVER (PARTITION BY genre_names ORDER BY vote_average DESC) AS ranking
FROM popular_movies m
INNER JOIN movie_genres g ON m.title = g.movie_title
WHERE genre_names IN ('Horror', 'Drama','Action');

/* Keywords associated with the most vote */
SELECT COUNT(*)
FROM ratings;

/* Querying the users who rated movie_id 31 */
SELECT id,title,userId
FROM ratings r
INNER JOIN popular_movies m
ON r.movieID = m.id
WHERE movie_id = 31;

/* Collaborative filtering using Self Join to find out the highly rated movies similar to user id 1. Used to calculate the similarity using Pearson Correlation Coefficient*/
CREATE VIEW UserSimilarMovies AS
WITH UserSimilarity AS (
    SELECT 
        r1.userId AS user1, 
        r2.userId AS user2, 
        AVG(r1.rating * r2.rating) / (SQRT(AVG(r1.rating * r1.rating)) * SQRT(AVG(r2.rating * r2.rating))) AS similarity
    FROM ratings r1
    JOIN ratings r2 ON r1.movieId = r2.movieId AND r1.userId <> r2.userId
    WHERE r1.userId = 1
    GROUP BY r1.userId, r2.userId
)
SELECT r.movieId, m.title, AVG(r.rating) AS avg_rating,us.user2 AS similar_user
FROM ratings r
JOIN UserSimilarity us ON r.userId = us.user2
JOIN popular_movies m ON r.movieId = m.id
GROUP BY r.movieId, m.title,similar_user
HAVING AVG(us.similarity) > (SELECT AVG(similarity) FROM UserSimilarity)
ORDER BY avg_rating DESC;

/* Content based filtering for UserID 1.*/
CREATE VIEW ContentBasedMovies AS
SELECT 
id,
title,
popularity,
vote_average
FROM popular_movies m
INNER JOIN ratings r ON m.id = r.movieID;

-- Recommend products based on rating and age
SELECT *
FROM popular_movies
ORDER BY (vote_average / POWER(DATEDIFF(NOW(), release_date), 2)) DESC;







