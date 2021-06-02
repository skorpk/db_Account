USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',	--всегда с начало года
		@dateEnd DATETIME='20190311',
		@reportYear SMALLINT=2018,
		@dateEndAkt DATETIME='20190311'		

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,ps.ENP,m.MES, c.AmountPayment AS AmountPay ,a.ReportYear, r.AttachLPU,f.CodeM,c.rf_idV009 AS RSLT,pp.DN		
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     										     
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  
					left JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					LEFT JOIN dbo.t_PurposeOfVisit pp ON
			c.id=pp.rf_idCase																			   					  					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006<4 AND f.TypeFile='H' --AND c.rf_idV010<>32 

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT * FROM #tCases WHERE AmountPay=0

GO
DROP TABLE #tCases
go
DROP TABLE #tD