USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200121',
		@dateEndPay DATETIME='20200222',
		@reportYear SMALLINT=2019



SELECT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,CAST(0.0 AS decimal(15,2)) AS AmountPaymentAcc, c.rf_idV006,a.rf_idSMO,p.ENP,c.DateBegin,c.GUID_Case,a.Account,c.DateEnd,c.idRecordCase
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND f.CodeM='103001' AND rf_idV006=1

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
;WITH cteDouble
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp,DateBegin ORDER BY rf_idCase) AS IDRow,ENP,DateBegin
FROM #tCases
WHERE AmountPaymentAcc>0
)
SELECT cc.Account,cc.idRecordCase,cc.ENP,cc.DateBegin,cc.DateEnd,RTRIM(d.DS1)+'-'+m.Diagnosis,CASE WHEN cc.AmountPaymentAcc>0.0 THEN 'Не снят' ELSE 'Снят' END AS ISExpertize,cc.AmountPayment
FROM cteDouble c INNER JOIN #tCases cc ON
		c.ENP=cc.ENP
		AND c.DateBegin=cc.DateBegin
				INNER JOIN dbo.vw_Diagnosis d ON
        cc.rf_idCase=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 m ON
        d.DS1=m.DiagnosisCode
WHERE c.IDRow>1
ORDER BY enp,ISExpertize desc

GO
DROP TABLE #tCases