USE AccountOMS
GO
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME='20170629 23:59:59',
		@dtEndRegRAK DATETIME='20170630 23:59:59',
		@reportYear SMALLINT=2017,
		@reportMonth TINYINT=5

SELECT *
INTO #csg
FROM (
		SELECT 1 AS rf_idV006, code
		FROM dbo.vw_sprCSG WHERE code LIKE '_____03[1-3]'
		UNION ALL
		SELECT 1,code
		FROM dbo.vw_sprCSG WHERE code LIKE '_____14[2-6]'		
		-----Дневной стационар---------------
		UNION ALL
		SELECT 2,code
		FROM dbo.vw_sprCSG WHERE code LIKE '_____01[3-5]'
		UNION ALL
		SELECT 2,code
		FROM dbo.vw_sprCSG WHERE code LIKE '_____05[0-4]'
	) t
				

SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,pc.ENP,c.rf_idV006,pid
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #csg cs  ON
			m.MES=cs.code                  
			AND cs.rf_idV006=1
					inner JOIN dbo.t_Case_PID_ENP pc ON
			c.id=pc.rf_idCase       		          
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') AND c.rf_idV006=1
UNION ALL
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,pc.ENP,c.rf_idV006,pid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts							
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #csg cs  ON
			m.MES=cs.code     
			AND cs.rf_idV006=2
					inner JOIN dbo.t_Case_PID_ENP pc ON
			c.id=pc.rf_idCase       			    
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') 	 AND c.rf_idV006=2

UPDATE t SET t.ENP=p.ENP
FROM #tmp t INNER JOIN PolicyRegister.dbo.PEOPLE p on
		t.pid=p.id
WHERE t.ENP IS NULL


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
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndRegRAK
								GROUP BY c.rf_idCase 
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cteTotal
AS
(
	SELECT COUNT(DISTINCT ENP) AS People,COUNT(rf_idCase) AS Cases,SUM(AmountPayment) AS AmountPayment,0 AS MU
	FROM #tmp WHERE AmountPayment>0 AND rf_idV006=1
	UNION ALL
	SELECT 0 AS People,0 AS Cases,0 AS AmountPayment,SUM(Quantity) AS MU
	FROM #tmp c INNER JOIN dbo.t_Meduslugi m ON
			 c.rf_idCase=m.rf_idCase
	WHERE AmountPayment>0 AND m.MUGroupCode=1 AND rf_idV006=1
 )
SELECT  SUM(People) AS People,SUM(Cases) AS Cases,SUM(AmountPayment) AS AmountPayment,SUM(MU) AS MU FROM cteTotal


;WITH cteTotalDS
AS
(
	SELECT COUNT(DISTINCT ENP) AS People,COUNT(rf_idCase) AS Cases,SUM(AmountPayment) AS AmountPayment,0 AS MU
	FROM #tmp WHERE AmountPayment>0 AND rf_idV006=2
	UNION ALL
	SELECT 0 AS People,0 AS Cases,0 AS AmountPayment,SUM(Quantity) AS MU
	FROM #tmp c INNER JOIN dbo.t_Meduslugi m ON
			 c.rf_idCase=m.rf_idCase
	WHERE AmountPayment>0 AND m.MUGroupCode=55 AND rf_idV006=2
 )
SELECT  SUM(People) AS People,SUM(Cases) AS Cases,SUM(AmountPayment) AS AmountPayment,SUM(MU) AS MU FROM cteTotalDS
go
DROP TABLE #csg
DROP TABLE #tmp

