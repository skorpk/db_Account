USE AccountOMSReports
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190221',
		@dateEndPay DATETIME='20190221',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=1

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	DS VARCHAR(5),
	rf_idV006 TINYINT,
	rf_idSMO VARCHAR(5),
	ENP VARCHAR(16)
)		

INSERT #tCases( rf_idCase, CodeM,AmountPayment,rf_idCompletedCase,AmountPaymentAcc,DS,rf_idV006,rf_idSMO,ENP )
SELECT c.id, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,c.AmountPayment, mkb.MainDS,c.rf_idV006,a.rf_idSMO,p.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient						
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase                  
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth =@reportMonth AND a.ReportYear=@reportYear
		AND mkb.MainDS IN ('O00','O01','O02','O03','O04','O05','O06','O07','O08') AND c.rf_idV006<3

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT DS
		,COUNT(DISTINCT CASE WHEN rf_idV006=1 and rf_idSMO<>34 THEN rf_idCompletedCase ELSE NULL END) AS Col3
		,COUNT(DISTINCT CASE WHEN rf_idV006=2 and rf_idSMO<>34 THEN rf_idCompletedCase ELSE NULL END) AS Col4
		,COUNT(DISTINCT CASE WHEN rf_idSMO<>34 THEN rf_idCompletedCase ELSE NULL END) AS Col5
		----------------------PEOPLE-----------------------------
		,count(DISTINCT CASE WHEN rf_idV006=1 and rf_idSMO<>34 THEN ENP ELSE null END) AS Col6
		,count(DISTINCT CASE WHEN rf_idV006=2 and rf_idSMO<>34 THEN ENP ELSE null END) AS Col7
		,count(DISTINCT CASE WHEN rf_idSMO<>34 THEN ENP ELSE null END) AS Col8
		--------------------34--------------------------------------
		,COUNT(DISTINCT CASE WHEN rf_idV006=1 and rf_idSMO=34 THEN rf_idCompletedCase ELSE NULL END) AS Col9
		,COUNT(DISTINCT CASE WHEN rf_idV006=2 and rf_idSMO=34 THEN rf_idCompletedCase ELSE NULL END) AS Col10
		,COUNT(DISTINCT CASE WHEN rf_idSMO=34 THEN rf_idCompletedCase ELSE NULL END) AS Col11
		----------------------PEOPLE-----------------------------
		,count(DISTINCT CASE WHEN rf_idV006=1 and rf_idSMO=34 THEN ENP ELSE null END) AS Col12
		,count(DISTINCT CASE WHEN rf_idV006=2 and rf_idSMO=34 THEN ENP ELSE null END) AS Col13
		,count(DISTINCT CASE WHEN rf_idSMO=34 THEN ENP ELSE null END) AS Col14
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAcc>0
GROUP BY DS
ORDER BY DS

SELECT 	count(DISTINCT CASE WHEN rf_idSMO<>34 THEN ENP ELSE null END) AS OurCitizen
		,count(DISTINCT CASE WHEN rf_idSMO=34 THEN ENP ELSE null END) AS Citizen34
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAcc>0
GO
DROP TABLE #tCases