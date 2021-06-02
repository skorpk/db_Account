USE AccountOMS
GO
declare @dateStartReg DATETIME,
		@dateEndReg DATETIME='20170616 23:59:59',
		@reportYear SMALLINT=2017

SET @dateStartReg=CAST(@reportYear AS VARCHAR(4))+'0101'

DECLARE @dt1 DATE =CAST(@reportYear AS VARCHAR(4))+'1201',
		@dt2 DATE,
		@dt3 DATE

SELECT @dt2=DATEADD(DAY,10,@dt1), @dt3=DATEADD(DAY,20,@dt1)                

SELECT @dt1,@dt2,@dt3

SELECT c.id AS rf_idCase,c.AmountPayment,c.DateEnd,a.ReportMonth,a.ReportYear
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient										
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@reportYear 
		AND a.ReportMonth IN(1,2,3,10,11,12) AND c.AmountPayment=0 AND c.rf_idV006=4 AND a.rf_idSMO<>'34'

ALTER TABLE #tmpPeople ADD AmountPaymentAcc DECIMAL(15,2) 

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE d.TypeCheckup=1 and f.DateRegistration>=@dateStartReg AND f.DateRegistration<'20170617'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT ReportYear,
	   cast(count(CASE WHEN ReportMonth=10 AND ReportYear<2017 THEN rf_idCase ELSE null END) AS MONEY) AS October,
	   cast(count(CASE WHEN ReportMonth=11 AND ReportYear<2017 THEN rf_idCase ELSE null END) AS MONEY) AS November,
	   cast(count(CASE WHEN ReportMonth=12 AND ReportYear<2017 THEN rf_idCase ELSE null END) AS MONEY) AS December,
	   '' AS EmptyCol,
	   cast(count(CASE WHEN ReportMonth=12  AND ReportYear<2017 AND DateEnd>=@dt1 AND DateEnd<@dt2 THEN rf_idCase ELSE null END)AS MONEY) AS December1_10,
	   cast(count(CASE WHEN ReportMonth=12  AND ReportYear<2017 AND DateEnd>=@dt2 AND DateEnd<@dt3 THEN rf_idCase ELSE null END)AS MONEY) AS December11_21,
	   cast(count(CASE WHEN ReportMonth=12  AND ReportYear<2017 AND DateEnd>=@dt3 THEN rf_idCase ELSE null END) AS MONEY) AS December21_31,
	   cast(count(CASE WHEN ReportMonth=1 AND ReportYear>2014 THEN rf_idCase ELSE null END)AS MONEY)  AS January,
	   cast(count(CASE WHEN ReportMonth=2 AND ReportYear>2014 THEN rf_idCase ELSE null END) AS MONEY) AS Feb,
	   cast(count(CASE WHEN ReportMonth=3 AND ReportYear>2014 THEN rf_idCase ELSE null END) AS MONEY) AS March
FROM #tmpPeople
WHERE AmountPaymentAcc=0 
GROUP BY ReportYear

GO 
DROP TABLE #tmpPeople