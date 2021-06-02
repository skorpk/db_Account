USE AccountOMS
GO

CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  ReportMonth TINYINT,					 
					  FIO VARCHAR(120), 
					  DR DATE, 
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2),
					  AmountRPD DECIMAL(11,2)
					  )


INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,FIO,DR,AmountPayment)
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,''),p.BirthDay,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.Letter='U'
			AND f.CodeM='511001'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient										
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<'20140228' AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>='20130101' AND DateRegistration<'20140904' AND a.Letter='U'	AND a.CodeM='511001'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
--------------------------------------Update information about RPD---------------------------
UPDATE p SET p.AmountRPD=AmountPaymentAccept
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountPaymentAccept) AS AmountPaymentAccept 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaidCase a 
							WHERE DateRegistration>='20130101' AND DateRegistration<'20140904' AND a.Letter='U' AND a.CodeM='511001'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
					
SELECT rf_idCase,FIO,Dr,DateBegin,DateEnd,CAST(ISNULL(AmountRAK,0) AS MONEY),CAST(ISNULL(AmountRPD,0) AS MONEY) FROM #tPeople /*WHERE ISNULL(AmountRAK,-1)>0*/ ORDER BY FIO

go

DROP TABLE #tPeople


