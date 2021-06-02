USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200611' 


SELECT DISTINCT p.ENP,cc.DateEnd,c.id AS rf_idCase,a.ReportYearMonth,cc.AmountPayment,rp.BirthDay,rp.rf_idV005,cc.AmountPayment AS AmountPaymentLPU, c.rf_idV006
	,CASE WHEN a.rf_idSMO='34' THEN 1 ELSE 0 END AS IsResident
INTO #tStac
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009
					INNER JOIN dbo.t_CompletedCase cc ON
            cc.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.vw_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND rp.rf_idFiles = f.id										                 																						
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear>2018 AND a.ReportYearMonth<202006 
/*-----------------------------Стационар Экспертиза------------------------------------------*/
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tStac p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cteMort
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd) AS idRow,ENP,BirthDay AS DR, CASE WHEN rf_idV005=1 then 'М' ELSE 'Ж'END AS W,DateEnd AS DS,ReportYearMonth, IsResident
FROM #tStac
WHERE (CASE WHEN AmountPaymentLPU>0.0 AND AmountPayment>0.0 THEN 1 WHEN AmountPaymentLPU=0.0 AND AmountPayment=0.0 THEN 1 ELSE 0 END)=1
)
SELECT ROW_NUMBER() OVER(ORDER BY c.DS,enp) AS IdRow,c.ENP,c.DR,c.W,c.DS,c.ReportYearMonth,c.IsResident
INTO tmp_mortality
FROM cteMort c WHERE c.idRow=1
GO
DROP TABLE #tStac
