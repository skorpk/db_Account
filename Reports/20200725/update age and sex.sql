USE AccountOMS
GO
--ALTER TABLE dbo.DNPersons202007 ADD Sex AS (CASE WHEN sex_ENP=1 THEN 'Ì' ELSE 'Æ' END)
--ALTER TABLE dbo.T_inform202007 ADD Sex TINYINT

--ALTER TABLE dbo.T_inform202007 ADD Age SMALLINT
go
BEGIN TRANSACTION
UPDATE t SET t.age= DATEDIFF(YEAR,p.DR,GETDATE()), t.sex=p.W
FROM dbo.T_inform202007 t INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			t.ENP=p.ENP

UPDATE t SET t.age= DATEDIFF(YEAR,p.DR,GETDATE()), t.sex=p.W
FROM dbo.T_inform202007 t INNER JOIN PolicyRegister.dbo.HISTENP h ON
			t.ENP=h.ENP
							INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			h.pid=p.id
COMMIT
SELECT * FROM dbo.T_inform202007 WHERE sex IS NULL OR age IS null
