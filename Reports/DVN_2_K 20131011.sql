USE AccountOMSReports
GO
DECLARE @reportYear SMALLINT=2013,
		@month TINYINT=9,
		@dateBegin DATETIME='20130501',
		@dateEnd DATETIME='20131008',
		@datePayment DATETIME='20131017'
				


CREATE table #tCase (CodeM CHAR(6),id bigint,Sex CHAR(1),rf_idV009 smallint,AmountPayment decimal(11,2),PeopleId BIGINT,AmountPaymentAccepted DECIMAL(15,2))

INSERT #tCase( CodeM, id, Sex, rf_idV009,AmountPayment )
SELECT t.CodeM,t.id,Sex,t.rf_idV009,t.AmountPayment
from (				
		SELECT f.CodeM,c.id,p.Sex,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles							
					AND a.ReportMonth=@month
					AND a.ReportYear=@reportYear
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='R' AND mu.MUGroupCode=72 AND MUUnGroupCode=1 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
		UNION ALL 
		SELECT f.CodeM,c.id,p.Sex,c.rf_idV009,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@month
					AND a.ReportYear=@reportYear
						  INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
						  INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
						  INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.IsCompletedCase=1
					AND c.DateEnd<=@dateEnd
					AND c.DateEnd>='20130101'
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase
							INNER JOIN dbo.vw_sprMUCompletedCase mu ON
					mes.MES=mu.MU
		WHERE a.Letter='R' AND mu.MUGroupCode=72 AND MUUnGroupCode=1 AND f.DateRegistration>=@dateBegin AND f.DateRegistration<=@dateEnd
	) t
	
	
UPDATE c SET c.PeopleID=p.IDPeople
FROM #tCase c INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase

				
UPDATE c SET c.AmountPaymentAccepted=p.AmountPaymentAccept
FROM #tCase c INNER JOIN (
						  SELECT rf_idCase,SUM(AmountPaymentAccept) AS AmountPaymentAccept
						  from dbo.t_PaidCase WHERE DateRegistration>'20130501' AND DateRegistration<getdate()
						  GROUP BY rf_idCase
						  ) p ON
				c.id=p.rf_idCase

--SELECT TOP 1 WITH TIES t1.PeopleId,t1.Sex, t1.id
--FROM #tCase t1 INNER JOIN #tCase t2 ON
--			t1.PeopleId=t2.PeopleId
--WHERE t1.Sex<>t2.Sex AND t1.id<>t2.id
--ORDER BY ROW_NUMBER() OVER(PARTITION BY t1.PeopleId ORDER BY t1.id desc)

UPDATE c SET c.Sex=p.Sex
FROM #tCase c INNER JOIN (SELECT TOP 1 WITH TIES t1.PeopleId,t1.Sex, t1.id
							FROM #tCase t1 INNER JOIN #tCase t2 ON
										t1.PeopleId=t2.PeopleId
							WHERE t1.Sex<>t2.Sex AND t1.id<>t2.id
							ORDER BY ROW_NUMBER() OVER(PARTITION BY t1.PeopleId ORDER BY t1.id asc) 
						  ) p ON
			c.PeopleId=p.PeopleId
											
SELECT t1.PeopleId
FROM #tCase t1 INNER JOIN #tCase t2 ON
			t1.PeopleId=t2.PeopleId
WHERE t1.Sex<>t2.Sex AND t1.id<>t2.id

	
SELECT 'Всего взрослых' AS Col1
		,CAST(SUM(AmountPayment)/1000 AS money) AS Col3
		,COUNT(DISTINCT PeopleId) AS Col4
		,CAST(SUM(AmountPaymentAccepted)/1000 AS money) AS Col5 
FROM #tCase	
UNION ALL
SELECT 'МУЖ' AS Col1
		,CAST(SUM(AmountPayment)/1000 AS money) AS Col3
		,COUNT(DISTINCT PeopleId) AS Col4
		,CAST(SUM(AmountPaymentAccepted)/1000 AS money) AS Col5
FROM #tCase	WHERE sex='М'
UNION ALL 
SELECT 'ЖЕН' AS Col1
		,CAST(SUM(AmountPayment)/1000 AS money) AS Col3
		,COUNT(DISTINCT PeopleId) AS Col4
		,CAST(SUM(AmountPaymentAccepted)/1000 AS money) AS Col5
FROM #tCase	WHERE sex='Ж'




go
DROP TABLE #tCase	
	
		