SELECT f.CodeM,c.id AS rf_idCase,c.GUID_Case,c.DateEnd,c.rf_idV006,m.MES,mm.MU,mm.MUSurgery,a.Account
--INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase           							
					left JOIN dbo.t_MES m ON
			c.id=m.rf_idCase           					
WHERE  f.DateRegistration>='20190701' AND f.DateRegistration<=GETDATE() AND a.ReportYear>=2019 
	AND NOT EXISTS(SELECT 1 FROM dbo.t_Case_UnitCode_V006 u WHERE u.rf_idCase=c.id)
	AND c.id IN (104612950,108138962,108447486,108377745,105318136,109971267,110141806,105665798,109971379,109563978,105097468,107351280)	
ORDER BY rf_idCase


--SELECT tt.rf_idCase,m.MUCode
--INTO #tt2
--FROM RegisterCases.dbo.t_Case c INNER JOIN #t tt ON
--			c.GUID_Case=tt.GUID_Case
--					INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
--             c.id=m.rf_idCase

--BEGIN TRANSACTION
--UPDATE m SET m.MUSurgery=t.MUCode
--FROM dbo.t_Meduslugi m INNER JOIN #tt2 t ON
--			m.rf_idCase=t.rf_idCase

--commit
GO
--DROP TABLE #t

