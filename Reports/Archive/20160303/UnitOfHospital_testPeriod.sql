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
					  rf_idV002 SMALLINT,
					  DateBegin DATE,
					  DateEnd date                      
					  )
INSERT #tPeople( rf_idCase ,CodeM ,rf_idV006 ,rf_idV002,DateBegin,DateEnd)
SELECT c.id,c.rf_idMO ,c.rf_idV006 ,c.rf_idV002, c.DateBegin,c.DateEnd
FROM dbo.t_Case c INNER JOIN (VALUES(1,33),(2,43)) v(v006,v010) ON
			c.rf_idv006=v.v006
			AND c.rf_idv010=v.v010  
WHERE c.DateEnd>@dateStart AND c.DateEnd<@dateEnd


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
;WITH UnitOfHosp
AS
(
SELECT rf_idCase,p.DateBegin,p.DateEnd,p.CodeM+'.'+CAST(p.rf_idV006 AS varchar(3))+'.'+CAST(p.rf_idV002 AS varchar(5)) AS UnitOfHospital
FROM #tPeople p 
WHERE AmountPayment>0 
)
SELECT c.rf_idMO,a.Account,a.DateRegister,a.ReportMonth,a.ReportYear,c.idRecordCase AS NumberCase,u.UnitOfHospital
FROM UnitOfHosp u INNER JOIN dbo.t_Case c ON
		u.rf_idCase=c.id
					INNER JOIN dbo.t_RecordCasePatient r ON
		r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_RegistersAccounts a ON
		a.id=r.rf_idRegistersAccounts
					INNER JOIN oms_NSI.dbo.t_UnitOfHospital u1 ON					                  
		u.UnitOfHospital=u1.UnitOfHospital
WHERE NOT EXISTS(SELECT * FROM oms_NSI.dbo.tOtdPeriod WHERE IDOTD=u.UnitOfHospital AND DATEBEG<=u.DateBegin AND DATEEND>=u.DateEnd)
--GROUP BY u.UnitOfHospital
ORDER BY c.rf_idMO,a.ReportMonth

GO
DROP TABLE #tPeople