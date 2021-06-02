USE AccountOMS--Reports
GO		
DECLARE @dtStart DATETIME='20140101',
		@dtEnd DATETIME='20150123 23:59:59',
		@reportYear SMALLINT=2014,
		@dtRPDEnd datetime='20150128'

		
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  AmountPayment DECIMAL(11,2)--, 
					  --AmountRAK DECIMAL(11,2) DEFAULT 0 NOT null,
					  )
					  
INSERT #tPeople (rf_idCase,CodeM,AmountPayment)
SELECT c.id,f.CodeM,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT  sc.rf_idCase, SUM(ISNULL(sc.AmountEKMP, 0) + ISNULL(sc.AmountMEE, 0) + ISNULL(sc.AmountMEK, 0)) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN ExchangeFinancing.dbo.t_DocumentOfCheckup p ON 
														f.id = p.rf_idAFile 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON 
														p.id = a.rf_idDocumentOfCheckup 
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedCase sc ON 
														a.id = sc.rf_idCheckedAccount
							WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtRPDEnd 
							GROUP BY sc.rf_idCase
							) r ON						
			p.rf_idCase=r.rf_idCase
			
SELECT COUNT(p.rf_idCase) AS Col3
FROM #tPeople p 
WHERE p.AmountPayment>0		
go

DROP TABLE #tPeople


