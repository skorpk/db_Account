USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2019
	


SELECT c.rf_idRecordCasePatient
INTO #tmpPeople 
FROM t_File f INNER JOIN t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts                  
					INNER JOIN t_Case c ON
		r.id = c.rf_idRecordCasePatient 					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportMonth>9 AND a.ReportYear=@reportYear
	AND c.rf_idV006=2
GROUP BY c.rf_idRecordCasePatient
HAVING COUNT(*)>1

BEGIN TRANSACTION
UPDATE c SET c.VB_P=1
FROM dbo.t_CompletedCase c INNER JOIN #tmpPeople p ON
			c.rf_idRecordCasePatient=p.rf_idRecordCasePatient
commit
GO
DROP TABLE #tmpPeople
