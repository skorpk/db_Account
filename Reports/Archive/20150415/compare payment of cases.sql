USE AccountOMS
GO
DECLARE @dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear smallint=2014
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  SMO VARCHAR(5),
					  GUI_Case UNIQUEIDENTIFIER,
					  NumberCase  BIGINT,
					  Account VARCHAR(15),
					  ReportMonth TINYINT,					 					  
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2),
					  AmountRPD DECIMAL(11,2)
					  )


INSERT #tPeople( rf_idCase,NumberCase,GUI_Case ,CodeM ,Account ,AmountPayment,SMO,ReportMonth)
SELECT c.id,c.idRecordCase,c.GUID_Case,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO, a.ReportMonth
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles																
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=@reportYear
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT  sc.rf_idCase, SUM(ISNULL(sc.AmountEKMP, 0) + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0)) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
														f.id = p.rf_idAFile 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
														p.id = a.rf_idDocumentOfCheckup 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
														a.id = sc.rf_idCheckedAccount
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay
							GROUP BY sc.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------------------Update information about RPD---------------------------
UPDATE p SET p.AmountRPD=AmountPaymentAccept
FROM #tPeople p INNER JOIN (
							SELECT        sc.rf_idCase, SUM(sc.AmountPayment) AS AmountPaymentAccept
							FROM            ExchangeFinancing.dbo.t_DFileIn f INNER JOIN
													 ExchangeFinancing.dbo.t_PaymentDocument p ON f.id = p.rf_idDFile INNER JOIN
													 ExchangeFinancing.dbo.t_SettledAccount a ON p.id = a.rf_idPaymentDocument INNER JOIN
													 ExchangeFinancing.dbo.t_SettledCase sc ON a.id = sc.rf_idSettledAccount
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay
							GROUP BY sc.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
					
SELECT l.CodeM,l.NAMES,SMO,Account,@reportYear,ReportMonth,NumberCase,GUI_Case,CAST(AmountPayment AS MONEY) AS AmountPayment 
	,CAST(AmountRAK AS MONEY) AS AmountRAK,CAST(AmountRPD AS MONEY) AS AmountRPD
FROM #tPeople p INNER JOIN vw_sprT001 l ON
		p.CodeM=l.CodeM
WHERE AmountRAK<>AmountRPD
ORDER BY l.CodeM,SMO
go

DROP TABLE #tPeople


