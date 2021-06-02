USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190411',
		@dateEndPay DATETIME='20190411',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=3		

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	rf_idV006 TINYINT,
	rf_idSMO VARCHAR(5),
	ENP VARCHAR(16),
	Age INT, 
	AmmPay DECIMAL(15,2),
	Sex CHAR(1)
)		

INSERT #tCases( rf_idCase, CodeM,AmountPayment,rf_idCompletedCase,AmountPaymentAcc,Age,rf_idV006,rf_idSMO,ENP,Sex )
SELECT distinct c.id, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,c.AmountPayment, c.Age,c.rf_idV006,a.rf_idSMO,p.ENP,pp.Sex
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase 
					INNER JOIN dbo.t_RegisterPatient pp ON
			f.id=pp.rf_idFiles
			AND r.id=pp.rf_idRecordCase
					 INNER JOIN dbo.t_PurposeOfVisit pv ON 
			c.id = pv.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth <=@reportMonth AND a.ReportYear=@reportYear
		AND c.rf_idV006=3 AND pv.rf_idV025='1.3'	 /*AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND m.MUCode BETWEEN 52 AND 103*/	AND c.Age>17 

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	 AND TypeCheckup=1
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

--SELECT *
--FROM #tCases c INNER JOIN #tCases cc ON
--		c.ENP=cc.ENP
--		AND c.Sex <> cc.Sex

--SELECT * FROM #tCases WHERE ENP='3453410841000117'

SELECT rf_idSMO,1 AS id,SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0  GROUP BY rf_idSMO

SELECT 1 AS id, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0 
UNION ALL
SELECT 2, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' 
UNION ALL
SELECT 3, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' AND Age=65
UNION ALL
SELECT 4, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' AND Age>65
UNION ALL
SELECT 5, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' 
UNION ALL
SELECT 6, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' AND Age=65
UNION ALL
SELECT 7, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='�' AND Age>65
GO
DROP TABLE #tCases