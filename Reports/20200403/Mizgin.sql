USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20200401',
		@dateEndPay DATETIME='20200403'

CREATE TABLE #tSurgery(MUSurgery VARCHAR(30))

INSERT #tSurgery(MUSurgery) VALUES('A06.10.006'),('A16.12.008.001'),('A16.12.008.002'),('A16.12.028.007')



SELECT DISTINCT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006,mm.MUSurgery
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					INNER JOIN dbo.t_Meduslugi mm ON
              c.id=mm.rf_idCase
					INNER JOIN #tSurgery ss ON
              mm.MUSurgery=ss.MUSurgery
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020
		AND c.rf_idV006<3 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT c.rf_idV006,v6.name AS Usl_ok,c.MUSurgery,v1.RBNAME,count(DISTINCT c.rf_idRecordCasePatient) AS CountCase
FROM #tCases c INNER JOIN dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id
				INNER JOIN oms_nsi.dbo.V001 v1 ON
        c.MUSurgery=v1.IDRB
WHERE AmountPayment>0
GROUP BY c.rf_idV006,v6.name,c.MUSurgery,v1.RBNAME
ORDER BY c.rf_idV006, c.MUSurgery
GO
DROP TABLE #tCases
DROP TABLE #tSurgery