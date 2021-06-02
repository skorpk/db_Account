USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200910',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200910',
		@reportYear SMALLINT=2020


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,c.rf_idRecordCasePatient,f.CodeM,a.rf_idMO, a.ReportMonth,m.MES
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
					INNER JOIN t_Mes m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND m.MES IN('ds02.001','ds02.002','st01.001')
AND c.rf_idV010=33 --AND NOT EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS s WHERE s.rf_idCase=c.id)


SELECT mes,COUNT(DISTINCT s.rf_idCase)
FROM dbo.t_SendingDataIntoFFOMS s
WHERE mes  IN('ds02.001','ds02.002','st01.001')
GROUP BY mes
ORDER BY mes

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

/*
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd,c.AmountPayment, CAST(c.rf_idDepartmentMO AS VARCHAR(6)), 9,c.rf_idV010,0.0
FROM dbo.t_Case c INNER JOIN dbo.t_CompletedCase cc ON
			c.rf_idRecordCasePatient=cc.rf_idRecordCasePatient                  
					INNER JOIN #t t ON
            c.id=t.rf_idCase
WHERE  NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.MUGroupCode=60 AND m.MUUnGroupCode=3 AND m.rf_idCase=c.id)
	AND c.rf_idV010 =33 AND c.rf_idV006<3


SELECT DISTINCT CAST(p.DateRegistration AS DATE)
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN  #t t ON
			p.rf_idCase=t.rf_idCase
*/
--SELECT * FROM #t WHERE AmountPayment>0
SELECT mes,COUNT(rf_idRecordCasePatient) FROM #t GROUP BY mes ORDER BY mes


--SELECT t.rf_idMO,t.CodeM+' - '+l.NAMES AS LPU,COUNT(rf_idCase)
--FROM #t t INNER JOIN dbo.vw_sprT001 l ON
--		t.CodeM=l.CodeM
--WHERE AmountPayment>0
--GROUP BY t.rf_idMO,t.CodeM+' - '+l.NAMES 
--ORDER BY t.rf_idMO
GO
DROP TABLE #t