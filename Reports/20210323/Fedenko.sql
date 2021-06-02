USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME='20210323',
		@dateStartRegRAK DATETIME='20210123',
		@dateEndRegRAK DATETIME=GETDATE()

SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,k.rf_idKiro,c.rf_idRecordCasePatient,m.MES
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts												
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					JOIN (VALUES('171004'),('151005'),('173801')) v(CodeLPU) ON
            f.CodeM=v.CodeLPU
					JOIN t_Mes m ON
            c.id=m.rf_idCase
				    JOIN dbo.t_Kiro k ON
            c.id=k.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg   AND a.ReportYear=2021 AND a.ReportMonth<3 AND c.rf_idV006=1
AND m.mes IN ('st12.015','st12.016','st12.017','st12.018','st12.019') AND k.rf_idKiro IN(2,4)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0 

SELECT MES 
		,COUNT( DISTINCT CASE WHEN CodeM='171004' AND rf_idKiro =2 THEN rf_idRecordCasePatient ELSE NULL END) AS Col2
		,COUNT( DISTINCT CASE WHEN CodeM='171004' AND rf_idKiro =4 THEN rf_idRecordCasePatient ELSE NULL END) AS Col3
		------------------------------------------------------------------------------------------------------------
		,COUNT( DISTINCT CASE WHEN CodeM='151005' AND rf_idKiro =2 THEN rf_idRecordCasePatient ELSE NULL END) AS Col4
		,COUNT( DISTINCT CASE WHEN CodeM='151005' AND rf_idKiro =4 THEN rf_idRecordCasePatient ELSE NULL END) AS Col5
		------------------------------------------------------------------------------------------------------------
		,COUNT( DISTINCT CASE WHEN CodeM='173801' AND rf_idKiro =2 THEN rf_idRecordCasePatient ELSE NULL END) AS Col6
		,COUNT( DISTINCT CASE WHEN CodeM='173801' AND rf_idKiro =4 THEN rf_idRecordCasePatient ELSE NULL END) AS Col7
FROM #tCases
GROUP BY MES
order BY mes
GO
DROP TABLE #tCases