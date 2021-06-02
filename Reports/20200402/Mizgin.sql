USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20200401',
		@dateEndPay DATETIME='20200401'

CREATE TABLE #tSurgery(MUSurgery VARCHAR(30))
INSERT #tSurgery
(
    MUSurgery
)
VALUES('A11.01.012'),('A16.07.083.002'),('A16.07.084.002'),('A16.08.024.002'),('A16.08.026'),('A16.08.045'),('A16.08.047'),('A16.10.007.002'),('A16.10.032.003'),('A16.23.042.001'),
		('A16.23.049.001'),	('A16.23.050.001'),('A16.23.090'),('A16.28.016'),('A16.28.073.001'),('A16.30.001.002'),('A16.30.002.002'),('A16.30.004.011'),('A16.30.004.012'),
		('A16.30.004.015'),('A16.30.004.016'),('A16.30.005.001'),('A16.30.021'),('A16.30.026'),('A16.30.028.001'),('A16.30.058.011'),('A16.30.058.012'),('A16.30.058.015'),('A16.30.058.017')


SELECT c.id AS rf_idCase, f.CodeM, c.AmountPayment,c.rf_idRecordCasePatient,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS FIO,c.DateBegin,c.DateEnd,m.MES,mm.MUSurgery,a.ReportYear
	,c.AmountPayment AS AmountPayment2
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					INNER JOIN dbo.t_RegisterPatient rp ON
            r.id=rp.rf_idRecordCase
			AND rp.rf_idFiles = f.id
					INNER JOIN dbo.t_Meduslugi mm ON
              c.id=mm.rf_idCase
					INNER JOIN #tSurgery ss ON
              mm.MUSurgery=ss.MUSurgery
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear>2017
		AND c.rf_idV006=1 AND f.CodeM='501001'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT ReportYear,MUSurgery,FIO,DateBegin,DateEnd,MES,SUM(AmountPayment2) AS AmountPayment
FROM #tCases
--WHERE AmountPayment>0
GROUP BY ReportYear,MUSurgery,FIO,DateBegin,DateEnd,MES
GO
DROP TABLE #tCases
DROP TABLE #tSurgery