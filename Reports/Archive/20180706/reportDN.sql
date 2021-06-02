USE AccountOMS
GO
DECLARE @startDateReg DATETIME,
		@endDateReg DATETIME=GETDATE(),
		@reportYear smallint=2016,
		@caseStart DATE,
		@caseEnd DATE

SELECT @startDateReg=CAST(@reportYear AS CHAR(4))+'0101',@caseStart=CAST(@reportYear AS CHAR(4))+'0101', @caseEnd=CAST(@reportYear AS CHAR(4))+'1231'

CREATE TABLE #tRSLT(rf_idV009 smallint)
CREATE TABLE #tMU(MU VARCHAR(9))

INSERT #tRSLT( rf_idV009 ) VALUES  (322), (323), (324), (349), (350), (351), (334), (335), (336), (339), (340), (341)
INSERT #tMU( MU )
VALUES  ('2.88.2'),('2.88.3'),('2.88.6'),('2.88.7'),('2.88.8'),('2.88.9'),('2.88.11'),('2.88.13'),('2.88.14'),('2.88.15'),('2.88.16'),
		('2.88.17'),('2.88.21'),('2.88.23'),('2.88.25'),('2.88.26'),('2.88.27'),('2.88.28'),('2.88.29'),('2.88.30'),('2.88.32'),('2.88.33'),('2.88.34')


SELECT c.id AS rf_idCase,c.rf_idV014, c.rf_idV009, c.AmountPayment, a.Letter, ch.id AS PID, c.rf_idV006, f.CodeM, r.AttachLPU
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              
				INNER JOIN dbo.t_Case_PID_ENP ce ON
		c.id=ce.rf_idCase	
				INNER JOIN PeopleAttach.dbo.Children ch on
		ce.pid=ch.id
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND ch.ry=@reportYear

INSERT #tPeople  
SELECT c.id AS rf_idCase,c.rf_idV014, c.rf_idV009, c.AmountPayment, a.Letter, ch.id AS PID,rf_idV006, f.CodeM, r.AttachLPU
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           		
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient		              
				INNER JOIN dbo.t_Case_PID_ENP ce ON
		c.id=ce.rf_idCase	
				INNER JOIN PeopleAttach.dbo.Children ch on
		ce.ENP=ch.enp
		AND ce.pid IS NULL
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportYear=@reportYear 
		AND c.DateEnd>=@caseStart AND c.DateEnd<=@caseEnd  AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND ch.ry=@reportYear  

--UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
--FROM #tPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
--								FROM dbo.t_PaymentAcceptedCase c
--								WHERE c.DateRegistration>=@startDateReg AND c.DateRegistration<@endDateReg 
--								GROUP BY c.rf_idCase
--							) r ON
--			p.rf_idCase=r.rf_idCase



