USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150701',
		@dateEnd DATETIME='20151201',
		@dateEndPay DATETIME='20151201'

DECLARE @t DECIMAL(11,2),
		@t1 DECIMAL(11,2)
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  CodeSMO CHAR(5),
					  AmountPayment DECIMAL(11,2),
					  DateBeg DATE,
					  DateEnd DATE,
					  PID INT,
					  SNILS_Doc VARCHAR(11)
					  )

-------------------------взрослые причисл€ютс€ к одной группе 5
INSERT #tPeople( rf_idCase ,CodeM ,CodeSMO ,AmountPayment,DateBeg, DateEnd,PID)
SELECT c.id,f.CodeM,a.rf_idSMO,c.AmountPayment,c.DateBegin,c.DateEnd,p.PID
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient								   
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase										
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>6 AND a.ReportMonth<=11 AND a.ReportYear=2015 AND c.rf_idV006=4 AND p.PID IS NOT NULL


UPDATE t SET t.SNILS_Doc=p.SS_Doctor
FROM #tPeople t INNER JOIN ( SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBeg>=p.LPUDT AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY p.PID ORDER BY p.LPUDT desc)
							) p ON
			t.rf_idCase=p.rf_idCase                          


select TOP 1 WITH TIES t.rf_idCase,t.PID
INTO #tPolicy
from RegisterCases.dbo.vw_People p inner join #tPeople t on
						p.ID=t.pid
						inner join RegisterCases.dbo.vw_Polis pol on
						p.ID=pol.PID
						 inner join RegisterCases.dbo.vw_sprSMO smo on
						isnull(pol.Q,0)=smo.smocod
where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'
ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idCase,pol.PID ORDER BY pol.DBEG desc)	


SELECT p.*,hl.LPUDT,hl.SS_DOCTOR,hl.KATEG
FROM #tPeople p INNER JOIN #tPolicy pol ON
		p.rf_idCase=pol.rf_idCase
				INNER JOIN PolicyRegister.dbo.HISTLPU hl ON
		p.pid=hl.PID              
WHERE SNILS_Doc IS NULL
				


SELECT @t=COUNT(DISTINCT pid) FROM #tPeople WHERE SNILS_Doc IS NOT NULL

SELECT @t1=COUNT(DISTINCT pid) FROM #tPeople 
SELECT (@t/@t1)*100.0

SELECT @t1,@t

GO
DROP TABLE #tPeople
DROP TABLE #tPolicy