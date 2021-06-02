USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150101',
		@dateEnd DATETIME='20160126',
		@dateEndPay DATETIME='20160128',
		@reportYear SMALLINT=2015

CREATE TABLE #tPeople(		
					  rf_idCase BIGINT,					 
					  codeM CHAR(6),
					  DateBeg DATE,
					  DateEnd DATE,
					  rf_idV002 SMALLINT,
					  DS varCHAR(10),
					  AmountPayment decimal(11,2)
					  )

INSERT #tPeople( rf_idCase, CodeM ,rf_idV002 ,DS ,AmountPayment,DateBeg,DateEnd)
SELECT c.id,f.CodeM,c.rf_idV002,d.DiagnosisCode,c.AmountPayment,c.DateBegin,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND c.rf_idV006=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
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
--DROP TABLE tmpMatveeva

SELECT p.codeM+' - '+l.NAMES AS LPU, v2.Name AS Profil,p.rf_idCase,CASE WHEN DATEDIFF(day,p.DateBeg,p.DateEnd)=0 THEN 1 ELSE DATEDIFF(day,p.DateBeg,p.DateEnd) end KoikoDen,
		p.DS, mkb.Diagnosis
INTO tmpMatveeva
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.codeM=l.CodeM
				INNER JOIN oms_nsi.dbo.sprV002 v2 ON
		p.rf_idV002=v2.Id              
				INNER JOIN dbo.vw_sprMKB10 mkb ON
		p.DS=mkb.DiagnosisCode              
WHERE AmountPayment>0
GO
DROP TABLE #tPeople