------первая колонка из таблицы от ЛЮЛ--------
SELECT SUM(Col1), SUM(Col2),SUM(Col3),SUM(Col4),SUM(Col5),SUM(Col6),SUM(Col7)
FROM (
	SELECT COUNT(DISTINCT ID) AS Col1,0 AS Col2,0 AS Col3, 0 AS Col4, 0 AS Col5, 0 AS Col6, 0 AS Col7 from PeopleAttach.dbo.Children WHERE ry=@reportYear
	UNION all
	-------Col2-----------
	SELECT 0,COUNT(DISTINCT p.PID) AS Col2, 0 AS Col3, 0 AS Col4, 0 AS Col5, 0 AS Col6, 0 AS Col7
	FROM #tPeople p INNER JOIN #tRSLT r ON
			p.rf_idV009=r.rf_idV009
					INNER JOIN #tPeople pp ON
			p.PID=pp.PID
	WHERE pp.rf_idV014<3 AND p.AmountPayment>0 AND p.Letter IN('D','F','V','I','U') AND pp.AmountPayment>0
	UNION ALL
	-------Col3-----------
	SELECT 0,0 AS Col2 ,COUNT(DISTINCT pp.PID) AS Col3,0,0,0,0
	FROM  #tPeople p INNER JOIN #tRSLT r ON
			p.rf_idV009=r.rf_idV009 
					INNER JOIN #tPeople pp ON
			p.PID=pp.PID			
					INNER JOIN dbo.t_Meduslugi m ON
				pp.rf_idCase=m.rf_idCase
					INNER JOIN #tMU mm ON
				m.MU=mm.MU 
	WHERE p.AmountPayment>0 AND pp.AmountPayment>0  AND pp.rf_idV006=3 AND p.Letter IN('D','F','V','I','U') AND pp.CodeM=pp.AttachLPU
	UNION ALL
	
	-------Col4-----------
	SELECT 0,0 ,0,COUNT(DISTINCT PID) AS Col4,0,0,0
	FROM #tPeople p 
	WHERE rf_idV014<3 AND AmountPayment>0 AND Letter IN('D','F','V','I','U') AND NOT EXISTS(SELECT 1 FROM #tRSLT WHERE rf_idV009=p.rf_idV009)
	UNION ALL
	SELECT 0,0 ,0,COUNT(DISTINCT PID) AS Col4,0,0,0
	FROM #tPeople p 
	WHERE rf_idV014<3 AND AmountPayment>0 AND Letter not IN('D','F','V','I','U') 
	
	-------Col5-----------
	UNION all
	SELECT 0,0 ,0,0,COUNT(DISTINCT PID) AS Col5,0,0
	FROM #tPeople p 
	WHERE AmountPayment>0 AND Letter IN('D','F','V','I','U')
	
	-------Col6-----------
	UNION all
	SELECT 0,0 ,0,0,0,COUNT(DISTINCT ID) AS Col6,0	
	FROM PeopleAttach.dbo.children  ch
	WHERE ch.ry=@reportYear AND NOT EXISTS ( SELECT *
											FROM #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
													p.rf_idCase=d.rf_idCase
											WHERE ch.id=p.pid AND AmountPayment>0 AND Letter NOT IN('D','F','V','I','U') AND d.DS1 NOT LIKE 'Z%'
											)
	
	-------Col7-----------
	--UNION all
	--SELECT 0,0 ,0,0,0,0,COUNT(DISTINCT pp.PID) AS Col7
	--FROM #tPeople p INNER JOIN #tRSLT r ON
	--		p.rf_idV009=r.rf_idV009
	--				INNER JOIN #tPeople pp ON
	--		p.PID=pp.PID
	--				INNER JOIN dbo.vw_Diagnosis d ON
	--		pp.rf_idCase=d.rf_idCase
	--WHERE p.AmountPayment>0 AND p.Letter IN ('D','F','V','I','U') AND pp.AmountPayment>0 AND pp.Letter NOT IN ('D','F','V','I','U') AND d.DS1 NOT LIKE 'Z%'
	--UNION all
	--SELECT 0,0 ,0,0,0,0,COUNT(DISTINCT pp.PID) AS Col7
	--FROM (
	--		SELECT distinct p.PID
	--		FROM #tPeople p INNER JOIN #tRSLT r ON
	--				p.rf_idV009=r.rf_idV009
	--		WHERE p.AmountPayment>0 AND p.Letter IN ('D','F','V','I','U') 
	--	) t INNER JOIN #tPeople pp ON
	--		t.PID=pp.PID
	--				INNER JOIN dbo.vw_Diagnosis d ON
	--		pp.rf_idCase=d.rf_idCase
	--where pp.AmountPayment>0 AND pp.Letter NOT IN ('D','F','V','I','U') and d.DS1 NOT LIKE 'Z%'
	UNION all
	SELECT 0,0 ,0,0,0,0,COUNT(DISTINCT p.PID) AS Col7
	FROM #tPeople p INNER JOIN #tRSLT r ON
			p.rf_idV009=r.rf_idV009
	WHERE p.AmountPayment>0 AND p.Letter IN ('D','F','V','I','U') 
		AND NOT EXISTS(SELECT * FROM #tPeople pp INNER JOIN dbo.vw_Diagnosis d ON
											pp.rf_idCase=d.rf_idCase
						where p.PID=pp.Pid and pp.AmountPayment>0 AND pp.Letter NOT IN ('D','F','V','I','U') and d.DS1 NOT LIKE 'Z%')					
	) t
GO
DROP TABLE #tMU
DROP TABLE #tPeople
DROP TABLE #tRSLT