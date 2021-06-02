USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATE='20180119',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12

SELECT MU,MUName
INTO #tMU
FROM dbo.vw_sprMU WHERE MUGroupCode=70 AND MUUnGroupCode=5 AND MUCode>2 AND MUCode<15
UNION ALL
SELECT MU,MUName
FROM dbo.vw_sprMU WHERE MUGroupCode=70 AND MUUnGroupCode=6 AND MUCode>0 AND MUCode<13

				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment AS AmountPaymentAccepted, mu.MU ,mu.MUName
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
					INNER JOIN #tMU mu ON
			m.MES=mu.MU                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	
UPDATE c SET c.AmountPaymentAccepted=c.AmountPaymentAccepted-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase   

SELECT c.CodeM,l.NAMES, c.MU,c.MUName,COUNT(c.rf_idCase)
FROM #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAccepted>0
GROUP BY c.CodeM,l.NAMES, c.MU,c.MUName
ORDER BY c.CodeM,c.MU
go
DROP TABLE #tmpCases
DROP TABLE #tMU
