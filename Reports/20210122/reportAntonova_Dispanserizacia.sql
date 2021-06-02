USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20201211',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=12,
		----------------------
		@dateStartReg2 DATETIME='20201211',
		@dateEndReg2 DATETIME=GETDATE(),
		@reportYear2 SMALLINT=2020


SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,11 AS ReportMonth,f.CodeM,p.id,dd.TypeDisp,a.Letter
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
					left JOIN dbo.t_DispInfo dd ON
            c.id=dd.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND f.TypeFile='F' 
		AND a.rf_idSMO<>'34' AND a.ReportMonth<@reportMonth
UNION ALL
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idv008,c.rf_idV006,12,f.CodeM,p.id,dd.TypeDisp,a.Letter
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
					left JOIN dbo.t_DispInfo dd ON
            c.id=dd.rf_idCase
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear AND c.rf_idV006=3 AND f.TypeFile='F' AND a.rf_idSMO<>'34' 
		


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg2 AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT c.CodeM,l.NAMES AS LPU
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='U' THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY) AS U_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='U' THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS U_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='U' THEN c.id ELSE null END)/11 AS U_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='U' THEN c.id ELSE null END) AS U_Dec_Case
		-----------------------Disp D-----------------------------------
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='D' THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY) AS D_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='D' THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS D_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='D' THEN c.id ELSE null END)/11 AS D_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='D' THEN c.id ELSE null END) AS D_Dec_Case
		-----------------------Disp F-----------------------------------
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='F' THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY) AS F_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='F' THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS F_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='F' THEN c.id ELSE null END)/11 AS F_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='F' THEN c.id ELSE null END) AS F_Dec_Case
		-----------------------Disp R-----------------------------------
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='R' THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY) AS R_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='R' THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS R_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='R' THEN c.id ELSE null END)/11 AS R_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='R' THEN c.id ELSE null END) AS R_Dec_Case
		-----------------------Disp O-----------------------------------
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='O' and TypeDisp in ('ÄÂ1','ÄÂ3') THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY) AS R_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='O' and TypeDisp in ('ÄÂ1','ÄÂ3') THEN c.AmountPayment ELSE 0.0 END) AS MONEY)AS R_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='O' and TypeDisp in ('ÄÂ1','ÄÂ3') THEN c.id ELSE null END)/11 AS R_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='O' and TypeDisp in ('ÄÂ1','ÄÂ3') THEN c.id ELSE null END) AS R_Dec_Case
		------------------------------------------------------------------------
		  ,CAST(SUM(CASE WHEN c.ReportMonth=11 AND c.Letter='O' and TypeDisp ='ÄÂ2' THEN c.AmountPayment ELSE 0.0 END)/11 AS MONEY)AS R_Nov_Suum
		  ,CAST(sum(CASE WHEN c.ReportMonth=12 AND c.Letter='O' and TypeDisp ='ÄÂ2' THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS R_Dec_Sum
		,count(CASE WHEN c.ReportMonth=11 AND c.Letter='O' and TypeDisp ='ÄÂ2' THEN c.id ELSE null END)/11 AS R_Nov_Case
		,count(CASE WHEN c.ReportMonth=12 AND c.Letter='O' and TypeDisp ='ÄÂ2' THEN c.id ELSE null END) AS R_Dec_Case
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		l.CodeM = c.CodeM
WHERE AmountPayment>0.0
GROUP BY c.CodeM,l.NAMES
ORDER BY c.CodeM
GO

DROP TABLE #tCases