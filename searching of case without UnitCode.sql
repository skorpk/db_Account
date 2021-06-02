USE AccountOMS
GO
SELECT c.id
INTO #tCase
FROM t_Case c
WHERE c.DateEnd>='20190101' AND NOT EXISTS(SELECT * FROM dbo.t_Case_UnitCode_V006 WHERE rf_idCase=c.id)

SELECT  f.CodeM,f.DateRegistration,COUNT(c.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN #tCase cc ON
            c.id=cc.id
WHERE f.DateRegistration<'20200214'
GROUP BY f.CodeM,f.DateRegistration		
GO
DROP TABLE #tCase