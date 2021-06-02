USE AccountOMS
GO

SELECT DISTINCT f.CodeM, c.id AS rf_idCase,c.GUID_Case,c.AmountPayment
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								
WHERE f.DateRegistration>'20160801' AND f.DateRegistration<'20160911' /*AND a.ReportYear=2016 AND a.ReportMonth=8 AND c.DateEnd>='20160801'*/ AND f.CodeM='395301'
--AND a.rf_idSMO<>'34'

SELECT SUM(AmountPayment) from #t

SELECT SUM(c.AmountPayment)
FROM #t t INNER JOIN RegisterCases.dbo.t_Case c ON
			t.GUID_Case = c.GUID_Case			
			INNER JOIN RegisterCases.dbo.t_RecordCaseBack rb ON
		c.id=rb.rf_idCase
			INNER JOIN RegisterCases.dbo.t_CaseBack cb ON
		rb.id=cb.rf_idRecordCaseBack          
WHERE /*c.DateEnd>='20160801'	AND c.DateEnd<'20160901' AND*/ cb.TypePay=1
go
DROP TABLE #t


