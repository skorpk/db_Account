USE AccountOMSReports
GO
DECLARE @dateBegin DATETIME='20150101',
		@dateEnd DATETIME='20151211 23:59:59',
		@dateEndRAK DATETIME='20151228 23:59:59'

CREATE TABLE #CasesDS
(
	CodeM VARCHAR(6),	
	id BIGINT,
	AmountPayment DECIMAL(11,2),
	MES VARCHAR(15),
	DateBegin DATE,
	DateEnd DATE,
	IDPeople INT,
	IsCrossDate TINYINT NOT NULL DEFAULT 0
)

CREATE TABLE #CasesS
(
	CodeM VARCHAR(6),	
	id BIGINT,
	DateBegin DATE,
	DateEnd DATE,
	IDPeople INT  
)


INSERT #CasesDS( CodeM ,id ,AmountPayment,DateBegin,DateEnd,MES)
SELECT f.CodeM,c.id,c.AmountPayment,c.DateBegin,c.DateEnd,m.MES
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase				
WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd AND a.ReportYear=2015 AND a.ReportMonth<12
	  AND m.MES IN('2500099','2500100') AND c.rf_idV006=2

------------------------------------------------------------------------------------------------------------------
INSERT #CasesS( CodeM ,id ,DateBegin,DateEnd)
SELECT f.CodeM,c.id,c.DateBegin,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd AND a.ReportYear=2015 AND a.ReportMonth<12
	  AND c.rf_idV006=1

UPDATE d SET d.IDPeople=c.IDPeople
FROM #CasesDS d INNER JOIN dbo.t_People_Case c ON
		d.id=c.rf_idCase

UPDATE d SET d.IDPeople=c.IDPeople
FROM #CasesS d INNER JOIN dbo.t_People_Case c ON
		d.id=c.rf_idCase
--------------------------Search cross date----------------

UPDATE ds SET ds.IsCrossDate=1
FROM #CasesDS ds INNER JOIN #CasesS s ON
		ds.IDPeople=s.IDPeople
		AND ds.DateBegin>=s.DateBegin 
		AND ds.DateBegin<=s.DateEnd
WHERE ds.IDPeople IS NOT NULL AND s.IDPeople IS NOT NULL 


UPDATE ds SET ds.IsCrossDate=1
FROM #CasesDS ds INNER JOIN #CasesS s ON
		ds.IDPeople=s.IDPeople
		AND ds.DateEnd>=s.DateBegin 
		AND ds.DateEnd<=s.DateEnd
WHERE ds.IDPeople IS NOT NULL AND s.IDPeople IS NOT NULL 
---------------------------------------------------------------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #CasesDS p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>=@dateBegin AND f.DateRegistration<@dateEndRAK 										
							GROUP BY rf_idCase
							) r ON
			p.id=r.rf_idCase
WHERE p.IsCrossDate=1


SELECT MES,COUNT(DISTINCT id) FROM #CasesDS WHERE AmountPayment>0 AND IsCrossDate=1 GROUP BY MES
go

DROP TABLE #CasesDS
DROP TABLE #CasesS

