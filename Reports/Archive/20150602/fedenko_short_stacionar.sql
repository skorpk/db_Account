USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20150430 23:59:59',
		@dateEndPay DATETIME='20150601 23:59:59',
		@reportYear smallint=2015
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  AmountPayment DECIMAL(11,2),
					  DateBegin DATE,
					  DateEnd DATE,
					  CodeM CHAR(6),
					  CodeKSG VARCHAR(16)
					  )


INSERT #tPeople( rf_idCase ,AmountPayment ,DateBegin ,DateEnd ,CodeM, CodeKSG)
SELECT c.id,c.AmountPayment, c.DateBegin,c.DateEnd,f.CodeM,m.MES 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
			AND a.rf_idSMO<>'34'															
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient																
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=4 AND a.ReportYear=@reportYear
		AND c.rf_idV006=1 AND c.rf_idV008=31 AND c.rf_idV002<>158 AND c.rf_idV009 NOT IN(105,106) AND DATEDIFF(d,c.DateBegin,c.DateEnd)<4


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay	 
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase		



			
SELECT l.CodeM,l.NAMES,p.CodeKSG,COUNT(p.rf_idCase) AS CountCases, CAST(SUM(p.AmountPayment) AS MONEY) AS AmountAllCases
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
WHERE p.AmountPayment>0		
GROUP BY l.CodeM,l.NAMES,p.CodeKSG
ORDER BY CodeM
GO
DROP TABLE #tPeople