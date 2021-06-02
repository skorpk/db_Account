USE AccountOMSReports
GO
CREATE TABLE #tmp(rf_idCase BIGINT, Sex CHAR(1), Age SMALLINT,IdPeople BIGINT,CodeM CHAR(6),MUGroupCode TINYINT,MUUnGroupCode TINYINT)

INSERT #tmp( rf_idCase, Sex, Age, IdPeople,CodeM,MUGroupCode,MUUnGroupCode)
SELECT c.id,p.Sex,c.Age,pid.IDPeople,f.CodeM,m.MUGroupCode,m.MUUnGroupCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				  INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				  INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
				  INNER JOIN dbo.t_RegisterPatient p ON
			f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase
					INNER JOIN dbo.t_People_Case pid ON
			c.id=pid.rf_idCase
					inner join t_Meduslugi m on
			c.id=m.rf_idCase						
			and m.MUGroupCode=71
			and m.MUUnGroupCode IN (1,2)
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<'20140708' AND a.ReportYear=2014 AND a.ReportMonth>=1 AND a.ReportMonth<7
		AND c.DateEnd>'20140101' AND c.DateEnd<='20140701' AND c.rf_idV006=4
		
SELECT l.filialCode,l.CodeM,l.NAMES,'Row73' Column3,COUNT(DISTINCT IdPeople) Column4 
FROM #tmp t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
GROUP BY l.filialCode,l.CodeM,l.NAMES
UNION all
SELECT l.filialCode,l.CodeM,l.NAMES,'Row74',COUNT(DISTINCT IdPeople) 
FROM #tmp t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
WHERE Age<18 
GROUP BY l.filialCode,l.CodeM,l.NAMES
UNION all
SELECT l.filialCode,l.CodeM,l.NAMES,'Row75',COUNT(distinct IdPeople) 
FROM #tmp t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
WHERE (Sex='Æ' AND Age>54) OR  (Sex='Ì' AND Age>59)
GROUP BY l.filialCode,l.CodeM,l.NAMES
UNION ALL
SELECT l.filialCode,l.CodeM,l.NAMES,'Row76',COUNT(DISTINCT IdPeople ) 
FROM #tmp t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
WHERE MUGroupCode=71 AND MUUnGroupCode=2 AND t.CodeM<>'806501' 
GROUP BY l.filialCode,l.CodeM,l.NAMES
ORDER BY l.filialCode,l.CodeM,Column3

--SELECT 'Row74',	COUNT(DISTINCT IdPeople),COUNT(IdPeople)  FROM #tmp WHERE Age<18 
go
DROP TABLE #tmp				  
				  