USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20210116',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20210119',
		@reportYear SMALLINT=2020

SELECT c.id AS rf_idCase, a.Account,a.DateRegister,c.idRecordCase,c.NumberHistoryCase,d.rf_idV020,d.rf_idV024,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,cc.AmountPayment
,cc.AmountPayment AS AmountPaymentMO,cc.DateBegin,cc.DateEnd
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles					
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_RegisterPatient p ON
            f.id=p.rf_idFiles
			AND r.id=p.rf_idRecordCase
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient			
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
					INNER JOIN t_DrugTherapy d ON
            c.id=d.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006<3 AND f.CodeM='103001'
	AND d.rf_idV020 IN('001691','002120','002121','001554','001705','000246','001276','001970','002031','002376')

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #t WHERE AmountPayment=0.0
PRINT('ÓäAëÿåì')

SELECT DISTINCT v24.IDDKK+' '+v24.DKKNAME AS schemaLek,n20.ID_LEKP,n20.MNN,t.Account,t.DateRegister,t.idRecordCase,FIO,t.NumberHistoryCase,t.DateBegin,t.DateEnd,CAST(t.AmountPaymentMO AS MONEY) 
FROM #t t INNER JOIN oms_nsi.dbo.sprN020 n20 on
		t.rf_idV020=n20.ID_LEKP
			INNER JOIN oms_nsi.dbo.sprV024 v24 on
		t.rf_idV024=v24.IDDKK
ORDER BY t.FIO,n20.ID_LEKP,schemaLek
GO
DROP TABLE #t