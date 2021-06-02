USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME=GETDATE(),
		@dateStartRPD DATETIME='20190210',	--всегда с 10 числа отчетного мес€ца
		@dateEndRPD DATETIME='20190310',
		@reportYear SMALLINT,
		@reportMonth TINYINT

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'

--отчетный мес€ц и год будит мес€ц и год от даты регистрации –ѕƒ
SET @reportMonth=MONTH(@dateStartRPD)
SET @reportYear=YEAR(@dateStartRPD)



SELECT distinct f.id, cc.AmountPayment,cc.id AS rf_idCompletedCase,c.id AS rf_idCase,c.GUID_Case,c.AmountPayment AS SUM_M,f.CodeM, c.rf_idV006
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     
					INNER JOIN dbo.t_ProfileOfBed b ON
			c.id=b.rf_idCase       
					INNER JOIN dbo.t_SlipOfPaper s ON
			c.id=s.rf_idCase      
					 INNER JOIN dbo.t_DS_ONK_REAB dso ON
			c.id=dso.rf_idCase                   
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase     
			--		INNER JOIN dbo.t_PaidCase p ON --прикручиваем только случаи оплаченные
			--C.ID=p.rf_idCase           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth=@reportMonth AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34' 
		AND c.rf_idV006<4 AND c.rf_idV008=32 
		--AND p.DateRegistration BETWEEN @dateStartRPD AND @dateEndRPD AND p.AmountPaymentAccept>0
		AND NOT EXISTS(SELECT 1 FROM dbo.t_260order_VMP WHERE rf_idCase=c.id) 
UNION ALL
SELECT distinct f.id, cc.AmountPayment,cc.id AS rf_idCompletedCase,c.id AS rf_idCase,c.GUID_Case,c.AmountPayment AS SUM_M ,f.CodeM ,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     					
					 INNER JOIN dbo.t_DS_ONK_REAB dso ON
			c.id=dso.rf_idCase                   
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34' 
		AND c.rf_idV006<4 AND c.rf_idV008<>32		
		AND NOT EXISTS(SELECT 1 FROM dbo.t_260order_ONK WHERE rf_idCase=c.id) 

UPDATE p SET p.SUM_M=p.SUM_M-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT rf_idV006, COUNT(rf_idCompletedCase) AS Col2, SUM(Sum_m) AS Col3
		,COUNT(CASE WHEN CodeM='103001' THEN rf_idCompletedCase ELSE NULL END) AS col4
		,sum(CASE WHEN CodeM='103001' THEN sum_M ELSE 0.0 END) AS col5
FROM #tCases c
WHERE SUM_M>0
GROUP BY rf_idV006
ORDER BY rf_idV006

GO
DROP TABLE #tD
DROP TABLE #tCases
