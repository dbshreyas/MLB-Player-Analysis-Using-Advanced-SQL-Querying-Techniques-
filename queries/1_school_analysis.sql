-- 1. In each decade, how many schools were there that produced MLB players?

WITH decade AS
			(
			SELECT *,
				CONCAT(
					   FLOOR((yearID -1 )/ 10 ) * 10 + 1,
                       " - ",
                       (FLOOR( (yearID-1) / 10) * 10)+10
                       ) AS decade
			FROM schools
			)

SELECT decade, 
	   COUNT(DISTINCT schoolID) AS no_of_players
FROM decade
GROUP BY decade;


-- 2. What are the names of the top 5 schools that produced the most players?

WITH tp AS
		(
		SELECT schoolId, 
			   COUNT(DISTINCT playerID) AS total_players
		FROM schools
		GROUP BY schoolId
		ORDER BY total_players DESC
		LIMIT 5
		)
        
SELECT sd.name_full, tp.total_players
FROM tp
INNER JOIN school_details AS sd
ON tp.schoolId = sd.schoolid;

-- 3. For each decade, what were the names of the top 3 schools that produced the most players?

WITH decade AS
			(
			SELECT *,
				CONCAT(
					   FLOOR((yearID -1 )/ 10 ) * 10 + 1,
                       " - ",
                       (FLOOR( (yearID-1) / 10) * 10)+10
                       ) AS decade
			FROM schools
			),

total_players AS
			(
			SELECT decade, schoolID, 
				COUNT(DISTINCT playerID) AS total_players,
				DENSE_RANK() OVER(PARTITION BY decade ORDER BY COUNT(DISTINCT playerID) DESC) AS drank
			FROM decade
			GROUP BY decade, schoolID
			)

SELECT tp.decade, sd.name_full, total_players, drank
FROM total_players AS tp
INNER JOIN school_details AS sd
ON tp.schoolID = sd.schoolID
WHERE drank <= 3
ORDER BY decade, drank, name_full;
