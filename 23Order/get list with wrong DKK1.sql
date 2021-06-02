USE AccountOMS
GO
CREATE TABLE #t(Dkk1 VARCHAR(20))
INSERT #t( Dkk1 )
VALUES('sh034'),('sh139'),('sh136'),('rb3'), ('rb4'), ('sh044'), ('sh039'), ('sh034'), ('sh136'), ('sh025'), ('sh082'), ('sh089'), ('rb5'), ('sh422'), ('sh255'), ('rb3') 


--SELECT DISTINCT f.CodeM,l.NAMES, a.rf_idSMO,a.Account,a.DateRegister,c.idRecordCase, c.id
SELECT DISTINCT ss.rf_idCase
INTO #td
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN dbo.t_SendingDataIntoFFOMS ss ON
		c.id = ss.rf_idCase
				INNER JOIN #t t ON
		ss.Dkk1=t.Dkk1
				INNER JOIN dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM				
WHERE ss.ReportMonth=7 AND ss.K_KSG IN ('148','149','341','57','150','140','155')

BEGIN TRANSACTION
DELETE FROM dbo.t_SendingDataIntoFFOMS 
FROM dbo.t_SendingDataIntoFFOMS s INNER JOIN #td t ON
			s.rf_idCase=t.rf_idCase
commit

GO 
DROP TABLE #t
DROP TABLE #td