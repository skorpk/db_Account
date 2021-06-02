USE AccountOMS
GO

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  DateRegistration DATETIME,
					  DateAccount DATE,
					  DateBegin DATE,
					  DateEnd DATE,				 					  
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2) null,
					  CodeSMO CHAR(5),
					  NumberCase BIGINT,
					  PID INT,
					  Reason VARCHAR(1000),
					  CodeM1 CHAR(6) NOT NULL DEFAULT('000000'),
					  ISReason TINYINT					
					  )


INSERT #tPeople( rf_idCase ,CodeM ,Account,AmountPayment,CodeSMO,DateRegistration,DateAccount,NumberCase,DateBegin,DateEnd)
--SELECT c.id,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,f.DateRegistration,a.DateRegister,c.idRecordCase,c.DateBegin,c.DateEnd
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles
--			AND a.rf_idSMO<>'34'			
--					INNER JOIN dbo.t_RecordCasePatient r ON
--			a.id=r.rf_idRegistersAccounts
--					INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCasePatient															
--			AND c.DateEnd>'20130101' AND c.DateEnd<'20140101'
--WHERE f.DateRegistration>'20130101' AND f.DateRegistration<GETDATE() AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013  AND a.Letter='O'
--UNION ALL
SELECT c.id,f.CodeM,a.Account,c.AmountPayment,a.rf_idSMO,f.DateRegistration,a.DateRegister,c.idRecordCase,c.DateBegin,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
			AND c.DateEnd>'20140101' AND c.DateEnd<'20140701'
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<GETDATE() AND a.ReportMonth>0 AND a.ReportMonth<7 AND a.ReportYear=2014   AND a.Letter='O'

---------------------------------------Update information about PID---------------------------------
UPDATE p SET p.pid=pid.PID
FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP pid ON
		p.rf_idCase=pid.rf_idCase
WHERE pid.PID IS NOT NULL					

--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(c.AmountEKMP+c.AmountMEE+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile													
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007' AND a.Account LIKE '%O'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET Reason=r.Reason
FROM #tPeople p INNER JOIN (SELECT rf_idCase, r.Reason 
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile													
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 
														INNER JOIN (select rf_idCheckedCase ,( SELECT distinct f014.Reason+ ';' as 'data()' 
																							   from ExchangeFinancing.dbo.t_ReasonDenialPayment t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
																													t2.CodeReason=f014.ID
																								where t1.rf_idCheckedCase=t2.rf_idCheckedCase for xml path('') 
																								) AS Reason
																from ExchangeFinancing.dbo.t_ReasonDenialPayment t1 group by rf_idCheckedCase) r ON
													c.id=r.rf_idCheckedCase
							WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007' AND a.Account LIKE '%O'
							GROUP BY rf_idCase,r.Reason 
							) r ON
			p.rf_idCase=r.rf_idCase	

UPDATE p SET ISReason=1
FROM #tPeople p INNER JOIN (SELECT rf_idCase 
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile													
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 
														INNER JOIN ExchangeFinancing.dbo.t_ReasonDenialPayment r on
													c.id=r.rf_idCheckedCase
														INNER JOIN (VALUES (70),(71)) v(CodeReason) ON
													r.CodeReason=v.CodeReason
							WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007' AND a.Account LIKE '%O'
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase				


UPDATE p SET CodeM1=p1.CodeM
FROM #tPeople p INNER JOIN (SELECT TOP 1 WITH TIES p.PID,CodeM,DateRegistration
							FROM #tPeople p inner JOIN (SELECT pid FROM #tPeople GROUP BY pid HAVING COUNT(*)>1) d ON
									p.pid=d.pid									
							ORDER BY ROW_NUMBER() OVER (PARTITION BY p.PID,CodeM ORDER BY DateRegistration asc)) p1 ON
			p.PID=p1.PID
WHERE p.IsReason=1


			
 
SELECT   
        LPU ,
        sNameS ,
        DocumentNumber ,
        DocumentDate ,Account,DateAccount,NumberCase,        
        DatePeriod ,
        AmountPayment ,Reason,
        '' columnEmpty ,
        NAMES
FROM (			
		SELECT TOP 100 PERCENT ROW_NUMBER() OVER(ORDER BY p.rf_idCase) AS id, p.CodeM+' - '+l.NAMES AS LPU, s.sNameS,d.DocumentNumber, d.DocumentDate
					, Account,DateAccount,NumberCase,
				CONVERT(CHAR(10),p.DateBegin,104)+' - '+CONVERT(CHAR(10), p.DateEnd, 104) AS DatePeriod, CAST(AmountPayment AS MONEY) AS AmountPayment
				,Reason,l1.NAMES
		FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
				p.CodeSMO=s.smocod
						INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
						INNER JOIN (SELECT TOP 1 WITH TIES rf_idCase,d.DocumentNumber,d.DocumentDate 
									FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
															f.id=d.rf_idAFile													
																		INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
															d.id=a.rf_idDocumentOfCheckup
																INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
															a.id=c.rf_idCheckedAccount 														
									WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007'
									ORDER BY ROW_NUMBER() OVER (PARTITION BY c.rf_idCase ORDER BY d.DocumentDate DESC, d.DocumentNumber DESC)
									)  d ON
				p.rf_idCase=d.rf_idCase
						inner JOIN (SELECT CodeM,NAMES from dbo.vw_sprT001 UNION ALL SELECT '000000','') l1 ON
				p.CodeM1=l1.CodeM
		WHERE AmountRAK =0
		ORDER BY LPU,Account,DateAccount,NumberCase
		) t
--WHERE id<35000

--SELECT  
--        LPU ,
--        sNameS ,
--        DocumentNumber ,
--        DocumentDate ,Account,DateAccount,NumberCase,        
--        DatePeriod ,
--        AmountPayment ,Reason,
--        '' columnEmpty ,
--        NAMES
--FROM (			
--		SELECT TOP 100 PERCENT ROW_NUMBER() OVER(ORDER BY p.rf_idCase) AS id, p.CodeM+' - '+l.NAMES AS LPU, s.sNameS,d.DocumentNumber, d.DocumentDate, Account,DateAccount,NumberCase,
--				CONVERT(CHAR(10),p.DateBegin,104)+' - '+CONVERT(CHAR(10), p.DateEnd, 104) AS DatePeriod, CAST(AmountPayment AS MONEY) AS AmountPayment
--				,Reason,l1.NAMES
--		FROM #tPeople p INNER JOIN dbo.vw_sprSMO s ON
--				p.CodeSMO=s.smocod
--						INNER JOIN dbo.vw_sprT001 l ON
--				p.CodeM=l.CodeM
--						INNER JOIN (SELECT TOP 1 WITH TIES rf_idCase,d.DocumentNumber,d.DocumentDate 
--									FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
--															f.id=d.rf_idAFile													
--																		INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
--															d.id=a.rf_idDocumentOfCheckup
--																INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
--															a.id=c.rf_idCheckedAccount 														
--									WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007'
--									ORDER BY ROW_NUMBER() OVER (PARTITION BY c.rf_idCase ORDER BY d.DocumentDate DESC, d.DocumentNumber DESC)
--									)  d ON
--				p.rf_idCase=d.rf_idCase
--						inner JOIN (SELECT CodeM,NAMES from dbo.vw_sprT001 UNION ALL SELECT '000000','') l1 ON
--				p.CodeM1=l1.CodeM
--		WHERE AmountRAK =0
--		ORDER BY LPU,Account,DateAccount,NumberCase
--		) t
--WHERE id>=35000		

GO
--DROP TABLE #tPeople