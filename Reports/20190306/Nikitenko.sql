USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190307',
		@dateEndPay DATETIME='20190307',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=2,
		@codeSMO VARCHAR(5)='34'

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
SELECT distinct c.id, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,0.0, c.Age,c.rf_idV006,a.rf_idSMO,p.ENP,pp.Sex
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
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase       
					INNER JOIN oms_nsi.dbo.sprMKBDN dd ON
			d.DS1=dd.DiagnosisCode           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth <=@reportMonth AND a.ReportYear=@reportYear
		AND c.rf_idV006=3	 AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND m.MUCode BETWEEN 52 AND 103	AND c.Age>17 AND a.rf_idSMO=@codeSMO 

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

SELECT 1 AS id, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0 
UNION ALL
SELECT 2, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Ì' 
UNION ALL
SELECT 3, SUM(ISNULL(AmountPayment,0.0)) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(ISNULL(AmmPay,0.0)) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Ì' AND Age=65
UNION ALL
SELECT 4, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Ì' AND Age>65
UNION ALL
SELECT 5, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Æ' 
UNION ALL
SELECT 6, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(ISNULL(AmmPay,0.0))  AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Æ' AND Age=65
UNION ALL
SELECT 7, SUM(AmountPayment) AS Col5,COUNT(DISTINCT enp) AS Col6, SUM(AmmPay) AS Col7 FROM #tCases WHERE AmountPaymentAcc>0	AND Sex='Æ' AND Age>65
GO
DROP TABLE #tCases