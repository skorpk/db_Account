USE AccountOMS
GO
DECLARE @dtStart DATETIME='20180101',
		@dtEnd DATETIME='20181001',
		@dtEndRAK DATETIME='20181010',
		@reportMM TINYINT=9,
		@reportYear SMALLINT=2018

SELECT MU, 1 AS TypeCol
INTO #tMU
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=79 AND MUCode>1 AND MUCode<52
UNION ALL
SELECT MU, 1
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=81
UNION ALL
SELECT MU, 1
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=88 AND MUCode>=1 AND MUCode<40
UNION ALL
SELECT MU, 2
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=80 AND MUCode>1 AND MUCode<29
UNION ALL
SELECT MU, 2
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=82
UNION ALL
SELECT MU, 3
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=78 AND MUCode>1 AND MUCode<47
UNION ALL
SELECT MU, 3
FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=89

/*
SELECT f.CodeM, c.id, c.AmountPayment AS AmountPaymentAccepted,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient													
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mm ON
		d.DS1=mm.DiagnosisCode  
				INNER JOIN dbo.t_Meduslugi m ON 
		c.id=m.rf_idCase   
				INNER JOIN #tMU t ON
		m.MU=t.MU    
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181001' AND TypeCol=2 AND c.rf_idV006=3 /*AND c.rf_idV002 IN(60,18,12)*/ AND mm.MainDS LIKE 'C8[1-5]'
*/

SELECT f.CodeM, c.id, c.AmountPayment AS AmountPaymentAccepted,c.rf_idV002, SUM(m.Quantity) AS Quantity, t.TypeCol
		, CASE WHEN Age>17 THEN 0 ELSE 1 END AS IsChild
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient													
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mm ON
		d.DS1=mm.DiagnosisCode  
				INNER JOIN dbo.t_Meduslugi m ON 
		c.id=m.rf_idCase   
				INNER JOIN #tMU t ON
		m.MU=t.MU    
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181001' AND c.rf_idV006=3 AND c.rf_idV002 IN(60,18,12) AND mm.MainDS LIKE 'C8[1-5]'
GROUP BY f.CodeM, c.id, c.AmountPayment ,c.rf_idV002, t.TypeCol, CASE WHEN Age>17 THEN 0 ELSE 1 END 
UNION ALL
SELECT f.CodeM, c.id, c.AmountPayment AS AmountPaymentAccepted,c.rf_idV002, m.Quantity, t.TypeCol
		, CASE WHEN Age>17 THEN 0 ELSE 1 END AS IsChild
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient													
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mm ON
		d.DS1=mm.DiagnosisCode  
				INNER JOIN dbo.t_MES m ON 
		c.id=m.rf_idCase   
				INNER JOIN #tMU t ON
		m.MES=t.MU    
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20181001' AND c.rf_idV006=3 AND c.rf_idV002 IN(60,18,12) AND mm.MainDS LIKE 'C8[1-5]'

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase


SELECT p.CodeM,p.CodeM+' - '+l.NAMES,'Онкология'
	,SUM(CASE WHEN TypeCol=1 THEN Quantity ELSE 0 END) AS Col1
	,SUM(CASE WHEN TypeCol=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col2
	,SUM(CASE WHEN TypeCol=1 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col3
	-------------------------------------------------
	,SUM(CASE WHEN TypeCol=2 THEN Quantity ELSE 0 END) AS Col4
	,SUM(CASE WHEN TypeCol=2 THEN AmountPaymentAccepted ELSE .0 END) AS Col5
	,SUM(CASE WHEN TypeCol=2 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col6
	-------------------------------------------------
	,SUM(CASE WHEN TypeCol=3 THEN Quantity ELSE 0 END) AS Col7
	,SUM(CASE WHEN TypeCol=3 THEN AmountPaymentAccepted ELSE .0 END) AS Col8
	,SUM(CASE WHEN TypeCol=3 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col9
from #tmpPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
WHERE AmountPaymentAccepted>0 AND rf_idV002 IN(60,18)
GROUP BY p.CodeM,p.CodeM+' - '+l.NAMES
UNION ALL
SELECT p.CodeM,p.CodeM+' - '+l.NAMES,'гематология'
	,SUM(CASE WHEN TypeCol=1 THEN Quantity ELSE 0 END) AS Col1
	,SUM(CASE WHEN TypeCol=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col2
	,SUM(CASE WHEN TypeCol=1 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col3
	-------------------------------------------------
	,SUM(CASE WHEN TypeCol=2 THEN Quantity ELSE 0 END) AS Col4
	,SUM(CASE WHEN TypeCol=2 THEN AmountPaymentAccepted ELSE .0 END) AS Col5
	,SUM(CASE WHEN TypeCol=2 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col6
	-------------------------------------------------
	,SUM(CASE WHEN TypeCol=3 THEN Quantity ELSE 0 END) AS Col7
	,SUM(CASE WHEN TypeCol=3 THEN AmountPaymentAccepted ELSE .0 END) AS Col8
	,SUM(CASE WHEN TypeCol=3 AND IsChild=1 THEN AmountPaymentAccepted ELSE .0 END) AS Col9
from #tmpPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
WHERE AmountPaymentAccepted>0 AND rf_idV002=12
GROUP BY p.CodeM,p.CodeM+' - '+l.NAMES
ORDER BY p.CodeM
GO
DROP TABLE #tmpPeople
go
DROP TABLE #tMU