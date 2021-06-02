USE planDD
GO
---необходимо брать последнию запись
CREATE VIEW t_R02ENP
as
SELECT TOP 1 WITH TIES  p.ENP AS ENP2, p.SMO, pp.Sex,rp.Date_B,DATEDIFF(YEAR,pp.BirthDay,GETDATE()) AS Age
--INTO t_R02ENP
FROM t_R01File f1  INNER JOIN t_R01Persons pp ON
		f1.id=pp.rf_R01File
					INNER JOIN t_R01PersonPeriod rp ON
		pp.id=rp.rf_R01Persons                  
					INNER JOIN t_R02File f2 ON
		f1.id=f2.rf_R01File
					INNER JOIN t_R02Persons p ON
		f2.id=p.rf_R02File  
		AND pp.ZAP=p.ZAP
WHERE f1.[YEAR]=2018 AND p.Result=1 AND pp.[T_PR] ='O' AND f1.CreateDate<'20180827' --AND p.enp='3455040842000010'
ORDER BY ROW_NUMBER() OVER(PARTITION BY p.enp ORDER BY f1.CreateDate desc)
GO
CREATE VIEW t_R03ENP
as
SELECT DISTINCT p.ENP AS ENP3, stage,pr.Date_I
--INTO t_R03ENP
FROM t_R03File f INNER JOIN t_R03Persons p on
		f.id=p.rf_R03File
				INNER JOIN t_R03PersonPeriod pr ON
		p.id=pr.rf_R03Persons
WHERE f.[Year]=2018 AND Stage IN(1,2) AND f.CreateDate<'20180827'
go