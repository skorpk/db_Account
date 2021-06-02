USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME=GETDATE(),
		@reportYear SMALLINT=2020


SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,c.rf_idRecordCasePatient,f.CodeM, p.ENP,cc.DateBegin,cc.DateEnd
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_PatientSMO p ON
            p.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Meduslugi m ON
			m.rf_idCase = c.id
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND f.CodeM='521001'
	AND a.Letter='K' AND m.MUGroupCode=60 AND m.MUUnGroupCode=4

DECLARE @lpu_KT VARCHAR(150)

SELECT  @lpu_KT=CodeM+' - '+NAMES FROM vw_sprT001 WHERE CodeM='521001'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT distinct @lpu_KT,t.ENP,pp.Fam+' '+ISNULL(pp.Im,'')+' '+ISNULL(pp.Ot,'') AS FIO,t.DateBegin,t.DateEnd,f.CodeM+' - '+l.NAMES,a.Account,c.idRecordCase AS NumCase,cc.DateBegin AS DateStacBeg, cc.DateEnd AS DateStacEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_PatientSMO p ON
            p.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_RegisterPatient pp ON
            r.id=pp.rf_idRecordCase
			AND pp.rf_idFiles = f.id		
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN #t t ON
			p.enp=t.ENP				
					INNER JOIN dbo.vw_sprT001 l ON
            f.CodeM=l.CodeM
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND t.AmountPayment>0
	AND ((t.DateBegin BETWEEN cc.DateBegin  AND cc.DateEnd) or (t.DateEnd BETWEEN cc.DateBegin  AND cc.DateEnd))

GO
DROP TABLE #t