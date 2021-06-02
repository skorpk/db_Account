USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190511',
		@dateEndPay DATETIME='20190511',
		@reportYear SMALLINT=2019

SELECT c.id AS rf_idCase,m.MES,cc.AmountPayment, cc.AmountPayment AS AmmPay,c.rf_idV006,cc.id
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code
			AND c.DateEnd BETWEEN csg.dateBeg AND csg.dateEnd																													                 
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006 <3
	AND EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUSurgery='B03.001.005')


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(id),MES,SUM(AmmPay) AS AmmPay,SUM(AmountPayment) AS AmountPayment
FROM(
	SELECT distinct id,mes,AmmPay,AmountPayment
	FROM #tCases 
	WHERE rf_idV006=1 AND AmountPayment>0
	) t
GROUP BY MES

SELECT COUNT(id),MES,SUM(AmmPay) AS AmmPay,SUM(AmountPayment) AS AmountPayment
FROM (
		SELECT distinct id,mes,AmmPay,AmountPayment
		FROM #tCases 
		WHERE rf_idV006=2 AND AmountPayment>0
	) t
GROUP BY MES
go

DROP TABLE #tCases
