USE AccountOMS
GO
DECLARE @dateStart DATETIME='20140101',
		@dateEnd DATETIME='20150126 23:59:59'
		
CREATE table #LPU (CodeM VARCHAR(6))

INSERT #LPU(CodeM) VALUES('101003'),('114504'),('114506'),('121018'),('124528'),('124530'),('134505'),('134510'),('141016'),('141022'),('141023'),
						 ('141024'),('154602'),('154608'),('154620'),('161007'),('161015'),('174601'),('175709'),('184512'),('184603'),('251001'),
						 ('251003'),('254504'),('254505'),('255802'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),
						 ('371001'),('381001'),('391001'),('401001'),('411001'),('421001'),('431001'),('441001'),('451001'),('461001'),('471001'),
						 ('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),('581001'),
						 ('591001'),('601001'),('611001'),('621001')


		

SELECT t.CodeM,l.NAMES
		,Sum(CASE WHEN t.rf_idV005=1 AND t.Age>29 THEN 1 ELSE 0 END) AS Man
		,SUM(CASE WHEN t.rf_idV005=2 AND t.Age>17 THEN 1 ELSE 0 END) AS Woman
FROM (
		SELECT TOP 1 WITH TIES f.CodeM,ce.PID,p.rf_idV005,c.Age
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.rf_idSMO<>'34'
							INNER JOIN #LPU l ON
					f.CodeM=l.CodeM
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_RegisterPatient p ON
					f.id=p.rf_idFiles
					AND r.id=p.rf_idRecordCase
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>='20140101' AND c.DateEnd<'20150101'
							INNER JOIN dbo.t_Case_PID_ENP ce ON
					c.id=ce.rf_idCase
					AND ce.ReportYear=2014
		WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2014 AND c.rf_idV006=3
				AND NOT EXISTS( SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MU LIKE '57.%') AND ce.PID IS NOT NULL
		ORDER BY ROW_NUMBER() OVER(PARTITION BY ce.pid ORDER BY c.DateBegin,f.DateRegistration) 
		) t INNER JOIN dbo.vw_sprT001 l ON
				t.CodeM=l.CodeM
GROUP BY t.CodeM,l.NAMES
ORDER BY t.CodeM