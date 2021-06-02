USE PeopleAttach
GO
BEGIN TRANSACTION
UPDATE c SET c.PID=p.id,c.ENP=p.enp
FROM dbo.CancerRegistr c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			c.Fam=p.FAM
			AND c.Im=p.IM
			AND c.DR = p.DR
			AND c.Ot = p.OT
WHERE c.[Year]=2018 AND c.Month=6
commit