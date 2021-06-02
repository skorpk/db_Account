USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20191020',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=9,
		@dateEndAkt DATETIME='20191020'
  
--последн€€ верси€. 
SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN(/*'C80',*/'C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

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
CREATE UNIQUE NONCLUSTERED INDEX QU_Temp ON #tCases(rf_idRecordCasePatient) WITH IGNORE_DUP_KEY
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

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
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


SELECT COUNT(DISTINCT ENP) AS Col7, 0 AS Col8,0 AS Col9,0 AS Col11,0 AS Col12, 0 AS Col13, 0 AS Col14, 0 AS Col15,0 AS Col16 
FROM( 
	  SELECT enp FROM #tCases WHERE AmountPay>0
	  UNION ALL
	  SELECT enp FROM #tCase_DS_ONK WHERE AmountPay>0              
	) t	
--WHERE ENP IN ('3452630882000350','3447240832000365','3471350833000501','3476160842000151','3448140876000207')

SELECT 0,COUNT(DISTINCT ENP) AS Col8,0,0,0,0,0,0,0 
FROM #tCase_DS_ONK d
WHERE AmountPay>0 AND NOT EXISTS(SELECT 1 FROM #tCases WHERE enp=d.ENP AND ReportYear=@reportYear AND AmountPay>0)
	--AND ENP IN ('3452630882000350','3447240832000365','3471350833000501','3476160842000151','3448140876000207')


SELECT 0,0,COUNT(DISTINCT ENP) AS Col9,0,0,0,0,0,0
FROM #tCases c 
WHERE AmountPay>0 --AND ENP IN ('3452630882000350','3447240832000365','3471350833000501','3476160842000151','3448140876000207')
/*
SELECT DISTINCT ENP
INTO #tt
FROM #tCase_DS_ONK d
WHERE AmountPay>0 AND NOT EXISTS(SELECT 1 FROM #tCases WHERE enp=d.ENP AND ReportYear=@reportYear)
UNION ALL
SELECT DISTINCT ENP
FROM #tCases c 
WHERE AmountPay>0 	


SELECT DISTINCT ENP
INTO #ttt
FROM
	(
	  SELECT enp FROM #tCases WHERE AmountPay>0
	  UNION ALL
	  SELECT enp FROM #tCase_DS_ONK WHERE AmountPay>0     
	) t

SELECT *
FROM #ttt t
WHERE NOT EXISTS(SELECT 1 FROM #tt WHERE ENP=t.enp)

SELECT *
FROM #tCases
WHERE Enp='3471350833000501' --AND AmountPay>0 	

SELECT *
FROM #tCase_DS_ONK
WHERE Enp='3471350833000501' AND AmountPay>0 
*/	
GO
DROP TABLE #tCase_DS_ONK
GO
DROP TABLE #tCases
GO
DROP TABLE #tD
GO
DROP TABLE #tt
GO
DROP TABLE #ttt