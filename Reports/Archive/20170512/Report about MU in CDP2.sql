USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEnd DATE='20170619',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=5
				
SELECT c.id AS rf_idCase,c.AmountPayment,a.ReportMonth,c.rf_idMO,c.rf_idDirectMO,sum(m.Quantity) AS QuantityMU,m.MUUnGroupCode
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO<>'34' AND f.CodeM='125901' AND a.Letter='K' AND m.MUGroupCode=4
GROUP BY c.id,c.AmountPayment, a.ReportMonth,c.rf_idMO,c.rf_idDirectMO,m.MUUnGroupCode



UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEnd
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

--SELECT SUM(QuantityMU),COUNT(rf_idCase) FROM #tmp WHERE AmountPayment>0

SELECT  LEFT(l.tfomsCode, 6) AS CodeM,l.mNAMES,t.ReportMonth,t.MUUnGroupCode,COUNT(t.rf_idCase),SUM(t.QuantityMU) as QuantityMU
FROM #tmp t INNER JOIN OMS_NSI.dbo.tMO l ON
		t.rf_idDirectMO=l.mcod
WHERE t.AmountPayment>0	AND l.isFirstLvl=1
GROUP BY LEFT(l.tfomsCode, 6),l.mNAMES,t.ReportMonth,t.MUUnGroupCode
ORDER BY CodeM,t.ReportMonth,t.MUUnGroupCode

GO
DROP TABLE #tmp