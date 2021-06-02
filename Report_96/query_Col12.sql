USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190620',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=6,
		@dateEndAkt DATETIME='20190620'
--последняя версия. 
SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN(/*'C80',*/'C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

DECLARE @lastMonth TINYINT --последний отчетный месяц

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,f.TypeFile
			,a.rf_idSMO AS CodeSMO, a.ReportMonth,a.Letter,c.Age, c.DateEnd	 ,a.ReportYear,c.DateBegin
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient																	   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006<4 AND f.TypeFile='H'
UNION ALL
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, f.TypeFile
		,a.rf_idSMO AS CodeSMO,a.ReportMonth,a.Letter ,c.Age , c.DateEnd,a.ReportYear,c.DateBegin
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006=3 AND f.TypeFile='F'
UNION 
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, f.TypeFile
		,a.rf_idSMO AS CodeSMO,a.ReportMonth,a.Letter ,c.Age , c.DateEnd,a.ReportYear ,c.DateBegin
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_DS2_Info d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006=3 AND f.TypeFile='F'

------берем с DS_ONK=1
CREATE UNIQUE NONCLUSTERED INDEX QU_Temp ON #tCases(rf_idRecordCasePatient) WITH IGNORE_DUP_KEY


SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,dd.IsOnko AS DS_ONK,f.TypeFile
		,a.rf_idSMO AS CodeSMO,a.ReportMonth, a.Letter,c.DateEnd,c.DateBegin
INTO #tCase_DS_ONK
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient													     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient													   					  					      
					INNER JOIN dbo.t_DispInfo dd ON
			c.id=dd.rf_idCase 
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006<4 AND dd.IsOnko=1


INSERT #tCase_DS_ONK
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,dd.DS_ONK,f.TypeFile
		,a.rf_idSMO AS CodeSMO,a.ReportMonth, a.Letter,c.DateEnd,c.DateBegin
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient													     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient													   					  					      
					INNER JOIN dbo.t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006<4 AND dd.DS_ONK=1

SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay, f.TypeFile
		,a.rf_idSMO AS CodeSMO,a.ReportMonth,a.Letter ,c.Age , c.DateEnd,a.ReportYear ,c.DateBegin
INTO #tCasesD
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					   										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMonth AND c.rf_idV006=3 AND a.Letter IN('F','O','R')

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt AND TypeCheckup=1	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCase_DS_ONK p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt AND TypeCheckup=1	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT @lastMonth=MAX(ReportMonth) FROM #tCases WHERE AmountPay>0

---------------------------------От Антоновой---------------------------------------------
			
		
		SELECT 0,0,0,0,COUNT(DISTINCT ENP) AS Col12,0,0,0,0
		FROM (			
	SELECT c.ENP
				FROM (SELECT enp, MIN(DateBegin) AS DateEnd
					  FROM #tCases 
					  WHERE TypeFile='H' AND Age>18 AND AmountPay>0 
					  GROUP BY ENP
					 ) c INNER JOIN #tCasesD c1 ON
						c.ENP=c1.ENP   
				--			inner JOIN dbo.t_DispInfo dd ON
				--c1.rf_idCase=dd.rf_idCase                           
				WHERE c1.Letter IN('O','R') AND c1.AmountPay>0 /*AND dd.IsOnko=1 */ AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP)
						AND c1.DateBegin<=c.DateEnd
				--UNION ALL
				--SELECT c.ENP
				--FROM (SELECT enp, MIN(DateBegin) AS DateEnd
				--	  FROM #tCases 
				--	  WHERE TypeFile='H' AND Age>18 AND AmountPay>0 
				--	  GROUP BY ENP
				--	 ) c INNER JOIN #tCase_DS_ONK c1 ON
				--		c.ENP=c1.ENP                              
				--WHERE c1.Letter IN('O','R') AND c1.AmountPay>0 AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c1.ENP)
				--		AND c1.DateBegin<=c.DateEnd                 
				UNION ALL
				SELECT ENP
				FROM #tCases c
				WHERE c.Letter IN('F','D','U') AND c.Age<18 AND AmountPay>0 AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP)
				UNION ALL
				SELECT c.ENP
				FROM (SELECT enp, MIN(DateBegin) AS DateEnd
					  FROM #tCases 
					  WHERE TypeFile='H' AND Age<18 AND AmountPay>0 
					  GROUP BY ENP
							) c INNER JOIN #tCasesD c1 ON
						c.ENP=c1.ENP                              
								INNER JOIN t_DispInfo dd ON
						c1.rf_idCase=dd.rf_idCase                              
				WHERE c1.Letter ='F' AND c1.AmountPay>0 and dd.TypeDisp='ОН1' AND dd.TypeFailure=1 --AND dd.IsOnko=1
						AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP)
				AND c1.DateBegin<=c.DateEnd
				--UNION ALL
				--SELECT c.ENP
				--FROM (SELECT enp, MIN(DateBegin) AS DateEnd
				--	  FROM #tCases 
				--	  WHERE TypeFile='H' AND Age<18 AND AmountPay>0 
				--	  GROUP BY ENP
				--			) c INNER JOIN #tCase_DS_ONK c1 ON
				--		c.ENP=c1.ENP                              
				--				INNER JOIN t_DispInfo dd ON
				--		c1.rf_idCase=dd.rf_idCase                              
				--WHERE c1.Letter ='F' AND c1.AmountPay>0 and dd.TypeDisp='ОН1' AND dd.TypeFailure=1 --AND dd.IsOnko=1
				--		AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP)
				--AND c1.DateBegin<=c.DateEnd
								            
			) t
	
		      
GO
DROP TABLE #tCases
go
DROP TABLE #tCasesD
GO
DROP TABLE #tCase_DS_ONK
GO
DROP TABLE #tD