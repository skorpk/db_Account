USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,cc.id AS rf_idCompletedCase,cc.AmountPayment AS AmmPay,p.ENP,c.rf_idV006,cc.DateBegin,cc.DateEnd,f.CodeM
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006<3 AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						   FROM dbo.t_PaymentAcceptedCase2 c
						   WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay AND c.TypeCheckup>1
						   GROUP BY c.rf_idCase
						  ) r ON
			p.rf_idCase=r.rf_idCase

SELECT SUM(AmmPay) ,COUNT(DISTINCT rf_idCompletedCase) FROM #tCases WHERE AmountPayment=0.0

DELETE FROM #tCases WHERE AmountPayment>0.0
--SELECT * FROM #tCases

SELECT DISTINCT f.CodeM+' - '+l.Names AS LPU,a.Account,c.idRecordCase,c.GUID_Case,pp.Fam+' '+pp.Im+' '+ISNULL(pp.Ot,'') AS FIO,pp.BirthDay
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					JOIN dbo.t_PatientSMO p ON
    r.id=p.rf_idRecordCasePatient		
						INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					JOIN dbo.t_CompletedCase cc ON
            r.id=cc.rf_idRecordCasePatient			
					JOIN #tCases c1 ON
            p.ENP=c1.ENP
			AND c.rf_idV006=c1.rf_idV006
			AND cc.DateBegin=cc.DateBegin
			AND cc.DateEnd=cc.DateEnd
			AND f.CodeM=c1.CodeM
					JOIN dbo.t_RegisterPatient pp ON
			f.id=pp.rf_idFiles
			AND r.id=pp.rf_idRecordCase
					JOIN dbo.vw_sprT001 l ON
           f.CodeM=l.CodeM
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<GETDATE() AND a.ReportYear=2020 AND c.rf_idV006<3 AND a.rf_idSMO<>'34' 
		AND NOT EXISTS(SELECT 1 FROM #tCases ccc WHERE cc.id=ccc.rf_idCompletedCase)
	
GO
DROP TABLE #tCases