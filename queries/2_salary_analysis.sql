-- 1. Return the top 20% of teams in terms of average annual spending

WITH ts AS
		(
		SELECT teamID, yearID, SUM(salary) AS total_spends
		FROM salaries
		GROUP BY teamID, yearID
		ORDER BY teamID, yearID
		),
        
	sp AS
		(
		SELECT teamID, AVG(total_spends) AS avg_spend,
			NTILE(5) OVER(ORDER BY AVG(total_spends) DESC) spend_pct
		FROM ts
		GROUP BY teamID
		)
 
 SELECT teamID, ROUND(avg_spend / 1000000, 2) avg_spend_mil
 FROM sp
 WHERE spend_pct = 1;

-- 2. For each team, show the cumulative sum of spending over the years

WITH ts AS
		(
		SELECT teamID, yearID, SUM(salary) AS total_sal
		FROM salaries
		GROUP BY teamID, yearID
		ORDER BY teamID, yearID
		)
        
SELECT *,
	ROUND( SUM(total_sal) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000000, 2) AS cum_sum_in_mil
FROM ts;

-- 3. Return the first year that each team's cumulative spending surpassed 1 billion

WITH ts AS
		(
		SELECT teamID, yearID, SUM(salary) AS total_sal
		FROM salaries
		GROUP BY teamID, yearID
		ORDER BY teamID, yearID
		),
        
     cum_spend AS   
		(
		SELECT *,
			ROUND( SUM(total_sal) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000000, 2) AS cum_sum_in_mil
		FROM ts
        ),
        
        rn AS
		(
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY cum_sum_in_mil ASC) AS rn
		FROM cum_spend
		WHERE cum_sum_in_mil >= 1
		)

SELECT teamID, yearID, cum_sum_in_mil
FROM rn
WHERE rn = 1;
