USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEnd DATE='20171231',
		@dtEndAmb DATETIME='20180830',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12


SELECT ENP, rf_idMO, DateEnd, Territory
INTO #tmpEKO
FROM dbo.tmpEKO34

SELECT DISTINCT c.id AS rf_idCase,c.AmountPayment,d.DS1,c.DateBegin,c.DateEnd,ps.ENP,c.rf_idV006, m.MES,a.rf_idMO, c.Comments
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN #tmpEKO e ON
			ps.ENP=e.ENP	
					left JOIN t_Mes m ON
			c.id=m.rf_idCase								
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEndAmb AND c.rf_idV002=136 AND c.rf_idV006 IN(1,3) 
	AND c.DateBegin>=e.DateEnd AND c.DateEnd>=@dtBegin  AND c.DateEnd<@dtEndAmb  

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases cc ON
														c.rf_idCase=cc.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<@dtEndAmb
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 



----------стационар--------------------   
SELECT e.ENP,e.DateEnd, l.mcod+' - '+l.NAM_MOK, l1.mcod+' - '+l1.NAM_MOK,c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis, c.MES
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode 
				INNER JOIN oms_nsi.dbo.sprMO l ON
		e.rf_idMO=l.mcod
				INNER JOIN oms_nsi.dbo.sprMO l1 ON
		c.rf_idMO=l1.mcod
WHERE c.AmountPayment>0	AND c.rf_idV006=1 AND c.DateBegin>=e.DateEnd
ORDER BY e.ENP, e.DateEnd,c.DateEnd
----------Амбулаторка--------------------   
SELECT DISTINCT e.ENP,e.DateEnd, l.mcod+' - '+l.NAM_MOK, l1.mcod+' - '+l1.NAM_MOK,c.DateBegin,c.DateEnd,c.DS1,m.Diagnosis, ISNULL(c.Comments,'')
FROM #tmpEKO e INNER JOIN #tmpCases c ON
		e.ENP=c.ENP
				INNER JOIN dbo.vw_sprMKB10 m ON
		c.DS1=m.DiagnosisCode 
				INNER JOIN oms_nsi.dbo.sprMO l ON
		e.rf_idMO=l.mcod
				INNER JOIN oms_nsi.dbo.sprMO l1 ON
		c.rf_idMO=l1.mcod
WHERE c.AmountPayment>0	AND c.rf_idV006=3 AND c.DateBegin>=e.DateEnd
ORDER BY e.ENP, e.DateEnd,c.DateEnd
go

DROP TABLE #tmpCases
DROP TABLE #tmpEKO
