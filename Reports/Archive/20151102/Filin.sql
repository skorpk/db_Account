USE AccountOMS
GO
DECLARE @dtStart DATETIME='20150101',
		@dtEnd DATETIME='20151008 23:59:59',
		@reportYear SMALLINT=2015,
		@dtRPDEnd datetime='20151020'

		
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  AmountPayment DECIMAL(11,2), 
					  PeopleID INT,
					  rf_idV006 TINYINT					  					  
					  )
					  
INSERT #tPeople (rf_idCase,CodeM,AmountPayment,rf_idV006,PeopleID)
SELECT c.id,f.CodeM,c.AmountPayment,c.rf_idV006,c1.IDPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN [SRVSQL1-ST2].AccountOMSReports.dbo.t_People_Case c1 ON
			c.id=c1.rf_idCase
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<10 AND c.DateEnd>'20150101'
		AND c.DateEnd<'20151001'
--------------------------------------Проставляем принятую оплату по случаю---------------------------
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

/*
--этот запрос нужно оптимизировать
UPDATE p SET p.PeopleID=c.ID
FROM #tPeople p INNER JOIN (
								 SELECT  CAST(PID AS varchar(20)) AS ID, rf_idCase FROM  dbo.t_Case_PID_ENP WHERE PID IS NOT NULL
								 UNION ALL
								 SELECT ENP AS ID, rf_idCase FROM  dbo.t_Case_PID_ENP WHERE  PID IS NULL AND ENP IS NOT null
								  UNION 
								 SELECT        rp.Fam + rp.Im + ISNULL(rp.Ot,'НЕТ') + CONVERT(VARCHAR(10), rp.BirthDay, 104), c.id
								 FROM            dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient r ON 
														c.rf_idRecordCasePatient = r.id 
																INNER JOIN dbo.t_RegistersAccounts a ON 
														r.rf_idRegistersAccounts = a.id 
																INNER JOIN dbo.t_File f ON 
														a.rf_idFiles = f.id 
																INNER JOIN dbo.t_RegisterPatient rp ON 
														r.id = rp.rf_idRecordCase
																LEFT JOIN dbo.t_Case_PID_ENP pid ON
														c.id=pid.rf_idCase
								 WHERE pid.rf_idCase IS NULL AND c.DateEnd>'20150101' AND c.DateEnd<'20151001'
							) c ON p.rf_idCase=c.rf_idCase
*/


--Итоговый запрос
SELECT rf_idV006,COUNT(DISTINCT PeopleID) AS TotalPeople
from #tPeople WHERE AmountPayment>0 GROUP BY rf_idV006 ORDER BY rf_idV006
GO
DROP TABLE #tPeople