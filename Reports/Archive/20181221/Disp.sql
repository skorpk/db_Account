USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180801',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME='20181206',
		@reportYear SMALLINT=2018


SELECT c.id,c.DateBegin,c.DateEnd,p.BirthDay, DAY(c.DateBegin) AS DayBeg, DAY(p.BirthDay) AS DayDR, m.mes,
	DATEDIFF(MONTH,p.BirthDay,c.DateEnd) AS MMDif
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2018 AND p.BirthDay>'20180101' AND a.Letter='F'

SELECT * FROM #t WHERE DayBeg=DayDR	ORDER BY MMDif
SELECT *
FROM RegisterCases.dbo.t_AgeMU72_2 WHERE MU='72.2.42'
go

DROP TABLE #t