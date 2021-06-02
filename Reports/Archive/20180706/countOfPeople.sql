USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME=GETDATE(),
		@reportYear smallint=2016,
		@caseStart DATE,
		@caseEnd DATE

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101', @caseEnd=CAST(@reportYear AS CHAR(4))+'1231'

CREATE TABLE #tRSLT(rf_idV009 smallint)
CREATE TABLE #tMU(MU VARCHAR(9))

INSERT #tRSLT( rf_idV009 ) VALUES  (323), (324),(325),  (349), (350), (351), (334), (335), (336), (339), (340), (341)
INSERT #tMU( MU )
VALUES  ('2.88.2'),('2.88.3'),('2.88.6'),('2.88.7'),('2.88.8'),('2.88.9'),('2.88.11'),('2.88.13'),('2.88.14'),('2.88.15'),('2.88.16'),
		('2.88.17'),('2.88.21'),('2.88.23'),('2.88.25'),('2.88.26'),('2.88.27'),('2.88.28'),('2.88.29'),('2.88.30'),('2.88.32'),('2.88.33'),('2.88.34')


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

--UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
--FROM #tPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
--								FROM dbo.t_PaymentAcceptedCase c
--								WHERE c.DateRegistration>=@startDateReg AND c.DateRegistration<@endDateReg 
--								GROUP BY c.rf_idCase
--							) r ON
--			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT PID) AS Col2
FROM #tPeople p INNER JOIN #tRSLT r ON
		p.rf_idV009=r.rf_idV009
WHERE AmountPayment>0 AND Letter IN('D','F','V','I','U')

GO
DROP TABLE #tMU
DROP TABLE #tPeople
DROP TABLE #tRSLT