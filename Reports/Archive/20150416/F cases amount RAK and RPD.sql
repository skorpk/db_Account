USE AccountOMS
GO
DECLARE @dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear smallint=2015,
		@letter CHAR(1)='F'
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  Step TINYINT,
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2),
					  AmountRPD DECIMAL(11,2) NOT NULL DEFAULT 0
					  )


INSERT #tPeople( rf_idCase,Step,AmountPayment)
SELECT c.id,CASE WHEN c.IsCompletedCase=0 THEN 2 ELSE c.IsCompletedCase END,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles																
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																				
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=3 AND a.ReportYear=@reportYear
		AND a.Letter=@letter

--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay AND Letter=@letter 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------------------Update information about RPD---------------------------
UPDATE p SET p.AmountRPD=AmountPaymentAccept
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountPaymentAccept) AS AmountPaymentAccept 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaidCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay AND Letter=@letter
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
					
SELECT COUNT(CASE WHEN step=1 AND AmountRAK>0 then rf_idCase ELSE NULL END) AS RAK_1,
		COUNT(CASE WHEN step=2 AND AmountRAK>0 then rf_idCase ELSE NULL END) AS RAK_2,
		COUNT(CASE WHEN step=1 AND AmountRPD>0 then rf_idCase ELSE NULL END) AS RPD_1,
		COUNT(CASE WHEN step=2 AND AmountRPD>0 then rf_idCase ELSE NULL END) AS RPD_2
FROM #tPeople 

SELECT TOP 10 * FROM #tPeople
go

DROP TABLE #tPeople


