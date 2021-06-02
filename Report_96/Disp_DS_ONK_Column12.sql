USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190508',
		@reportYear SMALLINT=2019,
		@dateEndAkt DATETIME='20190508'		

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,r.AttachLPU, c.AmountPayment AS AmountPay ,f.CodeM, a.Letter
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_DispInfo dd ON
			c.id=dd.rf_idCase 			
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.IsOnko=1 AND f.TypeFile='F'

SELECT COUNT(rf_idCase) FROM #tCases --GROUP BY Letter 
go

DROP TABLE #tCases

