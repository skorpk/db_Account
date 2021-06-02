USE AccountOMS
GO

IF OBJECT_ID('usp_ReportDDChild14', N'P') IS NOT NULL
	DROP PROC usp_ReportDDChild14
GO

CREATE PROCEDURE usp_ReportDDChild14 @dateStart DATETIME
	,@dateEnd DATETIME
AS
SELECT t.CodeM
	,l.NameS
	,SUM(t.Col3) AS Col3
	,SUM(t.Col4) AS Col4
	,SUM(t.Col3) + SUM(t.Col4) AS Col5
	,SUM(t.Col6) AS Col6
	,SUM(t.col7) AS Col7
	,SUM(t.Col6) + SUM(t.Col7) AS Col8
	,cast(SUM(t.Col3) AS MONEY) * 651.3 + cast(SUM(t.Col6) AS MONEY) * 1937.8 AS Col9
	,cast(SUM(t.Col4) AS MONEY) * 794.3 + cast(SUM(t.Col7) AS MONEY) * 1937.8 AS Col10
	,(cast(SUM(t.Col3) AS MONEY) * 651.3 + cast(SUM(t.Col6) AS MONEY) * 1937.8) + (cast(SUM(t.Col4) AS MONEY) * 794.3 + cast(SUM(t.Col7) AS MONEY) * 1937.8) AS Col11
FROM (
	SELECT CodeM
		,SUM(m.Quantity) AS Col3
		,0 AS Col4
		,0 AS Col6
		,0 AS Col7
	FROM t_File f
	INNER JOIN t_RegistersAccounts a ON f.id = a.rf_idFiles
	INNER JOIN t_RecordCasePatient p ON a.id = p.rf_idRegistersAccounts
	INNER JOIN t_Case c ON p.id = c.rf_idRecordCasePatient
	INNER JOIN t_Meduslugi m ON c.id = m.rf_idCase
	WHERE f.DateRegistration >= @dateStart
		AND f.DateRegistration <= @dateEnd
		AND a.Letter = 'D'
		AND m.MUInt = 7001001
		AND a.ReportYear=2012
	GROUP BY CodeM
	
	UNION ALL
	
	SELECT CodeM
		,0
		,SUM(m.Quantity)
		,0 
		,0
	FROM t_File f
	INNER JOIN t_RegistersAccounts a ON f.id = a.rf_idFiles
	INNER JOIN t_RecordCasePatient p ON a.id = p.rf_idRegistersAccounts
	INNER JOIN t_Case c ON p.id = c.rf_idRecordCasePatient
	INNER JOIN t_Meduslugi m ON c.id = m.rf_idCase
	WHERE f.DateRegistration >= @dateStart
		AND f.DateRegistration <= @dateEnd
		AND a.Letter = 'D'
		AND m.MUInt = 7001002
		AND a.ReportYear=2012
	GROUP BY CodeM
	
	UNION ALL
	
	SELECT CodeM
		,0
		,0
		,count(distinct m.rf_idCase)
		,0
	FROM t_File f
	INNER JOIN t_RegistersAccounts a ON f.id = a.rf_idFiles
	INNER JOIN t_RecordCasePatient p ON a.id = p.rf_idRegistersAccounts
	INNER JOIN t_Case c ON p.id = c.rf_idRecordCasePatient
	INNER JOIN vw_MUChild14D_Col6 m ON c.id = m.rf_idCase
	WHERE f.DateRegistration >= @dateStart
		AND f.DateRegistration <= @dateEnd
		AND a.Letter = 'D'
		AND a.ReportYear=2012
	GROUP BY CodeM
	
	UNION ALL
	
	SELECT CodeM
		,0
		,0
		,0
		,count(distinct m.rf_idCase)
	FROM t_File f
	INNER JOIN t_RegistersAccounts a ON f.id = a.rf_idFiles
	INNER JOIN t_RecordCasePatient p ON a.id = p.rf_idRegistersAccounts
	INNER JOIN t_Case c ON p.id = c.rf_idRecordCasePatient
	INNER JOIN vw_MUChild14D_Col7 m ON c.id = m.rf_idCase
	WHERE f.DateRegistration >= @dateStart
		AND f.DateRegistration <= @dateEnd
		AND a.Letter = 'D'
		AND a.ReportYear=2012
	GROUP BY CodeM
	) t
INNER JOIN dbo.vw_sprT001_Report l ON t.CodeM = l.CodeM
GROUP BY t.CodeM
	,l.NameS
ORDER BY CodeM
GO
