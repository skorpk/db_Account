USE AccountOMS
GO

SELECT f.CodeM,c.id AS rf_idCase, m.MU,m.Quantity,c.AmountPayment
INTO #tmpMU
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN (VALUES('3.5.4'),('2.79.51'),('8.30.3'),('4.15.746')) v(MU) ON
			m.MU=v.MU
WHERE f.DateRegistration>'20160101' AND f.DateRegistration<'21061201' AND a.ReportYear=2016 AND a.ReportMonth<12

ALTER TABLE #tmpMU ADD AmountPaymentAcc DECIMAL(11,2)

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpMU p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20161201'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT l.CodeM,l.NAMES,NumberRow,Info,COUNT(rf_idCase) AS CountCases, SUM(AmountPayment) AS amountPay
FROM (
		SELECT DISTINCT CodeM,1 AS NumberRow,'Количество случаев, имеющих в своем составе услугу 3.5.4' AS Info,rf_idCase,AmountPayment FROM #tmpMU m WHERE MU='3.5.4' AND AmountPaymentAcc>0
		UNION ALL
		SELECT DISTINCT CodeM,2,'Количество случаев, имеющих в своем составе услугу 2.79.51' AS Info,rf_idCase,AmountPayment FROM #tmpMU m WHERE MU='2.79.51' AND AmountPaymentAcc>0
		UNION ALL
		SELECT DISTINCT CodeM,3,'Из них количество услуг по коду 8.30.3' AS Info,SUM(Quantity),AmountPayment 
		FROM #tmpMU m 
		WHERE MU='8.30.3' AND m.AmountPaymentAcc>0 AND EXISTS(SELECT * FROM #tmpMU m1 WHERE m1.MU='2.79.51' AND m.rf_idCase=m1.rf_idCase )
		GROUP BY CodeM,AmountPayment 
		UNION ALL
		SELECT DISTINCT CodeM,4,'Количество случаев, имеющих в своем составе услугу 4.15.746' AS Info,rf_idCase,AmountPayment FROM #tmpMU m WHERE MU='4.15.746' AND AmountPaymentAcc>0
	) t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.Codem  
GROUP BY l.CodeM,l.NAMES,NumberRow,Info
ORDER BY l.CodeM,NumberRow
GO
--DROP TABLE #tmpMU