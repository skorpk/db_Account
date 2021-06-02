USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20171208 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth tinyint=11	  

SELECT distinct c.id,c.AmountPayment, v.*
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts		
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient					
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase
				INNER JOIN (VALUES('A18.05.002','Гемодиализ'),('A18.05.002.001','Гемодиализ интермиттирующий высокопоточный'),('A18.05.002.002','Гемодиализ интермиттирующий низкопоточный')) v(IdMU,Name) ON
		m.MUSurgery=v.IdMU	
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd AND c.rf_idV006=2 AND a.ReportMonth<=@reportMonth AND a.ReportYear=@reportYear

UPDATE p SET p.AmountPayment=p.AmountPayment-r.Deduction
FROM #tmpCases p INNER JOIN (SELECT f.rf_idCase,SUM(f.AmountDeduction) AS Deduction
								FROM dbo.t_PaymentAcceptedCase2 f																					
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEnd 
								GROUP BY f.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT IdMU,Name,COUNT(DISTINCT id),CAST(SUM(AmountPayment) AS MONEY) FROM #tmpCases WHERE AmountPayment>0 GROUP BY IdMU,Name
go
DROP TABLE #tmpCases

