USE AccountOMS
GO

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  DateRegistration DATETIME,
					  DateAccount DATE,
					  ReportMonth TINYINT,					 					  
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2) null,
					  AmountRPD DECIMAL(11,2) null,
					  CodeSMO CHAR(5),
					  NumberCase BIGINT 
					  )


INSERT #tPeople( rf_idCase ,CodeM ,Account,AmountPayment,CodeSMO,DateRegistration,DateAccount,NumberCase)
SELECT c.id,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,f.DateRegistration,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			--AND a.rf_idSMO<>'34'			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient															
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<GETDATE() AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013
UNION ALL
SELECT c.id,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,f.DateRegistration,a.DateRegister,c.idRecordCase
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient													
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportMonth>0 AND a.ReportMonth<7 AND a.ReportYear=2014
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase  GROUP  BY rf_idCase 
							) r ON
			p.rf_idCase=r.rf_idCase

	
			
					
SELECT p.CodeSMO,s.sNameS,p.CodeM,l.NAMES ,Account,DateAccount,NumberCase, CAST(AmountPayment AS MONEY),rf_idCase
FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
		p.CodeSMO=s.smocod
				INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
WHERE AmountRAK IS NULL
ORDER BY CodeM,DateRegistration,NumberCase
--------------------------------query 2 when RAK is not null and RPD is null--------------------------
--SELECT p.CodeSMO,s.sNameS,p.CodeM,l.NAMES ,Account,DateRegistration,DateAccount,NumberCase, FIO,Dr,DateBegin,p.DateEnd,CAST(AmountPayment AS MONEY),rf_idCase
--FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
--		p.CodeSMO=s.smocod
--				INNER JOIN dbo.vw_sprT001 l ON
--		p.CodeM=l.CodeM
--WHERE AmountRAK IS NOT NULL AND ISNULL(AmountRAK,-1)>0 AND AmountRPD IS NULL
--ORDER BY CodeM,DateRegistration,NumberCase
----------------------------------query 2 when RAK is null and RPD is not null--------------------------
--SELECT p.CodeSMO,s.sNameS,p.CodeM,l.NAMES ,Account,DateRegistration,DateAccount,NumberCase, FIO,Dr,DateBegin,p.DateEnd,CAST(AmountPayment AS MONEY),rf_idCase
--FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
--		p.CodeSMO=s.smocod
--				INNER JOIN dbo.vw_sprT001 l ON
--		p.CodeM=l.CodeM
--WHERE AmountRAK IS NULL AND AmountRPD IS NOT NULL
--ORDER BY CodeM,DateRegistration,NumberCase
GO
DROP TABLE #tPeople