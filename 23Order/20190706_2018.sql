USE AccountOMSReports
GO
SELECT COUNT(c.id)--,m.MES
--INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_mes m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>'20180101' AND f.DateRegistration<'20190201' AND a.ReportYear=2018 AND c.rf_idV006=1
AND c.rf_idv010=33 AND c.rf_idV008<>32	AND NOT EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS2018 WHERE rf_idCase=c.id)
	AND SUBSTRING(m.MES,3,1)='2' 
--GROUP BY m.MES

SELECT COUNT(c.id)--,m.MES
--INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_mes m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>'20180101' AND f.DateRegistration<'20190201' AND a.ReportYear=2018 AND c.rf_idV006=2
AND c.rf_idv010=43	AND NOT EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS2018 WHERE rf_idCase=c.id)
	AND SUBSTRING(m.MES,3,1)='2' 
          

