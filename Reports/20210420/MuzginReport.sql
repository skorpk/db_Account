USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20210101',
		@dateEndReg DATETIME='20210416',
		@reportYear SMALLINT=2021,
		@reportMonth TINYINT=3

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,cc.id AS rf_idCompletedCase,m.MUUnGroupCode
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth
AND c.rf_idV006=3 AND m.MUGroupCode=60 AND m.MUUnGroupCode IN(5,7)  AND a.rf_idSMO<>'34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM #tCases cc join dbo.t_PaymentAcceptedCase2 c ON
										cc.rf_idCase=c.rf_idCase
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0


----------------------------------------60.5.*-----------------------------
DECLARE @muCode TINYINT=5
;WITH cteMU5
as
(
SELECT ROW_NUMBER() OVER(PARTITION BY f.CodeM,a.Account,a.DateRegister,c.idRecordCase,p.ENP ORDER BY m.mu) AS idRow,					f.CodeM,a.Account,a.DateRegister,c.idRecordCase,p.ENP,cc.DateBegin,cc.DateEnd,m.MU,cc.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					JOIN (
							SELECT enp, MUUnGroupCode FROM #tCases WHERE MUUnGroupCode=@muCode GROUP BY enp, MUUnGroupCode HAVING COUNT(*)>1
						 ) d ON
            p.enp=d.ENP			
					JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase			
			AND m.MUUnGroupCode=d.MUUnGroupCode		
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth
AND c.rf_idV006=3 AND m.MUGroupCode=60 AND m.MUUnGroupCode=@muCode AND a.rf_idSMO<>'34'
)
SELECT c.CodeM,l.NAMES,c.Account,c.DateRegister,c.idRecordCase,c.ENP,c.DateBegin,c.DateEnd,c.MU+' - '+m.MUName,CAST(c.AmountPayment AS MONEY)
FROM cteMU5 c JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
			JOIN dbo.vw_sprMU m ON
        c.MU=m.MU
WHERE c.idRow=1
ORDER BY c.CodeM,c.ENP
---------------------------------------------60.7.*---------------------
SET @muCode=7
;WITH cteMU5
as
(
SELECT ROW_NUMBER() OVER(PARTITION BY f.CodeM,a.Account,a.DateRegister,c.idRecordCase,p.ENP ORDER BY m.mu) AS idRow,					f.CodeM,a.Account,a.DateRegister,c.idRecordCase,p.ENP,cc.DateBegin,cc.DateEnd,m.MU,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					JOIN (
							SELECT enp, MUUnGroupCode FROM #tCases WHERE MUUnGroupCode=@muCode GROUP BY enp, MUUnGroupCode HAVING COUNT(*)>1
						 ) d ON
            p.enp=d.ENP			
					JOIN dbo.t_Meduslugi m ON
            c.id=m.rf_idCase			
			AND m.MUUnGroupCode=d.MUUnGroupCode		
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth
AND c.rf_idV006=3 AND m.MUGroupCode=60 AND m.MUUnGroupCode=@muCode AND a.rf_idSMO<>'34'
)
SELECT c.CodeM,l.NAMES,c.Account,c.DateRegister,c.idRecordCase,c.ENP,c.DateBegin,c.DateEnd,c.MU+' - '+m.MUName,CAST(c.AmountPayment AS MONEY)
FROM cteMU5 c JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
			JOIN dbo.vw_sprMU m ON
        c.MU=m.MU
WHERE c.idRow=1
ORDER BY c.CodeM,c.ENP
GO
DROP TABLE #tCases