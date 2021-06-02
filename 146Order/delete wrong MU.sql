USE AccountOMS
GO
SELECT f.CodeM, c.id AS rf_idCase,c.GUID_Case,m.GUID_MU,m.id
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase  
					INNER JOIN RegisterCases.dbo.t_Case c1 ON
			c.GUID_Case=c1.GUID_Case
					INNER JOIN RegisterCases.dbo.t_Meduslugi m1 ON
			c1.id=m1.rf_idCase  
			AND m.id=m1.id
					INNER JOIN RegisterCases.dbo.t_RecordCaseBack rb ON
			c1.id=rb.rf_idCase
					INNER JOIN RegisterCases.dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack  					  
WHERE f.DateRegistration>'20160801' AND a.ReportYear=2016 AND a.ReportMonth>7 AND c.DateEnd>='20160801' /*AND f.CodeM='395301'*/ AND cb.TypePay=2
--GROUP BY f.CodeM, c.id ,c.GUID_Case,m.GUID_MU
--HAVING COUNT(*)>1

--SELECT * INTO tmp_CaseDentalMUError FROM #t

BEGIN TRANSACTION
DELETE FROM dbo.t_Meduslugi
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
		AND t.id=m.id
--WHERE ISNULL(m.Comments,'Œ“ ¿«')<>'Œ“ ¿«'  AND m.rf_idCase=61075991
SELECT @@ROWCOUNT

		   
COMMIT
GO
DROP TABLE #t