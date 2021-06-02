USE AccountOMS
GO
SELECT c.GUID_Case,m.GUID_MU, c.id AS rf_idCase
INTO #t
FROM t_Case c INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase
WHERE c.id IN(113183290,113183289,113183292)

SELECT DISTINCT f.FileNameHR
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
WHERE c.id IN(113183290,113183289,113183292)

BEGIN TRANSACTION
INSERT dbo.t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,
    DateHelpBegin, DateHelpEnd,DiagnosisCode,MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,
    TotalPrice, rf_idV004,rf_idDoctor,Comments,MUSurgery,IsNeedUsl
)
SELECT tt.rf_idCase,m.id,m.GUID_MU,m.rf_idMO,m.rf_idSubMO,m.rf_idDepartmentMO,m.rf_idV002,m.IsChildTariff,m.
    DateHelpBegin,m. DateHelpEnd,m.DiagnosisCode,0,0,0,m.Quantity,m.Price,m.
    TotalPrice,m. rf_idV004,m.rf_idDoctor,m.Comments,m.MUSurgery,m.IsNeedUsl
FROM RegisterCases.dbo.t_Case c INNER JOIN #t tt ON
		c.GUID_Case=tt.GUID_Case
					INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
        m.rf_idCase = c.id		
WHERE m.MUSurgery IS NOT NULL

commit
GO
DROP TABLE #t