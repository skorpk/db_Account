USE AccountOMS
GO
DECLARE @codeSMO CHAR(5)='34006'
CREATE TABLE #tPeople
(
	DateRegistration DATETIME,
	CodeM CHAR(6), 
	CodeSMO CHAR(5),
	Account VARCHAR(15), 
	DateAccount date,
	ReportMonth tinyint,
	ReportYear smallint,
	GUID_Case UNIQUEIDENTIFIER, 
	NumberCase int,
	AmountPayment DECIMAL(11,2),
	AmountDeduction	DECIMAL(11,2),
	id BIGINT
)

INSERT #tPeople (DateRegistration,CodeM,CodeSMO,Account,DateAccount,ReportMonth,ReportYear,GUID_Case,NumberCase,AmountPayment,id)
SELECT f.DateRegistration,f.CodeM, a.rf_idSMO,a.Account, a.DateRegister ,a.ReportMonth ,a.ReportYear ,c.GUID_Case, c.idRecordCase,c.AmountPayment,c.id
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO=@codeSMO
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
WHERE c.rf_idV006=1 AND f.DateRegistration>'20151101' AND f.DateRegistration<'20151205' AND a.ReportMonth=11 AND a.ReportYear=2015			                    

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>='20151101' AND f.DateRegistration<GETDATE()	 										
							GROUP BY rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT  CAST(DateRegistration AS DATE),p.CodeM, l.NAMES ,CodeSMO ,Account ,DateAccount ,ReportMonth 
		,ReportYear ,GUID_Case ,NumberCase ,AmountPayment--,AmountDeduction
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			 p.CodeM=l.CodeM 
WHERE CodeSMO=@codeSMO
ORDER BY p.CodeM,p.Account,p.NumberCase

/*
SET @codeSMO='34002'
SELECT  CAST(DateRegistration AS DATE),p.CodeM, l.NAMES ,CodeSMO ,Account ,DateAccount ,ReportMonth 
		,ReportYear ,GUID_Case ,NumberCase ,AmountPayment--,AmountDeduction
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			 p.CodeM=l.CodeM 
WHERE CodeSMO=@codeSMO
ORDER BY p.CodeM,p.Account,p.NumberCase

SET @codeSMO='34006'
SELECT  CAST(DateRegistration AS DATE),p.CodeM, l.NAMES ,CodeSMO ,Account ,DateAccount ,ReportMonth 
		,ReportYear ,GUID_Case ,NumberCase ,AmountPayment--,AmountDeduction
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			 p.CodeM=l.CodeM 
WHERE CodeSMO=@codeSMO
ORDER BY p.CodeM,p.Account,p.NumberCase
*/
GO
DROP TABLE #tPeople