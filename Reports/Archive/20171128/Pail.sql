USE AccountOMS
GO		
DECLARE @dtBegin DATETIME,	
		@dtEndReg DATETIME=GETDATE(),
		@dtEnd DATE,
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12,
		@dtEndCase DATE='20170101'--конец отчетного периода

SET @dtBegin=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEnd=GETDATE()
IF(@reportYear=2017)
BEGIN 
	SET @dtEndCase='20171101'
	SET @reportMonth=10
END

SELECT @dtBegin,@dtEnd,@dtEndReg, @dtEndCase

				
SELECT c.id AS rf_idCase,c.AmountPayment,a.rf_idSMO AS CodeSMO,c.rf_idV006
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.rf_idSMO <>'34' AND a.ReportMonth<=@reportMonth
 AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEndCase

SELECT id,Reason INTO #tCode FROM  OMS_NSI.dbo.sprF014 WHERE Reason LIKE '5.%'	

ALTER TABLE #tmpCases ADD CodeReason VARCHAR(20)
ALTER TABLE #tmpCases ADD AmountPaymentAccepted DECIMAL(15,2) DEFAULT 0.0

	
UPDATE c SET c.AmountPaymentAccepted=AmountDeduction
from #tmpCases c INNER JOIN ( SELECT f.rf_idCase,SUM(f.AmountMEK) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 f INNER JOIN dbo.t_ReasonDenialPayment r ON
											f.idAkt=r.idAkt
											AND f.rf_idCase=r.rf_idCase														                              
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND TypeCheckup=1 AND EXISTS(SELECT * FROM #tCode WHERE id=r.CodeReason)
								GROUP BY f.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

UPDATE c SET c.CodeReason=p.Reason
from #tmpCases c INNER JOIN ( SELECT f.rf_idCase,Reason
							  FROM dbo.t_PaymentAcceptedCase2 f INNER JOIN dbo.t_ReasonDenialPayment r ON
											f.idAkt=r.idAkt
											AND f.rf_idCase=r.rf_idCase														                              
														INNER JOIN #tCode t ON
											r.CodeReason=t.id                                                      
							  WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND TypeCheckup=1 
							) p ON
			c.rf_idCase=p.rf_idCase 
--CREATE NONCLUSTERED INDEX IX_CodeReason
--ON #tmpCases ([CodeReason])
--INCLUDE ([CodeSMO],[rf_idV006],[AmountPaymentAccepted])


;WITH cte 
AS(
SELECT 1 AS Id,'Сумма выставленных счетов' AS Reason,
	   SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=3 THEN AmountPayment ELSE 0 END) AS Amb34002,
	   SUM(CASE WHEN CodeSMO IN('34007','34001') AND rf_idV006=3 THEN AmountPayment ELSE 0 END) AS Amb34007,
	   SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=1 THEN AmountPayment ELSE 0 END) AS Stac34002,
	   SUM(CASE WHEN CodeSMO IN('34007','34001') AND rf_idV006=1 THEN AmountPayment ELSE 0 END) AS Stac34007,
	   SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=2 THEN AmountPayment ELSE 0 END) AS DnStac34002,
	   SUM(CASE WHEN CodeSMO IN('34007','34001') AND rf_idV006=2 THEN AmountPayment ELSE 0 END) AS DnStac34007,
	   SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=4 THEN AmountPayment ELSE 0 END) AS Skor34002,
	   SUM(CASE WHEN CodeSMO IN('34007','34001') AND rf_idV006=4 THEN AmountPayment ELSE 0 END) AS Skor34007
FROM #tmpCases
GROUP BY CodeSMO
UNION ALL
SELECT 2,CodeReason AS Reason,SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=3 THEN AmountPaymentAccepted ELSE 0 END) AS Amb34002,
				  SUM(CASE WHEN CodeSMO='34007' AND rf_idV006=3 THEN AmountPaymentAccepted ELSE 0 END) AS Amb34007,
				  SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=1 THEN AmountPaymentAccepted ELSE 0 END) AS Stac34002,
				  SUM(CASE WHEN CodeSMO='34007' AND rf_idV006=1 THEN AmountPaymentAccepted ELSE 0 END) AS Stac34007,
				  SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=2 THEN AmountPaymentAccepted ELSE 0 END) AS DnStac34002,
				  SUM(CASE WHEN CodeSMO='34007' AND rf_idV006=2 THEN AmountPaymentAccepted ELSE 0 END) AS DnStac34007,
				  SUM(CASE WHEN CodeSMO='34002' AND rf_idV006=4 THEN AmountPaymentAccepted ELSE 0 END) AS Skor34002,
				  SUM(CASE WHEN CodeSMO='34007' AND rf_idV006=4 THEN AmountPaymentAccepted ELSE 0 END) AS Skor34007
FROM #tmpCases
WHERE CodeReason IS NOT NULL
GROUP BY CodeReason
)
SELECT id, Reason
		,cast(SUM(Amb34002)  as money) AS Amb34002
		,cast(SUM(Amb34007)  as money) as Amb34007
		,cast(sum(Stac34002) as money) AS Stac34002
		,cast(sum(Stac34007) AS MONEY) AS Stac34007
		,cast(sum(DnStac34002) as money) AS DnStac34002
		,cast(sum(DnStac34007) as money) AS DnStac34007
		,cast(sum(Skor34002) as money) AS Skor34002
		,cast(sum(Skor34007) as money) AS Skor34007 
FROM cte
GROUP BY id,Reason
ORDER BY id, Reason

go
DROP TABLE #tmpCases
DROP TABLE #tCode

