USE AccountOMSReports
GO
DECLARE @reportYear SMALLINT=2015,
		@dateStart DATETIME='20150101',
		@dateEnd DATE='20160101',
		@dateEndPay DATETIME='20160202 23:59:59'

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  AmountPayment DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  CodeM CHAR(6),
					  rf_idV006 TINYINT,
					  rf_idV002 smallint                      
					  )
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002
FROM dbo.t_Case c INNER JOIN (VALUES(1,33),(2,43)) v(v006,v010) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd

/*SELECT c.id,f.CodeM ,c.rf_idV006 ,c.rf_idV002
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN (VALUES(1,33),(2,43)) v(v006,v010) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=@reportYear  
*/


--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=r.AmountPayment
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS AmountPayment
							FROM dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--DROP TABLE oms_NSI.dbo.t_UnitOfHospital 
SELECT DISTINCT p.CodeM+'.'+CAST(p.rf_idV006 AS varchar(3))+'.'+CAST(p.rf_idV002 AS varchar(5)) AS UnitOfHospital
INTO oms_NSI.dbo.t_UnitOfHospital 
FROM #tPeople p 
WHERE AmountPayment>0 
GO
DROP TABLE #tPeople