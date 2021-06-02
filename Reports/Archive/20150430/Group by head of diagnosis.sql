USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20150124',
		@dateEndPay DATETIME='20150128',
		@reportYear smallint=2014
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 CHAR(6),
					  AmountPayment DECIMAL(11,2) 
					  )


INSERT #tPeople( rf_idCase,DS1,AmountPayment)
SELECT c.id,RTRIM(d.DS1),c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles																
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase														
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=@reportYear
		AND c.rf_idV006=1 AND c.rf_idV008=31

--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
			
SELECT h.rf_HeadId,h.HeadName,COUNT(p.rf_idCase) AS CountCase,CAST(SUM(p.AmountPayment) AS MONEY) AS SumCase
FROM #tPeople p INNER JOIN (SELECT m.DiagnosisCode,h.rf_HeadId,h1.DiagnosisCodeB+' - '+h1.DiagnosisCodeE AS HeadName 
							FROM OMS_NSI.dbo.sprMKB m INNER JOIN oms_nsi.dbo.sprHeadUnGroup h ON
										m.rf_HeadUnGroupId=h.HeadUnGroupId
														INNER JOIN OMS_NSI.dbo.sprHead h1 ON
										h.rf_HeadId=h1.HeadId) h ON
			p.DS1=h.DiagnosisCode	
WHERE p.AmountPayment>0					
GROUP BY h.rf_HeadId,h.HeadName
ORDER BY h.rf_HeadId

go

DROP TABLE #tPeople


