USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@dateEndPay DATETIME=GETDATE(),
		@reportYear SMALLINT=2019




SELECT c.id AS rf_idCase, c.AmountPayment ,c.AmountPayment AS AmountPaymentAcc,c.AmountPayment AS AmountPaymentALL,p.ENP,a.Account,a.DateRegister,c.idRecordCase
		,c.NumberHistoryCase, c.DateBegin,c.DateEnd, a.rf_idSMO, dt.rf_idV024, d.DS1,l.fio,ls
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase                  
					INNER JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase	
			--------вставить список с людьми
					INNER JOIN PeopleAttach..sk_list l ON
			p.ENP=l.enp                  
					INNER JOIN dbo.t_DrugTherapy dt ON
			c.id=dt.rf_idCase																	                 
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND f.CodeM='103001' AND u.rf_idN013=2
		AND c.rf_idV006<3 AND dt.rf_idV020 IN('000300','002120','002121') AND c.rf_idV002=60


UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaymentALL=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT distinct c.ENP,c.fio,c.Account, c.DateRegister,c.idRecordCase,c.NumberHistoryCase,c.DS1,c.DateBegin,c.DateEnd,c.rf_idSMO,c.rf_idV024,v24.DKKNAME
		,c.ls,c.AmountPayment,c.AmountPaymentALL
		,DocumentNumber+ ' от ' +convert(CHAR(10),DocumentDate,104)
FROM #tCases c 	INNER JOIN oms_nsi.dbo.sprV024 v24 ON
		c.rf_idV024=v24.IDDKK
				left JOIN (SELECT rf_idCase ,TypeCheckup,DocumentNumber,DocumentDate from dbo.t_PaymentAcceptedCase2 WHERE TypeCheckup IN(2,3) AND DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	) p ON
		c.rf_idCase=p.rf_idCase 
WHERE c.AmountPaymentAcc>0 

--SELECT distinct c.ENP,c.fio,c.Account, c.DateRegister,c.idRecordCase,c.NumberHistoryCase,c.DS1,c.DateBegin,c.DateEnd,c.rf_idSMO,c.rf_idV024
--		,c.ls,c.AmountPayment,c.AmountPaymentALL
--FROM #tCases c 
--WHERE c.AmountPaymentAcc>0 
go

DROP TABLE #tCases

