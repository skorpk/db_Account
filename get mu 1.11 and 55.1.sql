USE AccountOMS
GO
WITH cteMU
AS
(
SELECT c.id,m.MU,f.id AS rf_idFile
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase    
WHERE m.[MUGroupCode] IN(55,1) AND f.DateRegistration>'20160801' AND a.ReportYear=2016 AND a.ReportMonth>7 AND c.DateEnd>'20160801'
) 
SELECT *
FROM cteMU m INNER JOIN cteMU m1 ON
		m.id=m1.id
WHERE m.MU<>m1.MU