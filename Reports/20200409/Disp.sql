USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200118',
		@reportYear SMALLINT=2019,
		@dateEndRAK DATETIME='20200122',
		@dateEndRPD DATETIME='20200124'


SELECT c.id AS rf_idCase, c.AmountPayment,f.CodeM,dd.TypeDisp, CAST(0.0 AS decimal(15,2)) AS AmountPay,(CASE WHEN a.rf_idSMO='34' THEN 2 ELSE 1 END) AS IsSMO
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DispInfo dd ON
            c.id=dd.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.Letter='O' 


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPay=r.AmountPay
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountPay
								FROM dbo.t_PaidCase c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndRPD
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT l.CodeM,l.NAMES AS LPU
		,COUNT(DISTINCT CASE WHEN c.IsSMO=1 AND c.AmountPay>0 AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.rf_idCase ELSE NULL END ) AS ColType1Case
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=1 AND c.AmountPay>0 AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.AmountPay ELSE 0.0 END ) AS money) AS ColType1Amount

		,COUNT(DISTINCT CASE WHEN c.IsSMO=1  AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.rf_idCase ELSE NULL END ) AS ColType1CaseAcc
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=1  AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.AmountPayment ELSE 0.0 END ) AS money) AS ColType1AmountAcc

		,COUNT(DISTINCT CASE WHEN c.IsSMO=1    and c.AmountPay>0  AND c.TypeDisp ='ÄÂ2'THEN c.rf_idCase ELSE NULL END ) AS ColType2Case
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=1 and c.AmountPay>0 AND c.TypeDisp='ÄÂ2' THEN c.AmountPay ELSE 0.0 END ) AS money) AS ColType2Amount
		,COUNT(DISTINCT CASE WHEN c.IsSMO=1  AND c.TypeDisp ='ÄÂ2'THEN c.rf_idCase ELSE NULL END ) AS ColType2CaseAcc
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=1  AND c.TypeDisp='ÄÂ2' THEN c.AmountPayment ELSE 0.0 END ) AS money) AS ColType2AmountAcc
		-------------------------------------------------------------------------------------
		,COUNT(DISTINCT CASE WHEN c.IsSMO=2 AND c.AmountPay>0 AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.rf_idCase ELSE NULL END ) AS ColType1Case34
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=2 AND c.AmountPay>0 AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.AmountPay ELSE 0.0 END ) AS money) AS ColType1Amount43
		,COUNT(DISTINCT CASE WHEN c.IsSMO=2 AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.rf_idCase ELSE NULL END ) AS ColType1CaseAcc43
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=2  AND c.TypeDisp IN('ÄÂ1','ÄÂ3') THEN c.AmountPayment ELSE 0.0 END ) AS money) AS ColType1AmountAcc34
		,COUNT(DISTINCT CASE WHEN c.IsSMO=2 and c.AmountPay>0  AND c.TypeDisp ='ÄÂ2'THEN c.rf_idCase ELSE NULL END ) AS ColType2Case34
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=2 and c.AmountPay>0 AND c.TypeDisp='ÄÂ2' THEN c.AmountPay ELSE 0.0 END ) AS money) AS ColType2Amount34
		,COUNT(DISTINCT CASE WHEN c.IsSMO=2 AND c.TypeDisp ='ÄÂ2'THEN c.rf_idCase ELSE NULL END ) AS ColType2CaseAcc34
		,CAST(SUM(DISTINCT CASE WHEN c.IsSMO=2  AND c.TypeDisp='ÄÂ2' THEN c.AmountPayment ELSE 0.0 END ) AS money) AS ColType2AmountAcc34		
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON	
		c.CodeM=l.CodeM
WHERE c.AmountPayment>0 --AND c.AmountPay>0
GROUP BY l.CodeM,l.NAMES 
ORDER BY l.CodeM
GO
DROP TABLE #tCases
 