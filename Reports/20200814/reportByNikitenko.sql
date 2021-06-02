USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200725',
		@reportYear SMALLINT=2019
-----меняем PeopleAttach.dbo.nsb_21 на PeopleAttach.dbo.nsb_11
SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,f.CodeM,p.ENP,c.rf_idRecordCasePatient,cc.DateBegin,cc.DateEnd,n.nrec
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient		
				/*связь с таблице из СРЗ*/			
					INNER JOIN PeopleAttach.dbo.nsb_21 n ON
            n.penp = p.ENP
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase Cc ON
			r.id=cc.rf_idRecordCasePatient					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  a.rf_idSMO<>'34' AND f.TypeFile='F' 

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT n.fam+' '+n.im+' '+n.ot AS FIO,CAST(n.dr AS DATE),l.CodeM+' - '+l.NAMES,t.DateBegin,t.DateEnd
FROM PeopleAttach.dbo.nsb_21 n LEFT JOIN #t t ON
			n.nrec=t.nrec
			AND t.AmountPayment>0
					LEFT JOIN dbo.vw_sprT001 l ON
            t.CodeM=l.CodeM
--WHERE t.AmountPayment>0
GO
DROP TABLE #t
