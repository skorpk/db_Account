USE AccountOMS
GO

CREATE TABLE #tPeople(rf_idCase BIGINT,					  					  				 					  
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2) NULL,
					  PID int
					  )


INSERT #tPeople( rf_idCase ,AmountPayment)
SELECT c.id,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
			AND c.DateEnd>='20130101' AND c.DateEnd<'20140101'
			INNER JOIN (VALUES(3),(23)) v(t) ON 
			c.IsSpecialCase=v.t														
WHERE f.DateRegistration>'20130101' AND f.DateRegistration<GETDATE() AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013 AND a.Letter='O'  
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(c.AmountEKMP+c.AmountMEE+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile													
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 														
							WHERE f.DateRegistration>='20130101' AND f.DateRegistration<'20141007' --AND a.Account LIKE '%O'
							GROUP BY rf_idCase 
							) r ON
			p.rf_idCase=r.rf_idCase

--UPDATE p SET p.pid=pid.PID
--FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP pid ON
--		p.rf_idCase=pid.rf_idCase
--WHERE pid.PID IS NOT NULL	

--ALTER TABLE #tPeople ADD ENP VARCHAR(20)


--UPDATE p SET p.ENP=pid.ENP
--FROM #tPeople p INNER JOIN dbo.t_Case_PID_ENP pid ON
--		p.rf_idCase=pid.rf_idCase
--WHERE pid.PID IS NULL	

UPDATE p SET p.pid=pid.IDPeople
FROM #tPeople p INNER JOIN(SELECT * FROM [srvsql1-st2].AccountOMSReports.dbo.t_People_Case) pid ON
		p.rf_idCase=pid.rf_idCase



SELECT p1.rf_idCase,p.PID
FROM (SELECT PID FROM #tPeople WHERE AmountRAK>0 GROUP BY PID HAVING COUNT(*)>1) p INNER JOIN #tPeople p1 ON
		p.PID=p1.PID
ORDER BY p.PID		
SELECT * FROM #tPeople WHERE PID IS NULL

SELECT pid FROM #tPeople WHERE AmountRAK>0 GROUP BY PID HAVING COUNT(*)>1
					
--SELECT COUNT(DISTINCT rf_idCase)
--FROM #tPeople p WHERE AmountRAK>0

--SELECT COUNT(*) FROM #tPeople WHERE AmountRAK=0
go
--DROP TABLE #tPeople
