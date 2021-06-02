
USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATE='20180123',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=12, 
		@codeSMO CHAR(5)='34002'

SELECT code AS CSG, 1 AS TypeCSG
INTO #tCSG
FROM dbo.vw_sprCSG WHERE code LIKE '1____03[1-3]%'
UNION ALL
SELECT code, 1 AS rf_idV006 FROM dbo.vw_sprCSG WHERE code LIKE '1____14[2-6]%'
UNION ALL
SELECT code, 2 AS rf_idV006 FROM dbo.vw_sprCSG WHERE code LIKE '2____01[3-5]%'
UNION ALL
SELECT code, 2 AS rf_idV006 FROM dbo.vw_sprCSG WHERE code LIKE '2____05[0-4]%'

				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.rf_idV006,ISNULL(mu.TypeCSG,9) AS TypeChemotherapy
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            					
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase	
					left JOIN #tCSG mu ON
			m.MES=mu.CSG   
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006<4
		AND d.DS1 LIKE 'C%' AND a.rf_idSMO=@codeSMO

--CREATE UNIQUE NONCLUSTERED INDEX QU_tmp ON #tmpCases(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tmpCases (CodeM,rf_idCase,AmountPayment,rf_idV006,TypeChemotherapy)
SELECT f.CodeM,c.id ,c.AmountPayment,c.rf_idV006,ISNULL(mu.TypeCSG,9) AS TypeChemotherapy
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase            					
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase	
					left JOIN #tCSG mu ON
			m.MES=mu.CSG   
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006<4
		AND d.DS2 LIKE 'C%' AND a.rf_idSMO=@codeSMO

INSERT #tmpCases (CodeM,rf_idCase,AmountPayment,rf_idV006,TypeChemotherapy)
SELECT f.CodeM,c.id ,c.AmountPayment,c.rf_idV006,9 AS TypeChemotherapy
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																				
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase						
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006<4 AND c.IsCompletedCase=0
		AND d.DS2 LIKE 'C%' AND a.rf_idSMO=@codeSMO

INSERT #tmpCases (CodeM,rf_idCase,AmountPayment,rf_idV006,TypeChemotherapy)
SELECT f.CodeM,c.id ,c.AmountPayment,c.rf_idV006,9 AS TypeChemotherapy
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																				
					INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase						
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth AND c.rf_idV006<4 AND c.IsCompletedCase=0
		AND d.DS1 LIKE 'C%' AND a.rf_idSMO=@codeSMO

--DROP TABLE tmpIdCaseCanser
--SELECT *
--INTO tmpIdCaseCanser
--FROM #tmpCases

ALTER TABLE #tmpCases ADD EKMP TINYINT
ALTER TABLE #tmpCases ADD CodeReason INT
ALTER TABLE #tmpCases ADD IsReason TINYINT NOT NULL DEFAULT(0)
ALTER TABLE #tmpCases ADD CountReason TINYINT NOT NULL DEFAULT(0)

select Id ,Reason
INTO #tmpReason
from oms_nsi.dbo.sprF014 
WHERE Reason LIKE '3.[2-4].%'
order by Reason
	
UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase  

UPDATE c1 SET c1.EKMP=3
FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases c1 ON
				c.rf_idCase=c1.rf_idCase
WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg AND TypeCheckup=3

UPDATE c SET c.CountReason=p.CountReason
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,COUNT(DISTINCT rd.CodeReason) AS CountReason
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN dbo.t_ReasonDenialPayment rd ON
												c.rf_idCase = rd.rf_idCase
												AND c.idAkt = rd.idAkt                              
																	INNER JOIN #tmpCases c1 ON
												c.rf_idCase=c1.rf_idCase
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg AND TypeCheckup=3
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase  


UPDATE c1 SET c1.CodeReason=rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN dbo.t_ReasonDenialPayment rd ON
				c.rf_idCase = rd.rf_idCase
				AND c.idAkt = rd.idAkt                              
									INNER JOIN #tmpCases c1 ON
				c.rf_idCase=c1.rf_idCase
WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg AND TypeCheckup=3 

UPDATE c SET c.IsReason=CountIsReason
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,COUNT(DISTINCT rd.CodeReason) AS CountIsReason
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN dbo.t_ReasonDenialPayment rd ON
												c.rf_idCase = rd.rf_idCase
												AND c.idAkt = rd.idAkt                              
																	INNER JOIN #tmpCases c1 ON
												c.rf_idCase=c1.rf_idCase                                  
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg AND EXISTS( SELECT 1 FROM #tmpReason WHERE id=rd.CodeReason) AND TypeCheckup=3
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase  

SELECT '1',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
		  ,COUNT(CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
		  ,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
		  ,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE AmountPayment>0
UNION ALL
SELECT '1.1',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
			,COUNT(DISTINCT CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
		    ,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
			,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE AmountPayment>0 AND TypeChemotherapy<9
UNION ALL
SELECT '2',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
		  ,COUNT(CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
		  ,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
		  ,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE EKMP IS NOT NULL
UNION ALL
SELECT '2.1',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
			,COUNT(CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
			,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
			,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE EKMP IS NOT NULL AND TypeChemotherapy<9
UNION ALL
SELECT '3',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
		  ,COUNT(CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
		  ,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
		  ,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE CodeReason IS NOT NULL
UNION ALL
SELECT '3.1',COUNT(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL END) AS Ambulance
			,COUNT(CASE WHEN rf_idV006=1 THEN rf_idCase ELSE NULL END) AS Stacionar
		    ,COUNT(CASE WHEN rf_idV006=2 THEN rf_idCase ELSE NULL END) AS DnevnoiStacionar
			,COUNT(rf_idCase) AS AllCases
FROM #tmpCases
WHERE CodeReason IS NOT NULL AND TypeChemotherapy<9
UNION ALL
SELECT '4',SUM(CASE WHEN rf_idV006=3 THEN CountReason ELSE 0 END) AS Ambulance
		  ,SUM(CASE WHEN rf_idV006=1 THEN CountReason  ELSE 0 END) AS Stacionar
		  ,SUM(CASE WHEN rf_idV006=2 THEN CountReason  ELSE 0 END) AS DnevnoiStacionar
		  ,SUM(CountReason) AS AllCases
FROM #tmpCases
WHERE CountReason IS NOT NULL
UNION ALL
SELECT '4.1',SUM(CASE WHEN rf_idV006=3 THEN CountReason ELSE 0 END) AS Ambulance
			,SUM(CASE WHEN rf_idV006=1 THEN CountReason  ELSE 0 END) AS Stacionar
			,SUM(CASE WHEN rf_idV006=2 THEN CountReason  ELSE 0 END) AS DnevnoiStacionar
			,SUM(CountReason) AS AllCases
FROM #tmpCases
WHERE CountReason IS NOT NULL AND TypeChemotherapy<9
UNION ALL
SELECT '5',SUM(CASE WHEN rf_idV006=3 THEN ISReason ELSE 0 END) AS Ambulance
		  ,SUM(CASE WHEN rf_idV006=1 THEN ISReason  ELSE 0 END) AS Stacionar
		  ,SUM(CASE WHEN rf_idV006=2 THEN ISReason  ELSE 0 END) AS DnevnoiStacionar
		  ,SUM(ISReason) AS AllCases
FROM #tmpCases
WHERE ISReason IS NOT NULL
UNION ALL
SELECT '5.1',SUM(CASE WHEN rf_idV006=3 THEN ISReason ELSE 0 END) AS Ambulance
			,SUM(CASE WHEN rf_idV006=1 THEN ISReason  ELSE 0 END) AS Stacionar
			,SUM(CASE WHEN rf_idV006=2 THEN ISReason  ELSE 0 END) AS DnevnoiStacionar
			,SUM(ISReason) AS AllCases
FROM #tmpCases
WHERE ISReason IS NOT NULL AND TypeChemotherapy<9
GO
DROP TABLE #tmpCases
DROP TABLE #tmpReason
DROP TABLE #tCSG