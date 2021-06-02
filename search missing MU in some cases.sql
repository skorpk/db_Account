USE AccountOMS
GO

SELECT f.CodeM, c.id AS rf_idCase,c.GUID_Case--,m.GUID_MU
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
			--		LEFT JOIN dbo.t_Meduslugi m ON
			--c.id=m.rf_idCase    
WHERE f.DateRegistration>'20160801' AND a.ReportYear=2016 AND a.ReportMonth>7 AND c.DateEnd>='20160801' 
		AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id)

SELECT c.GUID_Case,m.GUID_MU,m.rf_idCase
INTO #t1
FROM #t t INNER JOIN RegisterCases.dbo.t_Case c ON
			t.GUID_Case = c.GUID_Case
					INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
			c.id=m.rf_idCase    			
					INNER JOIN RegisterCases.dbo.t_RecordCaseBack rb ON
			c.id=rb.rf_idCase
					INNER JOIN RegisterCases.dbo.t_CaseBack cb ON
			rb.id=cb.rf_idRecordCaseBack                  
WHERE c.DateEnd>='20160801' AND cb.TypePay=1

SELECT COUNT(*) FROM #t1 



--SELECT COUNT(*) FROM #t 

--SELECT * FROM #t WHERE rf_idCase IN (61902643)
SELECT DISTINCT  t1.rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO , m.rf_idSubMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,
				m.DateHelpEnd ,m.DiagnosisCode ,0,0,0,m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 , m.rf_idDoctor,m.Comments , m.MUSurgery        
FROM #t1 t inner JOIN #t t1 ON
		t.GUID_Case=t1.GUID_Case
			INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
		AND t.GUID_MU=m.GUID_MU          
WHERE NOT EXISTS(SELECT * FROM #t t1 WHERE t1.GUID_Case=t.GUID_Case AND t.GUID_MU=t1.GUID_MU)  




BEGIN TRANSACTION
INSERT dbo.t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,MUGroupCode ,
						MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MUSurgery)
SELECT DISTINCT  t1.rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO , m.rf_idSubMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,
				m.DateHelpEnd ,m.DiagnosisCode ,0,0,0,m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 , m.rf_idDoctor,m.Comments , m.MUSurgery        
FROM #t1 t inner JOIN #t t1 ON
		t.GUID_Case=t1.GUID_Case
			INNER JOIN RegisterCases.dbo.t_Meduslugi m ON
		t.rf_idCase=m.rf_idCase
		AND t.GUID_MU=m.GUID_MU          
--WHERE NOT EXISTS(SELECT * FROM #t t1 WHERE t1.GUID_Case=t.GUID_Case AND t.GUID_MU=t1.GUID_MU)  


SELECT f.CodeM, c.id AS rf_idCase,c.GUID_Case,m.GUID_MU, m.rf_idCase ,
        m.id ,
        m.GUID_MU ,        
        m.MUGroupCode ,
        m.MUUnGroupCode ,
        m.MUCode ,        
        m.MU ,
        m.MUSurgery ,
        m.MUInt
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase				
WHERE f.DateRegistration>'20160801' AND f.DateRegistration<'20161110' AND a.ReportYear=2016 AND c.GUID_Case='2F6709C4-B1F3-7A0C-F064-B708B2A0D1BA'


--ROLLBACK
--GO
commit
DROP TABLE #t	  
DROP TABLE #t1