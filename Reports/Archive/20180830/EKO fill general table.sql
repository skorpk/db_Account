USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATEtime='20180120',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12
				
SELECT c.id AS rf_idCase,c.AmountPayment,c.DateEnd,ps.ENP,f.CodeM, a.rf_idMO
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					inner JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient														
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND c.rf_idV002=137 AND c.rf_idV006=2
	AND m.MES LIKE '2__40005'


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2	c
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<='20180121'
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 


--DROP TABLE dbo.tmpEKO34

SELECT 	DateEnd ,ENP, 2 AS idV006, rf_idMO, 'Волгоградская область' AS Territory
--INTO tmpEKO34
FROM #tmpEKO e 
WHERE AmountPayment>0
GO
DROP TABLE #tmpEKO