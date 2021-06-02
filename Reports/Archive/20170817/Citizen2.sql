USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170817 15:00',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=6
				
SELECT c.id AS rf_idCase,c.AmountPayment,a.ReportMonth,ce.ENP,f.CodeM, c.rf_idV002,ce.Country,a.rf_idSMO
INTO #tmpEKO
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase  										
					INNER JOIN dbo.tmp_FC ce ON
			ps.ENP=ce.ENP			                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006 IN(1,3)

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpEKO c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM [SRVSQL2-ST1].ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  [SRVSQL2-ST1].ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN [SRVSQL2-ST1].ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN [SRVSQL2-ST1].ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmpEKO cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

SELECT ROW_NUMBER() OVER(ORDER BY e.Country) AS idNum,COUNT(DISTINCT e.ENP) AS CountCitizen,e.Country
FROM #tmpEKO e         
WHERE AmountPayment>0
GROUP BY e.Country
ORDER BY e.Country


SELECT ROW_NUMBER() OVER(ORDER BY e.rf_idSMO) AS idNum,COUNT(DISTINCT e.ENP) AS CountCitizen,s.sNameS,e.rf_idSMO
FROM #tmpEKO e INNER JOIN dbo.vw_sprSMO s ON
		e.rf_idSMO=s.smocod        
WHERE AmountPayment>0
GROUP BY e.rf_idSMO,s.sNameS
ORDER BY e.rf_idSMO
GO
DROP TABLE #tmpEKO