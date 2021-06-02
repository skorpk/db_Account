USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME=GETDATE(),
		@reportYear smallint=2016,
		@caseStart DATE,
		@caseEnd DATE

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101', @caseEnd=CAST(@reportYear AS CHAR(4))+'1231'

CREATE TABLE #tRSLT(rf_idV009 smallint)

INSERT #tRSLT( rf_idV009 ) VALUES  (325), (323), (324), (349), (350), (351), (334), (335), (336), (339), (340), (341)


SELECT c.id AS rf_idCase,c.rf_idV014, c.rf_idV009, c.AmountPayment, a.Letter, ch.id AS PID, c.rf_idV006, f.CodeM, r.AttachLPU
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              
				INNER JOIN dbo.t_Case_PID_ENP ce ON
		c.id=ce.rf_idCase	
				INNER JOIN PeopleAttach.dbo.Children ch on
		ce.pid=ch.id
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND ch.ry=@reportYear

INSERT #tPeople  
SELECT c.id AS rf_idCase,c.rf_idV014, c.rf_idV009, c.AmountPayment, a.Letter, ch.id AS PID,rf_idV006, f.CodeM, r.AttachLPU
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              
				INNER JOIN dbo.t_Case_PID_ENP ce ON
		c.id=ce.rf_idCase	
				INNER JOIN PeopleAttach.dbo.Children ch on
		ce.ENP=ch.enp
		AND ce.pid IS NULL
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND ch.ry=@reportYear  

UPDATE ch SET ch.IsDispUchet=1
FROM #tPeople p INNER JOIN #tRSLT r ON
		p.rf_idV009=r.rf_idV009
				INNER JOIN PeopleAttach.dbo.children ch ON
		p.pid=ch.ID              
WHERE p.Letter IN('D','F','V','I','U') AND ch.ry=@reportYear
GO
DROP TABLE #tPeople
DROP TABLE #tRSLT