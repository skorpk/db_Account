USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',	--всегда с начало года
		@dateEnd DATETIME='20200817',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=7,
		@dateEndAkt DATETIME='20200817'
--последн€€ верси€. 
SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
--AND MainDS NOT IN(/*'C80',*/'C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

DECLARE @lastMonth TINYINT, --последний отчетный мес€ц
		@dateEndCase DATE
  
 set	@dateEndCase=DATEADD(MONTH,1,CAST((CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01') AS DATE))      

 
--=======================================================================================================================--
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
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient																	   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006<4 AND f.TypeFile='H'
--=======================================================================================================================--
CREATE UNIQUE NONCLUSTERED INDEX QU_Temp ON #tCases(rf_idRecordCasePatient,rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006=3 AND f.TypeFile='F'
--=======================================================================================================================--
INSERT #tCases
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006=3 AND f.TypeFile='F'
----------------------------------------------------------2019-----------------------------------------------------------------------
----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,ps.ENP, c.AmountPayment AS AmountPay,f.TypeFile
			,a.rf_idSMO AS CodeSMO, a.ReportMonth,a.Letter,c.Age, c.DateEnd	 ,a.ReportYear,c.DateBegin
INTO #tCases2019
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient																	   					  					      
WHERE f.DateRegistration>'20190101' AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.DateEnd<'20200101' AND c.rf_idV006<4 AND f.TypeFile='H'

CREATE UNIQUE NONCLUSTERED INDEX QU_Temp2019 ON #tCases2019(rf_idRecordCasePatient,rf_idCase) WITH IGNORE_DUP_KEY
INSERT #tCases2019
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
WHERE f.DateRegistration>'20190101' AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.DateEnd<'20200101' AND c.rf_idV006=3 AND f.TypeFile='F'

INSERT #tCases2019
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
WHERE f.DateRegistration>'20190101' AND f.DateRegistration<@dateEnd AND a.ReportYear=2019 AND c.DateEnd<'20200101' AND c.rf_idV006=3 AND f.TypeFile='F'


--=======================================================================================================================--
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006<4 AND dd.IsOnko=1
 --=======================================================================================================================--
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006<4 AND dd.DS_ONK=1
--=======================================================================================================================--
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.DateEnd<@dateEndCase AND c.rf_idV006=3 AND a.Letter IN('F','O','R')
 --=======================================================================================================================--
UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt AND TypeCheckup=1	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
 --=======================================================================================================================--
UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases2019 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt AND TypeCheckup=1	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
 --=======================================================================================================================--
UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCase_DS_ONK p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt AND TypeCheckup=1	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT @lastMonth=MAX(ReportMonth) FROM #tCases WHERE AmountPay>0

--SELECT MAX(ReportMonth) FROM #tCases 



---------------------------------ќт јнтоновой---------------------------------------------
		
		----√рафы 14-16
		SELECT 0,0,0,0,0,0,COUNT(DISTINCT ENP),0,0
		FROM (      
				SELECT c.ENP
				FROM #tCases c INNER JOIN dbo.t_PurposeOfVisit pv ON
							c.rf_idCase=pv.rf_idCase              
								INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id                                
				WHERE amountPay>0 AND TypeFile='H' AND pv.rf_idV025='1.3' AND cc.rf_idV002 IN(60,18) AND pv.DN IN(1,2)
				UNION ALL				
				SELECT c.ENP
				FROM #tCases c INNER JOIN dbo.t_DS2_Info cc ON
							c.rf_idCase=cc.rf_idCase         
				WHERE amountPay>0 AND TypeFile='F' AND cc.IsNeedDisp IN (1,2) AND c.Letter IN('O','R','F','D','U')
				UNION ALL				
				SELECT c.ENP
				FROM #tCases c INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id        
				WHERE amountPay>0 AND TypeFile='F' AND cc.IsNeedDisp IN (1,2) AND c.Letter IN('O','R','F','D','U')
				UNION ALL
				--------------2019-------------------------
                SELECT c.ENP
				FROM #tCases2019 c INNER JOIN dbo.t_PurposeOfVisit pv ON
							c.rf_idCase=pv.rf_idCase              
								INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id                                
				WHERE amountPay>0 AND TypeFile='H' AND pv.rf_idV025='1.3' AND cc.rf_idV002 IN(60,18) AND pv.DN IN(1,2)
				UNION ALL				
				SELECT c.ENP
				FROM #tCases2019 c INNER JOIN dbo.t_DS2_Info cc ON
							c.rf_idCase=cc.rf_idCase         
				WHERE amountPay>0 AND TypeFile='F' AND cc.IsNeedDisp IN (1,2) AND c.Letter IN('O','R','F','D','U')
				UNION ALL				
				SELECT c.ENP
				FROM #tCases2019 c INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id        
				WHERE amountPay>0 AND TypeFile='F' AND cc.IsNeedDisp IN (1,2) AND c.Letter IN('O','R','F','D','U')
			)t

			SELECT 0,0,0,0,0,0,0,COUNT(DISTINCT ENP) AS Col15,0
			FROM (      
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_PurposeOfVisit pv ON
								c.rf_idCase=pv.rf_idCase              
									INNER JOIN dbo.t_Case cc ON
								c.rf_idCase=cc.id                                
					WHERE amountPay>0 AND TypeFile='H' AND pv.rf_idV025='1.3' AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1))
						  AND cc.rf_idV002 IN(60,18) AND pv.DN=2 
					UNION ALL				
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_DS2_Info cc ON
							c.rf_idCase=cc.rf_idCase                            
					WHERE amountPay>0 AND TypeFile='F' AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1)) AND cc.IsNeedDisp =2
					UNION ALL				
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id                        
					WHERE amountPay>0 AND TypeFile='F' AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1)) AND cc.IsNeedDisp=2
				)t

			
			SELECT distinct ENP
			FROM (      
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_PurposeOfVisit pv ON
								c.rf_idCase=pv.rf_idCase              
									INNER JOIN dbo.t_Case cc ON
								c.rf_idCase=cc.id                                
					WHERE amountPay>0 AND TypeFile='H' AND pv.rf_idV025='1.3' AND  EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1))
						  AND cc.rf_idV002 IN(60,18) AND pv.DN=2 
					UNION ALL				
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_DS2_Info cc ON
							c.rf_idCase=cc.rf_idCase                            
					WHERE amountPay>0 AND TypeFile='F' AND  EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1)) AND cc.IsNeedDisp =2
					UNION ALL				
					SELECT c.ENP
					FROM #tCases c INNER JOIN dbo.t_Case cc ON
							c.rf_idCase=cc.id                        
					WHERE amountPay>0 AND TypeFile='F' AND EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 WHERE ENP=c.ENP AND ReportYear=(@reportYear-1)) AND cc.IsNeedDisp=2
				)t
