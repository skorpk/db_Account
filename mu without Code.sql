USE AccountOMS
GO
/*
SELECT f.CodeM,a.Account,f.DateRegistration,c.GUID_Case,m.GUID_MU,m,MU,m.MUSurgery
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient 
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN RegisterCases.dbo.t_Case c on
WHERE f.DateRegistration>'20160901' AND m.MU='0.0.0' AND m.MUSurgery IS null --c.id=61752582
*/
SELECT f.CodeM, c.id AS rf_idCase,c.GUID_Case,m.GUID_MU
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					LEFT JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase    
WHERE f.DateRegistration>'20160801' AND m.MU='0.0.0' AND m.MUSurgery IS null --c.id=61752582

SELECT c.GUID_Case,m.GUID_MU,m.rf_idCase,m.MUCode,m.MUSurgery
INTO #t1
FROM #t t INNER JOIN RegisterCases.dbo.t_Case c ON
			t.GUID_Case = c.GUID_Case
					INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
			c.id=m.rf_idCase    
			AND t.GUID_MU=m.GUID_MU
					INNER JOIN RegisterCases.dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN RegisterCases.dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack                  
WHERE c.DateEnd>='20160801' AND cb.TypePay=1

SELECT DISTINCT t1.rf_idCase,sm.MUGroupCode,sm.MUUnGroupCode,sm.MUCode
FROM #t1 t inner JOIN #t t1 ON
		t.GUID_Case=t1.GUID_Case
		AND t.GUID_MU=t1.GUID_MU
			INNER JOIN dbo.t_Meduslugi m ON
		t1.rf_idCase=m.rf_idCase
		AND t1.GUID_MU=m.GUID_MU	
			INNER JOIN dbo.vw_sprMU sm ON
		t.MUCode=sm.MU
--WHERE m.rf_idCase=60737300
BEGIN TRANSACTION
UPDATE m SET m.MUGroupCode=sm.MUGroupCode, m.MUUnGroupCode=sm.MUUnGroupCode,m.MUCode=sm.MUCode
FROM #t1 t inner JOIN #t t1 ON
		t.GUID_Case=t1.GUID_Case
		AND t.GUID_MU=t1.GUID_MU
			INNER JOIN dbo.t_Meduslugi m ON
		t1.rf_idCase=m.rf_idCase
		AND t1.GUID_MU=m.GUID_MU	
			INNER JOIN dbo.vw_sprMU sm ON
		t.MUCode=sm.MU
commit	         
go
DROP TABLE #t
DROP TABLE #t1
