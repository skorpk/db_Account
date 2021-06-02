USE AccountOMS
GO
CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  MUSurgery VARCHAR(16),
					  DS VARCHAR(6),
					  rf_idV008 smallint
					  )
INSERT #tPeople( rf_idCase ,CodeM ,MUSurgery,DS,rf_idV008)
SELECT DISTINCT c.id,f.CodeM,m.MUSurgery,LEFT(d.DS1,5),c.rf_idV008
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles						
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.DS1 LIKE 'S72.%'												
WHERE f.DateRegistration>'20150101' AND f.DateRegistration<'20151127' AND a.ReportMonth>0 AND a.ReportMonth<12 AND a.ReportYear=2015
		AND c.rf_idV006=1 AND c.rf_idV002=100  AND c.rf_idV008 IN (31,32)

SELECT p.CodeM,l.NAMES,p.rf_idV008
		, COUNT(CASE WHEN p.DS='S72.0' THEN p.rf_idCase ELSE NULL END) AS 'S72.0'
		, COUNT(CASE WHEN p.DS='S72.1' THEN p.rf_idCase ELSE NULL END) AS 'S72.1'
		, COUNT(CASE WHEN p.DS='S72.2' THEN p.rf_idCase ELSE NULL END) AS 'S72.2'
		, COUNT(CASE WHEN p.DS='S72.0' AND ISNULL(MUSurgery,'bla') LIKE 'A16%' THEN p.rf_idCase ELSE NULL END) AS 'S72.0_Surgery'
		, COUNT(CASE WHEN p.DS='S72.1' AND ISNULL(MUSurgery,'bla') LIKE 'A16%' THEN p.rf_idCase ELSE NULL END) AS 'S72.1_Surgery'
		, COUNT(CASE WHEN p.DS='S72.2' AND ISNULL(MUSurgery,'bla') LIKE 'A16%' THEN p.rf_idCase ELSE NULL END) AS 'S72.2_Surgery'
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
GROUP BY p.CodeM,l.NAMES,p.rf_idV008
ORDER by CodeM, rf_idV008
go

DROP TABLE #tPeople


