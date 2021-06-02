USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190509',
		@reportYear SMALLINT=2019,
		@dateEndAkt DATETIME='20190506'		

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, ps.ENP, c.AmountPayment AS AmountPay, a.rf_idSMO
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND f.TypeFile='H' --AND a.rf_idSMO=34

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, ps.ENP, c.AmountPayment AS AmountPay
INTO #tCases2
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
WHERE f.DateRegistration>'20180101' AND f.DateRegistration<'20190125' AND a.ReportYear=2018 AND f.TypeFile='H' 

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT p.ENP) AS Col11
FROM #tCases p
WHERE AmountPay>0 AND NOT EXISTS(SELECT * FROM #tCases2 c WHERE c.ENP=p.ENP AND AmountPay>0)

SELECT COUNT(DISTINCT p.ENP) AS Col13
FROM #tCases p
WHERE rf_idSMO='34' AND AmountPay>0 AND NOT EXISTS(SELECT * FROM #tCases2 c WHERE c.ENP=p.ENP AND AmountPay>0)
GO
DROP TABLE #tCases
DROP TABLE #tCases2
DROP TABLE #tD
