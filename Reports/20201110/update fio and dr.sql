USE PeopleAttach
GO
--ALTER TABLE dbo.t_CovidRegister20201026 DROP COLUMN FIO_My
--GO
--ALTER TABLE dbo.t_CovidRegister20201026 ADD Fam_My varchar(40)
WITH cteFIO
AS(
SELECT Id_Source,CONVERT(DATE,DR_Source,104) AS DR,u.FIO_Source,
	PARSENAME(REPLACE(REPLACE(u.FIO_Source,'  ',' '), ' ', '.'), 2) AS Im,
	PARSENAME(REPLACE(REPLACE(u.FIO_Source,'  ',' '), ' ', '.'), 1) AS Ot,
	PARSENAME(REPLACE(REPLACE(u.FIO_Source,'  ',' '), ' ', '.'), 3) AS Fam
FROM dbo.t_CovidRegister20201026 u
WHERE u.Im_My IS null
)
UPDATE r SET r.Fam_My=c.Fam,r.Im_My=c.Im,r.Ot_My=c.Ot, r.DR_My=c.DR
FROM cteFIO c INNER JOIN dbo.t_CovidRegister20201026 r ON
		c.Id_Source=r.Id_Source 
WHERE c.Ot IS NOT NULL 