USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180101',
		@dtEnd DATETIME='20180526',
		@reportMM TINYINT=5,
		@reportYear SMALLINT=2018

SELECT ps.ENP
INTO #tmpENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient			
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient							
			INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406)) v(rf_idV009) ON--RSLT=411 не брать
			c.rf_idV009=v.rf_idV009 																							
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth>=1 AND a.ReportMonth<5 AND c.rf_idV006=3
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180501'

SELECT a.ReportMonth, c.id,d.DS1, c.rf_idV006, a.rf_idSMO,c.AmountPayment, c.AmountPayment AS AmountPaymentAcc
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO ps ON
		r.id=ps.rf_idRecordCasePatient			
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient							
			INNER JOIN (VALUES(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase																
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth>=1 AND a.ReportMonth<5
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180501' AND NOT EXISTS(SELECT * FROM #tmpENP WHERE ENP=ps.ENP)

UPDATE p SET p.AmountPaymentAcc=p.AmountPaymentAcc-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2018 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase
  ----------------------Наши-----------------------
SELECT Ds1,ReportMonth
	,COUNT(CASE WHEN rf_idV006=1 THEN id ELSE NULL END) AS Stacionar
	,COUNT(CASE WHEN rf_idV006=2 THEN id ELSE NULL END) AS DnStacionar
	,COUNT(CASE WHEN rf_idV006=3 THEN id ELSE NULL END) AS Ambulatoorka
	,COUNT(CASE WHEN rf_idV006=4 THEN id ELSE NULL END) AS Skorya
	,COUNT(id) AS AllCase
FROM #tmpPeople	
WHERE rf_idSMO<>'34' AND (CASE WHEN AmountPayment>0 AND AmountPaymentAcc>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAcc=0 THEN 1 ELSE 0 END)=1
GROUP BY Ds1,ReportMonth
ORDER BY ReportMonth,DS1
----------------------Иногородние-------------------
SELECT Ds1,ReportMonth
	,COUNT(CASE WHEN rf_idV006=1 THEN id ELSE NULL END) AS Stacionar
	,COUNT(CASE WHEN rf_idV006=2 THEN id ELSE NULL END) AS DnStacionar
	,COUNT(CASE WHEN rf_idV006=3 THEN id ELSE NULL END) AS Ambulatoorka
	,COUNT(CASE WHEN rf_idV006=4 THEN id ELSE NULL END) AS Skorya
	,COUNT(id) AS AllCase
FROM #tmpPeople
WHERE rf_idSMO='34' AND (CASE WHEN AmountPayment>0 AND AmountPaymentAcc>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAcc=0 THEN 1 ELSE 0 END)=1
GROUP BY Ds1,ReportMonth
ORDER BY ReportMonth,DS1
go

DROP TABLE #tmpPeople
DROP TABLE #tmpENP