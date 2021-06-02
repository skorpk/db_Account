--WITH cte
--AS(
--SELECT z.rf_idV002,COUNT(z.id) AS Col3,l.DS_OSN AS Col4
--FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.Table_LN l ON
--			z.rf_idV002=l.PROFIL
--			AND z.DS=l.DS_OSN
--WHERE z.kol>l.SROK1
--GROUP BY z.rf_idV002,l.DS_OSN
--)
--UPDATE l SET l.IsNeed=0
--FROM cte c INNER JOIN Table_LN l ON
--	c.rf_idV002=l.Profil
--	AND c.Col4=l.ds_osn
--WHERE Col3<6

SELECT z.rf_idV002,v2.name,z.DS,COUNT(z.id)
FROM dbo.T_ZAPROS_18_04_2018 z INNER JOIN dbo.Table_LN l ON
			z.rf_idV002=l.PROFIL
			AND z.DS=l.DS_OSN
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		   z.rf_idV002=v2.id
WHERE z.kol>l.SROK1 AND l.IsNeed=0
GROUP BY z.rf_idV002,v2.name,z.DS
