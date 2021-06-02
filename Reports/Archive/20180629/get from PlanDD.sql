USE planDD
GO
SELECT DISTINCT p.ENP, stage,pr.Date_I,[METHOD], f.SMO 
FROM t_R03File f INNER JOIN t_R03Persons p on
		f.id=p.rf_R03File
				INNER JOIN t_R03PersonPeriod pr ON
		p.id=pr.rf_R03Persons
WHERE f.[Year]=2018 AND Stage =1 AND f.createdate<'20180714'