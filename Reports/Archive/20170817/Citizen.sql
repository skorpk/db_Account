USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170817 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=6,
		@idV006 TINYINT=3
				
SELECT c.id AS rf_idCase,c.AmountPayment,a.ReportMonth,ce.ENP,f.CodeM, c.rf_idV002,ce.Country
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
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006=@idV006

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

SELECT e.ReportMonth,ROW_NUMBER() OVER(ORDER BY e.ReportMonth) AS idNum,l.NAMES AS LPU,v.NameMM, v2.NAME, COUNT(DISTINCT e.ENP) AS CountCitizen,e.Country, CAST(SUM(e.AmountPayment) AS  MONEY) AS Amount 
FROM #tmpEKO e INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		e.rf_idV002=v2.id
				INNER JOIN (VALUES(1,'январь'),(2,'февраль'),(3,'март'),(4,'апрель'),(5,'май'),(6,'июнь')) v(ReportMM,NameMM) ON
		e.ReportMonth=v.ReportMM
				INNER JOIN dbo.vw_sprT001 l ON
		e.CodeM=l.CodeM              
WHERE AmountPayment>0
GROUP BY ReportMonth,l.NAMES ,v.NameMM, v2.NAME,e.Country
ORDER BY e.ReportMonth
GO
DROP TABLE #tmpEKO