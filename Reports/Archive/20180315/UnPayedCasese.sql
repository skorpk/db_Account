USE AccountOMS
GO
DECLARE @dateStart DATETIME='20170101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2017,
		@dateEndCase date='20180101'

SELECT f.CodeM,a.Account,a.rf_idSMO AS CodeSMO,c.idRecordCase,c.GUID_Case,c.id AS rf_idCase,c.AmountPayment AS AmountPaymentAccepted, CAST(0.0 AS DECIMAL(15,2)) AS AmountPayment
INTO #tPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient           		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					 INNER JOIN (VALUES(1,33),(2,43)) v(v006,v010) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG csg ON
			m.MES=csg.code                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd	AND a.ReportYear=@reportYear AND c.DateEnd<@dateEndCase
		AND c.rf_idV006<3 AND NOT EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS2017 WHERE rf_idCase=c.id) 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_PaidCase p WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEnd and p.rf_idCase=c.id) AND a.rf_idSMO<>'34'


--UPDATE p SET p.AmountPayment=r.AmountPayment
--FROM #tPeople p INNER JOIN (
--							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
--							FROM dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
--												p.rf_idCase=t.rf_idCase
--							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEnd	 
--							GROUP BY t.rf_idCase
--							) r ON
--			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEnd	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT *
FROM #tPeople p 
WHERE /*AmountPayment<AmountPaymentAccepted*/ AmountPayment=0.0 AND AmountPaymentAccepted>0
ORDER BY p.CodeM,p.Account
GO
DROP TABLE #tPeople