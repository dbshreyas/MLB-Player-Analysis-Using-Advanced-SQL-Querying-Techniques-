-- 1. Which players have the same birthday?

-- Method-1
WITH birthdate AS
		(
		SELECT *,
			CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay) AS DATE) AS birthdate
		FROM players
		)

SELECT a.nameGiven, a.birthdate,
	b.nameGiven, b.birthdate
FROM birthdate AS a
INNER JOIN birthdate AS b
ON a.birthdate = b.birthdate
AND a.nameGiven < b.nameGiven;

-- Method-2 using GROUP_CONCAT function

WITH bn AS
		(
		SELECT nameGiven,
			CAST(CONCAT(birthYear, "-", birthMonth, "-", birthDay) AS DATE) AS birthdate
		FROM players
		)
        
SELECT birthdate, GROUP_CONCAT(nameGiven SEPARATOR ", ") AS player_names
FROM bn
WHERE birthdate IS NOT NULL
GROUP BY birthdate
ORDER BY birthdate DESC;

-- 2. Create a summary table that shows for each team, what percent of players bat right, left and both.

SELECT s.teamID,
	ROUND( SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) *100, 2) AS bats_right,
	ROUND( SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) *100, 2) AS bats_left,
	ROUND( SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END)  / COUNT(s.playerID) *100, 2) AS bats_both
FROM salaries AS s
LEFT JOIN players AS p
ON s.playerId = p.playerID
WHERE p.bats IS NOT NULL
GROUP BY teamID;

-- 3. How have average height and weight at debut game 
--    changed over the years, and what's the decade-over-decade difference?
        
WITH hw AS
		(
		SELECT yearID, AVG(height) AS avg_height,
					   LAG(AVG(height)) OVER(ORDER BY yearID ASC) AS prev_height,
					   AVG(weight) AS avg_weight,
					   LAG(AVG(weight)) OVER(ORDER BY yearID ASC) AS prev_weight
		FROM salaries AS s
		LEFT JOIN players AS p
		ON s.playerID = p.playerID
		GROUP BY yearID
		)
        
SELECT yearID, 
	   avg_height, prev_height, prev_height - avg_height AS change_in_height,
       avg_weight, prev_weight, prev_weight - avg_weight AS change_in_weight
FROM hw
