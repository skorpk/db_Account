USE AccountOMS
GO
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  ReportYear SMALLINT,
					  Age TINYINT,
					  Quantity DECIMAL(6,2),
					  rf_idV006 TINYINT
					  )
---------------------2014----------------------------------------------------
INSERT #tPeople( rf_idCase ,CodeM ,ReportYear ,Age ,Quantity ,rf_idV006)
SELECT c.id,f.CodeM,a.ReportYear,c.Age,SUM(m.Quantity),c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
			--AND a.rf_idSMO<>'34'					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase												
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150301' AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2014
		AND c.rf_idV006 IN(1,2) AND m.MUSurgery LIKE 'A16%' AND c.rf_idV002=65 AND c.rf_idV008=31
GROUP BY c.id,f.CodeM,a.ReportYear,c.Age,c.rf_idV006
---------------------2015----------------------------------------------------
INSERT #tPeople( rf_idCase ,CodeM ,ReportYear ,Age ,Quantity ,rf_idV006)
SELECT c.id,f.CodeM,a.ReportYear,c.Age,SUM(m.Quantity),c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
			--AND a.rf_idSMO<>'34'					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase												
WHERE f.DateRegistration>'20150101' AND f.DateRegistration<'20150710' AND a.ReportMonth>0 AND a.ReportMonth<7 AND a.ReportYear=2015
		AND c.rf_idV006 IN(1,2) AND m.MUSurgery LIKE 'A16%' AND c.rf_idV002=65 AND c.rf_idV008=31
GROUP BY c.id,f.CodeM,a.ReportYear,c.Age,c.rf_idV006

SELECT p.CodeM,l.NAMES,v006.name
		, COUNT(CASE WHEN p.ReportYear=2014 AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col1
		, COUNT(CASE WHEN p.ReportYear=2014 AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col2
		, sum(CASE WHEN p.ReportYear=2014 AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col3
		, sum(CASE WHEN p.ReportYear=2014 AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col4
		--------------------2015-------------------------
		, COUNT(CASE WHEN p.ReportYear=2015 AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col1
		, COUNT(CASE WHEN p.ReportYear=2015 AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col2
		,   sum(CASE WHEN p.ReportYear=2015 AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col3
		,   sum(CASE WHEN p.ReportYear=2015 AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col4
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV006 v006 ON
		p.rf_idV006=v006.id              
GROUP BY p.CodeM,l.NAMES,v006.name
ORDER BY CodeM
go

DROP TABLE #tPeople


