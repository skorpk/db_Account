USE AccountOMS
GO
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  ReportYear SMALLINT,
					  Age TINYINT,
					  Quantity DECIMAL(6,2),
					  MUSurgery VARCHAR(16)
					  )
---------------------2014----------------------------------------------------
INSERT #tPeople( rf_idCase ,CodeM ,ReportYear ,Age ,Quantity ,MUSurgery)
SELECT c.id,f.CodeM,a.ReportYear,c.Age,SUM(m.Quantity),m.MUSurgery
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase		
					INNER JOIN (VALUES('A16.26.092'), ('A16.26.092.001'), ('A16.26.093'), ('A16.26.093.001'), ('A16.26.094'),('A16.26.096')) t(MUSurgery) ON
			m.MUSurgery=t.MUSurgery
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20150301' AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2014
		AND c.rf_idV006=1 AND c.rf_idV002=65 AND c.rf_idV008=31
GROUP BY c.id,f.CodeM,a.ReportYear,c.Age,m.MUSurgery
---------------------2015----------------------------------------------------
INSERT #tPeople( rf_idCase ,CodeM ,ReportYear ,Age ,Quantity ,MUSurgery)
SELECT c.id,f.CodeM,a.ReportYear,c.Age,SUM(m.Quantity),m.MUSurgery
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase			
					INNER JOIN (VALUES('A16.26.092'), ('A16.26.092.001'), ('A16.26.093'), ('A16.26.093.001'), ('A16.26.094'),('A16.26.096')) t(MUSurgery) ON
			m.MUSurgery=t.MUSurgery									
WHERE f.DateRegistration>'20150101' AND f.DateRegistration<'20150710' AND a.ReportMonth>0 AND a.ReportMonth<7 AND a.ReportYear=2015
		AND c.rf_idV006=1 AND c.rf_idV002=65 AND c.rf_idV008=31
GROUP BY c.id,f.CodeM,a.ReportYear,c.Age,m.MUSurgery

SELECT p.CodeM,l.NAMES
		-----------------------------------------------------------------------------------------------------------------------		
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col3
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092.001' AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col4
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery= 'A16.26.093'    AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col5
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.093.001' AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col6
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.094'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col7
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.096'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col8

		-----------------------------------------------------------------------------------------------------------------------		
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col9
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092.001' AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col10
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery= 'A16.26.093'    AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col11
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.093.001' AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col12
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.094'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col13
		, COUNT(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.096'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col14
		-----------------------------------------------------------------------------------------------------------------------		
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092'     AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col15
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092.001' AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col16
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery= 'A16.26.093'    AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col17
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.093.001' AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col18
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.094'     AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col19
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.096'     AND p.Age>17 THEN isnull(p.Quantity,0) ELSE 0 END) AS Col20

		-----------------------------------------------------------------------------------------------------------------------		
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col21
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.092.001' AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col22
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery= 'A16.26.093'    AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col23
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.093.001' AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col24
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.094'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col25
		, SUM(CASE WHEN p.ReportYear=2014 AND MUSurgery='A16.26.096'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col26
		----------------------------------------------2015---------------------------------------------------------------------
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col27
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092.001' AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col28
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery= 'A16.26.093'    AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col29
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.093.001' AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col30
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.094'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col31
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.096'     AND p.Age>17 THEN p.rf_idCase ELSE NULL END) AS Col32

		-----------------------------------------------------------------------------------------------------------------------		
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col33
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092.001' AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col34
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery= 'A16.26.093'    AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col35
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.093.001' AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col36
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.094'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col37
		, COUNT(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.096'     AND p.Age<18 THEN p.rf_idCase ELSE NULL END) AS Col38
		-----------------------------------------------------------------------------------------------------------------------		
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092'     AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col39
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092.001' AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col40
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery= 'A16.26.093'    AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col41
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.093.001' AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col42
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.094'     AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col43
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.096'     AND p.Age>17 THEN p.Quantity ELSE 0 END) AS Col44
		--------------------------------------------------------------------------------------------------------------------		
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col45
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.092.001' AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col46
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery= 'A16.26.093'    AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col47
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.093.001' AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col48
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.094'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col49
		, SUM(CASE WHEN p.ReportYear=2015 AND MUSurgery='A16.26.096'     AND p.Age<18 THEN p.Quantity ELSE 0 END) AS Col50
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM			
GROUP BY p.CodeM,l.NAMES
ORDER BY CodeM
go

DROP TABLE #tPeople


