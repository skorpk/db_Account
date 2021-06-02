USE AccountOMS
GO
DECLARE @dateStart DATETIME='20130501',
		@dateEnd DATETIME='20141120 23:59:59',
		@dateEndPay DATETIME='20141111'
		
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBegin DATE, 
					  DateEnd DATE,
					  CodeM CHAR(6),
					  Account VARCHAR(15),
					  ReportMonth TINYINT,
					  ReportYear SMALLINT,					 
					  DR DATE, 
					  AmountPayment DECIMAL(11,2), 
					  AmountRAK DECIMAL(11,2),					  
					  DateRegistration DATETIME,
					  rf_idV005 TINYINT,
					  IsError592 TINYINT NOT NULL DEFAULT 0
					  )


INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,DR,AmountPayment, DateRegistration,rf_idV005,ReportMonth,ReportYear )
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,p.BirthDay,c.AmountPayment,f.DateRegistration,ISNULL(p.rf_idV005,age.Sex)
		,a.ReportMonth,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN t_MES m ON
			c.id=m.rf_idCase					
					INNER JOIN (SELECT distinct MU, Sex FROM RegisterCases.dbo.t_AgeMU2) age ON
			m.MES=age.MU
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear=2013 
-------------------------------------------2014----------------------------------------------
INSERT #tPeople( rf_idCase ,DateBegin ,DateEnd ,CodeM ,Account ,DR,AmountPayment,DateRegistration,rf_idV005,ReportMonth,ReportYear )
SELECT c.id,c.DateBegin,c.DateEnd,f.CodeM,a.Account,p.BirthDay,c.AmountPayment,f.DateRegistration,ISNULL(p.rf_idV005,age.Sex)
		,a.ReportMonth,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN (SELECT distinct MU,Sex FROM RegisterCases.dbo.t_AgeMU2) age ON
			m.MES=age.MU			
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND f.id=p.rf_idFiles
WHERE f.DateRegistration>'20140101' AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=10 AND a.ReportYear=2014	


--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountRAK=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay 	
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


UPDATE #tPeople SET IsError592=0

UPDATE p SET p.IsError592=1
FROM (
		SELECT c.id,mes.Mes,YEAR(c.DateBegin)-YEAR(r.DR) AS Age,r.rf_idV005
		from #tPeople r inner join t_Case c on
						r.rf_idCase=c.id
								INNER JOIN (VALUES(10),(14),(20)) v(id) ON
						c.Comments=v.id
								inner join t_MES mes on
						c.id=mes.rf_idCase	
								INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=3
											UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=1
											UNION ALL 
											SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=2) mc on
						mes.MES=mc.MU						
		WHERE r.AmountRAK>0						
			) c INNER JOIN #tPeople p ON
			c.id=p.rf_idCase
WHERE NOT EXISTS(SELECT * FROM RegisterCases.dbo.t_AgeMU2 s WHERE s.MU=c.MES AND s.Age=c.Age AND ISNULL(s.Sex,c.rf_idV005)=c.rf_idV005)


--2 вариант, когда «— 70.5.* или 72.* беретьс€ возраст высчитаный при вставки данных в таблицу t_Case
UPDATE r SET IsError592=1
from #tPeople r inner join t_Case c on
				r.rf_idCase=c.id
						INNER JOIN (VALUES(10),(14),(20)) v(id) ON
				c.Comments=v.id
						inner join t_MES mes on
				c.id=mes.rf_idCase	
						INNER JOIN (SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=72 AND MUUnGroupCode=3
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=5
									UNION ALL 
									SELECT MU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=70 AND MUUnGroupCode=6
									) mc on
				mes.MES=mc.MU		
WHERE r.AmountRAK>0 AND NOT EXISTS(SELECT * FROM RegisterCases.dbo.t_AgeMU2 s WHERE s.MU=mes.MES AND s.Age=c.Age AND ISNULL(s.Sex,r.rf_idV005)=r.rf_idV005)

--UPDATE #tPeople SET IsError592=0
-------------------------------------------------------------------------------------------------------------------------------------------					
SELECT --c.id,
		l.CodeM,l.NAMES AS LPU,Account,c.idRecordCase,Dr
		--,rf_idV005,CASE WHEN m.MES LIKE '70.3.%' THEN YEAR(c.DateBegin)-YEAR(r.DR) ELSE c.Age END,c.DateBegin
		,ReportMonth,ReportYear,MES+' '+mes.MUName
		,CAST(r.AmountPayment AS MONEY),CAST(ISNULL(AmountRAK,0) AS MONEY)
		,c.DateBegin,c.DateEnd,r.rf_idV005 
FROM #tPeople r INNER JOIN dbo.t_Case c ON
		r.rf_idCase=c.id
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprT001 l ON
		r.CodeM=l.CodeM
				INNER JOIN vw_sprMUCompletedCase mes ON
		m.MES=mes.MU
WHERE IsError592=1		
ORDER BY l.CodeM

go

--DROP TABLE #tPeople