GO
if OBJECT_ID('tempDB..#tCases',N'U') is not NULL
DROP TABLE #tCases
if OBJECT_ID('tempDB..#tCases2019',N'U') is not NULL
DROP TABLE #tCases2019
if OBJECT_ID('tempDB..#tCases2',N'U') is not NULL
DROP TABLE #tCases2
if OBJECT_ID('tempDB..#tD',N'U') is not NULL
DROP TABLE #tD
if OBJECT_ID('tempDB..#tmpSkrybina',N'U') is not NULL
DROP TABLE #tmpSkrybina
if OBJECT_ID('tempDB..#tmpKolesov',N'U') is not NULL 
DROP TABLE #tmpKolesov
if OBJECT_ID('tempDB..#F014',N'U') is not NULL
DROP TABLE #F014
if OBJECT_ID('tempDB..#tCase_DS_ONK',N'U') is not NULL						
DROP TABLE #tCase_DS_ONK
if OBJECT_ID('tempDB..#tCasesM',N'U') is not NULL
DROP TABLE #tCasesM
if OBJECT_ID('tempDB..#tCases21_24',N'U') is not NULL
DROP TABLE #tCases21_24
if OBJECT_ID('tempDB..#tENP',N'U') is not NULL
DROP TABLE #tENP
if OBJECT_ID('tempDB..#tCases3',N'U') is not NULL
DROP TABLE #tCases3
if OBJECT_ID('tempDB..#tmpMagalyz',N'U') is not NULL
DROP TABLE #tmpMagalyz
if OBJECT_ID('tempDB..#tCasesD',N'U') is not NULL
DROP TABLE #tCasesD
