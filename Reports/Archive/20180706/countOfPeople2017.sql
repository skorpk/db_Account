USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME=GETDATE(),
		@reportYear smallint=2017,
		@caseStart DATE,
		@caseEnd DATE

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101', @caseEnd=CAST(@reportYear AS CHAR(4))+'1231'

SELECT c.id AS rf_idCase,c.rf_idV014, c.rf_idV009, c.AmountPayment, a.Letter, ch.ENP AS PID, c.rf_idV006, f.CodeM, r.AttachLPU
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
		ce.ENP=ch.ENP
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND ch.ry=@reportYear


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase c
								WHERE c.DateRegistration>=@startDateReg AND c.DateRegistration<@endDateReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT p.PID) 
FROM #tPeople p INNER JOIN dbo.t_DS2_Info r ON
		p.rf_idCase=r.rf_idCase				
WHERE p.AmountPayment>0 AND r.IsNeedDisp IN(1,2) AND p.Letter IN('D','F','V','I','U') 
GO
DROP TABLE #tPeople