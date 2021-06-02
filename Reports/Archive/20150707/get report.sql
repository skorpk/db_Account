USE AccountOMSReports
GO
DECLARE @startPeriod INT=201501,
		@endPeriod INT=201506,
		@startDateReg DATETIME='20150101',
		@endDateReg DATETIME=GETDATE(),
		@endDateRegRAK DATETIME='20150630 23:59:59'

CREATE TABLE #t(
	CodeM char(6) NULL,
	NAMES varchar(250) NULL,
	sNameS varchar(250) NULL,
	V006 varchar(254) NULL,
	V002 varchar(254) NULL,
	SNILS varchar(11) NULL,
	Child varchar(1) NOT NULL,
	Sex char(1) NULL,
	DS1 varchar(6) NULL,
	Diagnosis varchar(255) NOT NULL,
	Account varchar(15) NULL,
	DateAccount date NULL,
	NumberCase bigint NULL,
	Policy varchar(20) NULL,
	V009 varchar(254) NULL,
	AmountPayment decimal(11, 2) NULL,
	AmountDeduction decimal(38, 2) NULL,
	rf_idCase BIGINT,
	NumberOfAct VARCHAR(2000)
)

INSERT #t( CodeM ,NAMES , sNameS , V006 , V002 , SNILS , Child , Sex , DS1 , Diagnosis , Account , DateAccount , NumberCase , Policy , V009 , AmountPayment ,  rf_idCase)
SELECT  a.CodeM ,l.NAMES,s.sNameS,v006.name AS V006,v2.Name AS V002,a.SNILS ,
        CASE WHEN a.Child=0 THEN 'Â' ELSE 'Ä' END Child ,a.Sex,
		a.DS1 ,mkb.Diagnosis, a.Account ,a.DateAccount ,a.NumberCase ,a.Policy,
        v9.name AS V009, a.AmountPayment,a.rf_idCase 
FROM dbo.t_ReportAnalyzeDeath a INNER JOIN vw_sprT001 l ON
					a.CodeM=l.CodeM
								INNER JOIN dbo.vw_sprSMO s ON
					a.CodeSMO=s.smocod                              
								INNER JOIN dbo.vw_sprV006 v006 ON
					a.rf_idV006=v006.id                             
								INNER JOIN oms_nsi.dbo.sprV002 v2 ON
					a.rf_idV002=v2.Id 
								INNER JOIN dbo.vw_sprMKB10 mkb ON
					a.DS1=mkb.DiagnosisCode                               
								INNER JOIN dbo.vw_sprV009 v9 ON
					a.rf_idV009=v9.id                             
WHERE DateRegistration>@startDateReg AND DateRegistration<@endDateReg AND ReportYearMonth>=@startPeriod AND ReportYearMonth<=@endPeriod 

UPDATE a SET a.AmountDeduction=r.AmountDeduction
FROM #t a inner JOIN (SELECT rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction

											FROM dbo.t_PaymentAcceptedCase p						
											WHERE p.DateRegistration>=@startDateReg AND p.DateRegistration<@endDateRegRAK 
											GROUP BY rf_idCase
											) r ON
					a.rf_idCase=r.rf_idCase


UPDATE a SET NumberOfAct=pt.Akt
FROM #t a INNER JOIN (SELECT rf_idCase,( SELECT distinct t2.DocumentNumber+','+ CONVERT(VARCHAR(10),t2.DocumentDate,104)+','+t2.TypeCheckup+ ';' as 'data()' 
										from t_PaymentAcceptedCaseType t2           
										where t1.rf_idCase=t2.rf_idCase for xml path('') 
										) AS Akt
					 FROM t_PaymentAcceptedCaseType t1
					 WHERE  t1.DateRegistration>=@startDateReg AND t1.DateRegistration<@endDateRegRAK 
					 ) pt on a.rf_idCase=pt.rf_idCase

SELECT t.rf_idCase, CodeM ,NAMES ,sNameS ,V006 ,V002 ,SNILS ,Child ,Sex ,DS1 ,Diagnosis ,
        Account ,DateAccount ,NumberCase ,Policy ,V009 ,AmountPayment ,NumberOfAct,AmountDeduction 
FROM #t t 
go
DROP TABLE #t
