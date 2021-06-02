USE AccountOMS
GO		
DECLARE @idV006 TINYINT=1,
		@dtBegin DATETIME='20160101',	
		@dtEnd DATETIME='20161201'
				
SELECT c.id AS rf_idCase,c.AmountPayment,e.TypeCheckup ,e.AmountMEE ,e.AmountEKMP ,e.AmountMEK,e.AmountDeduction,NULL AS Reason
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (SELECT c.rf_idCase,d.TypeCheckup,c.AmountMEE,c.AmountEKMP,c.AmountMEK,c.AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																																				
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<@dtEnd AND AmountDeduction>0								
							) e on
			c.id=e.rf_idCase
WHERE f.DateRegistration>@dtBegin AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND a.ReportMonth<10 AND a.rf_idSMO='34006' AND c.rf_idV006=@idV006

ALTER TABLE #tmpCases ADD AmountPaymentAccept DECIMAL(11,2) NOT NULL DEFAULT 0.0

UPDATE c SET c.AmountPaymentAccept=p.AmountPayment
from #tmpCases c INNER JOIN (
							SELECT p.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
							from #tmpCases c INNER JOIN [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaidCase p ON
										c.rf_idCase=p.rf_idCase
							WHERE p.DateRegistration>@dtBegin AND p.DateRegistration<@dtEnd
							GROUP BY p.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase                          

;WITH cte
AS(
SELECT MIN(r.id) AS MinID,c.rf_idCase
FROM ExchangeFinancing.dbo.t_ReasonDenialPayment r INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
			r.rf_idCheckedCase=c.id
GROUP BY c.rf_idCase
) 
UPDATE t SET Reason=r.CodeReason
FROM ExchangeFinancing.dbo.t_ReasonDenialPayment r INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
			r.rf_idCheckedCase=c.id							
						INNER JOIN #tmpCases t ON
			c.rf_idCase=t.rf_idCase
WHERE EXISTS(SELECT * FROM cte WHERE MinID=r.id AND rf_idCase=c.rf_idCase)



SELECT RTRIM(f.Reason)+' '+f.Name,
		-------------------------------------MEK------------------------------
		CAST(SUM(CASE WHEN t.TypeCheckup=1 THEN t.AmountPayment ELSE 0 END) AS MONEY) AS sumAccountMEK,
		cast(count(CASE WHEN t.TypeCheckup=1 THEN t.rf_idCase ELSE NULL end) AS MONEY) AS CountCasesMEK, 
		cast(SUM(CASE WHEN t.TypeCheckup=1 THEN t.AmountMEK ELSE 0 END) AS MONEY) AS SumDeductionMek,
		cast(SUM(CASE WHEN t.TypeCheckup=1 THEN t.AmountPaymentAccept ELSE 0 END) AS MONEY) AS SumPaymentAcceptMEK, 0 AS ReasonMEK
		-------------------------------------MEE------------------------------
	   ,cast(SUM(CASE WHEN t.TypeCheckup=2 THEN t.AmountPayment ELSE 0 END) AS MONEY) AS sumAccountMEE,
		cast(count(CASE WHEN t.TypeCheckup=2 THEN t.rf_idCase ELSE NULL end) AS MONEY) AS CountCasesMEE, 
		cast(SUM(CASE WHEN t.TypeCheckup=2 THEN t.AmountMEE ELSE 0 END) AS MONEY) AS SumDeductionMee,
		cast(SUM(CASE WHEN t.TypeCheckup=2 THEN t.AmountPaymentAccept ELSE 0 END) AS MONEY) AS SumPaymentAcceptMEE, 0 AS ReasonMEE
		-------------------------------------EKMP------------------------------
	   ,cast(SUM(CASE WHEN t.TypeCheckup=3 THEN t.AmountPayment ELSE 0 END) AS MONEY) AS sumAccountEKMP,
		cast(count(CASE WHEN t.TypeCheckup=3 THEN t.rf_idCase ELSE NULL end) AS MONEY) AS CountCasesEKMP, 
		cast(SUM(CASE WHEN t.TypeCheckup=3 THEN t.AmountEKMP ELSE 0 END) AS MONEY) AS SumDeductionEKMP,
		cast(SUM(CASE WHEN t.TypeCheckup=3 THEN t.AmountPaymentAccept ELSE 0 END) AS MONEY) AS SumPaymentAcceptEKMP, 0 AS ReasonEKMP
		------------------------------------Total------------------------------
		,CAST(count(rf_idCase) AS MONEY) AS CountCasesTotal
		,CAST(ISNULL(SUM(AmountDeduction),0) AS MONEY) AS SumDeduction
FROM #tmpCases t RIGHT JOIN oms_nsi.dbo.sprF014 f ON
			t.Reason=f.id 
GROUP BY RTRIM(f.Reason)+' '+f.Name
go 
DROP TABLE #tmpCases
