-- 1. For each player, calculate their age at their first (debut) game, their last game,
-- and their career length (all in years). Sort from longest career to shortest career.

WITH bd AS
		(
		SELECT nameGiven,
			CAST(CONCAT(birthYear,"-", birthMonth,"-", birthDay) AS DATE) AS birthdate,
			debut, finalGame
		FROM players
        	WHERE birthday IS NOT NULL
		)
        
SELECT *,
	TIMESTAMPDIFF(YEAR, birthdate, debut) AS age_debut,
	TIMESTAMPDIFF(YEAR, birthdate, finalGame) AS age_final,
    	TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_length
FROM bd
ORDER BY career_length DESC;

-- 2. What team did each player play on for their starting and ending years?

SELECT  p.playerID, p.debut,
	s1.yearID, s1.teamID, 
        p.finalGame,
        s2.yearID, s2.teamID
FROM players AS p
INNER JOIN salaries AS s1
	ON p.playerID = s1.playerID
    AND YEAR(p.debut) = s1.yearID
INNER JOIN salaries AS s2
	ON p.playerID = s2.playerID
    AND YEAR(p.finalGame) = s2.yearID;

-- 3. How many players started and ended on the same team and also played for over a decade?

SELECT  COUNT(p.playerID) AS total_players
FROM players AS p
INNER JOIN salaries AS s1
	ON p.playerID = s1.playerID
    AND YEAR(p.debut) = s1.yearID
INNER JOIN salaries AS s2
	ON p.playerID = s2.playerID
    AND YEAR(p.finalGame) = s2.yearID
WHERE s1.teamID = s2.teamID
AND s2.yearID - s1.yearID >= 10;
