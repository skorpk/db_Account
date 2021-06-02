USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME=GETDATE(),
		@reportYear smallint=2017,
		@caseStart DATE,
		@caseEnd DATE

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101', @caseEnd=CAST(@reportYear AS CHAR(4))+'1231'

SELECT c.id AS rf_idCase, c.AmountPayment, a.Letter, 0 AS AmountPaid, p.ENP
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              				
				INNER JOIN dbo.t_RegisterPatient rp ON
		r.id=rp.rf_idRecordCase
		AND f.id=rp.rf_idFiles              
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.Letter='F' AND a.rf_idSMO<>'34' AND rp.BirthDay>='20000101' AND rp.BirthDay<'20030101'


UPDATE p SET p.AmountPaid=r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountPaymentAccept) AS AmountDeduction
								FROM dbo.t_PaidCase c
								WHERE c.DateRegistration>=@startDateReg AND c.DateRegistration<@endDateReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT rf_idCase) AS CountCase,COUNT(DISTINCT ENP) AS CountChild, SUM(AmountPaid)
FROM #tPeople
WHERE AmountPaid>0
GO
DROP TABLE #tPeople