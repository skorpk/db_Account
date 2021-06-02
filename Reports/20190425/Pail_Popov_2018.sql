USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190127',
		@dateEndPay DATETIME='20190411',
		@reportYear SMALLINT=2018

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	rf_idV006 TINYINT,
	rf_idSMO VARCHAR(5),	
	AmmPay DECIMAL(15,2)
)		

INSERT #tCases( rf_idCase, CodeM,AmountPayment,rf_idCompletedCase,AmountPaymentAcc,rf_idV006,rf_idSMO)
SELECT distinct c.id, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,c.AmountPayment, c.rf_idV006,a.rf_idSMO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient														                 			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.rf_idSMO in('34002','34007')	AND c.rf_idV006<4	

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmmPay=r.AmountPaymentAccept
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountPaymentAccept
								FROM dbo.t_PaidCase c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT s.smocod+' - '+s.sNameS
		,cast(SUM(CASE WHEN c.rf_idV006=3 THEN c.AmountPaymentAcc ELSE 0.0 END) AS MONEY) AS AmbulatorkaAcc
		,cast(SUM(CASE WHEN c.rf_idV006=3 THEN c.AmmPay ELSE 0.0 END) AS MONEY) AS AmbulatorkaPaid
		-------------------------------------------------------------------------------
		,CAST(SUM(CASE WHEN c.rf_idV006=2 THEN c.AmountPaymentAcc ELSE 0.0 END) AS MONEY) AS DnStacioanraAcc
		,CAST(SUM(CASE WHEN c.rf_idV006=2 THEN c.AmmPay ELSE 0.0 END) AS MONEY) AS DnStacioanrPaid
		-------------------------------------------------------------------------------
		,CAST(SUM(CASE WHEN c.rf_idV006=1 THEN c.AmountPaymentAcc ELSE 0.0 END) AS MONEY) AS StacioanraAcc
		,CAST(SUM(CASE WHEN c.rf_idV006=1 THEN c.AmmPay ELSE 0.0 END) AS MONEY) AS StacioanrPaid
		-------------------------------------------------------------------------------
		--,cast(SUM(CASE WHEN c.rf_idV006=4 THEN c.AmountPaymentAcc ELSE 0.0 END) AS MONEY) AS SMPAcc
		--,cast(SUM(CASE WHEN c.rf_idV006=4 THEN c.AmmPay ELSE 0.0 END) AS MONEY) AS SMPPaid
FROM #tCases c INNER JOIN dbo.vw_sprSMO s ON
		c.rf_idSMO=s.smocod
GROUP BY s.smocod+' - '+s.sNameS
GO
DROP TABLE #tCases