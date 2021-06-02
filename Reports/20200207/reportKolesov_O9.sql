USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20200121',
		@dateEndPay DATETIME='20190222',
		@reportYear SMALLINT=2019

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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear
		AND mkb.MainDS IN ('O91','O92') AND c.rf_idV006<4

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT c.CodeM,l.NAMES AS LPU,DS
		,COUNT(DISTINCT CASE WHEN rf_idV006=1 THEN rf_idCompletedCase ELSE NULL END) AS Stacionar
		,COUNT(DISTINCT CASE WHEN rf_idV006=2 THEN rf_idCompletedCase ELSE NULL END) AS DnStacionar
		,COUNT(DISTINCT CASE WHEN rf_idV006=3 THEN rf_idCompletedCase ELSE NULL END) AS Ambulatorka
		,COUNT(DISTINCT rf_idCompletedCase) AS TotalCas
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAcc>0
GROUP BY c.CodeM,l.NAMES,DS
ORDER BY c.CodeM,DS

GO
DROP TABLE #tCases