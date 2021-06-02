USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20191211',
		@reportYear SMALLINT=2019



SELECT c.id AS rf_idCase, c.AmountPayment,p.id,p.HospitalizationPeriod
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase p ON
			r.id=p.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND f.CodeM='161007'
		AND c.rf_idv008=31

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
CREATE TABLE #tTotal
(
----------------------------- Group #1---------------------------------
Col1 INT not null default 0,
Col2 INT not null default 0,
Col3 decimal(15,2) not null default 0.0,
----------------------------- Group #2---------------------------------
Col4 INT not null default 0,
Col5 INT not null default 0,
Col6 decimal(15,2) not null default 0.0,
----------------------------- Group #3---------------------------------
Col7 INT not null default 0,
Col8 INT not null default 0,
Col9 decimal(15,2) not null default 0.0,
----------------------------- Group #4---------------------------------
Col10 INT not null default 0,
Col11 INT not null default 0,
Col12 decimal(15,2) not null default 0.0,
----------------------------- Group #5---------------------------------
Col13 INT not null default 0,
Col14 INT not null default 0,
Col15 decimal(15,2)	not null default 0.0
)
----------------------------- Group #1---------------------------------
;WITH cte
AS(
SELECT DISTINCT c.id,c.HospitalizationPeriod,c.AmountPayment
FROM #tCases c
WHERE AmountPayment>0
)
INSERT #tTotal(Col1,Col2,Col3)
SELECT COUNT(id) AS Col1,SUM(cte.HospitalizationPeriod) AS Col2,SUM(cte.AmountPayment) AS Col3 FROM cte
----------------------------- Group #2---------------------------------
;WITH cte
AS(
SELECT DISTINCT c.id,c.HospitalizationPeriod,c.AmountPayment
FROM #tCases c
WHERE AmountPayment>0 AND c.HospitalizationPeriod<4
)
INSERT #tTotal(Col4,Col5,Col6)
SELECT COUNT(id) AS Col4,SUM(cte.HospitalizationPeriod) AS Col5,SUM(cte.AmountPayment) AS Col6 FROM cte
----------------------------- Group #3---------------------------------
;WITH cte
AS(
SELECT DISTINCT c.id,c.HospitalizationPeriod,c.AmountPayment
FROM #tCases c INNER JOIN dbo.t_Kiro k ON
		c.rf_idCase=k.rf_idCase
WHERE AmountPayment>0 AND c.HospitalizationPeriod<4 AND k.rf_idKiro IN(2,4)
)
INSERT #tTotal(Col7,Col8,Col9)
SELECT COUNT(id) AS Col7,SUM(cte.HospitalizationPeriod) AS Col8,SUM(cte.AmountPayment) AS Col9 FROM cte
----------------------------- Group #4---------------------------------
;WITH cte
AS(
SELECT DISTINCT c.id,c.HospitalizationPeriod,c.AmountPayment
FROM #tCases c INNER JOIN dbo.t_Kiro k ON
		c.rf_idCase=k.rf_idCase
WHERE AmountPayment>0 AND c.HospitalizationPeriod<4 AND k.rf_idKiro IN(1,3)
)
INSERT #tTotal(Col10,Col11,Col12)
SELECT COUNT(id) AS Col10,SUM(cte.HospitalizationPeriod) AS Col11,SUM(cte.AmountPayment) AS Col12 FROM cte
----------------------------- Group #5---------------------------------
;WITH cte
AS(
SELECT DISTINCT c.id,c.HospitalizationPeriod,c.AmountPayment
FROM #tCases c INNER JOIN dbo.t_Kiro k ON
		c.rf_idCase=k.rf_idCase
WHERE AmountPayment>0 AND c.HospitalizationPeriod<4 AND k.rf_idKiro IN(5,6)
)
INSERT #tTotal(Col13,Col14,Col5)
SELECT COUNT(id) AS Col13,ISNULL(SUM(cte.HospitalizationPeriod),0.0) AS Col14,ISNULL(SUM(cte.AmountPayment),0.0) AS Col15 FROM cte 

SELECT sum(Col1), sum(Col2),sum(Col3),sum(Col4),sum(Col5),sum(Col6),sum(Col7),sum(Col8),sum(Col9),sum(Col10),sum(Col11),sum(Col12),sum(Col13),sum(Col14),sum(Col15)
FROM #tTotal
GO

DROP TABLE #tCases
DROP TABLE #tTotal
