USE AccountOMS
go
alter PROC usp_ReportShumeikoByExpertize		
			@dtBegin DATETIME,	
			@dtEndReg DATETIME,
			@dtEndRegAkt DATETIME,
			@v6 TINYINT,--мен€ем услови€ оказани€ мед.помощи
			@codeSMO CHAR(5)
as				
SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,c.rf_idV006,ps.ENP,c.rf_idV002,c.DateBegin,c.DateEnd,r.NewBorn
		,Account,a.DateRegister	AS DateAccount,c.NumberHistoryCase,c.idRecordCase		
INTO #tmpCases1
FROM dbo.t_File f  INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case c WITH (INDEX(IX_ReportShumeiko)) ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase  											
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.Letter NOT IN('K','T','O','R','F','V','U','D') AND a.rf_idSMO=@codeSMO AND c.rf_idV006=@v6
		AND c.rf_idV002 NOT IN(41,79,109) AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode>78 AND m.MUUnGroupCode<83)
		--AND ps.ENP='2449740887000467'

CREATE NONCLUSTERED INDEX IX_Cases
ON #tmpCases1(rf_idCase)
INCLUDE ([CodeM],[AmountPayment],[AmountPaymentAccepted],[CodeSMO],[DS1],[rf_idV006],[ENP],[rf_idV002],[DateBegin],[DateEnd],[NewBorn],[Account],[DateAccount],[NumberHistoryCase],[idRecordCase])

DELETE FROM #tmpCases1
FROM #tmpCases1 c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006 FROM #tmpCases1 GROUP BY ENP,DS1,rf_idV002,rf_idV006  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006

;WITH cteD																						 
as
(																								 
SELECT  ROW_NUMBER() OVER(PARTITION BY ENP,DS1, rf_idV002,rf_idV006,NewBorn ORDER BY t1.DateBegin,t1.rf_idCase ) AS id,
		t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn		
FROM #tmpCases1 t1 
), cteA AS
( SELECT DISTINCT t1.rf_idCase,t2.rf_idCase AS rf_idCase2,DATEDIFF(DAY,t1.DateEnd,t2.DateBegin) AS diffD
FROM cteD t1 left JOIN cteD t2 ON
		t1.ENP=t2.ENP
		AND t1.DS1=t2.ds1
		AND t1.rf_idV002 = t2.rf_idV002
		AND t1.rf_idV006 = t2.rf_idV006
		AND t1.id<>t2.id
WHERE DATEDIFF(DAY,t1.DateEnd,t2.DateBegin)>0 AND DATEDIFF(DAY,t1.DateEnd,t2.DateBegin)<16
)
SELECT distinct t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn ,c.diffD
INTO #tmpCases
FROM cteA c INNER JOIN  cteD t1 ON
		c.rf_idCase=t1.rf_idCase
UNION 
SELECT DISTINCT t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn,c.diffD
FROM cteA c INNER JOIN  cteD t1 ON
		c.rf_idCase2=t1.rf_idCase

------------------удаление не дублирующих записей после расчета промежутков----------------------------
DELETE FROM #tmpCases
FROM #tmpCases c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006 FROM #tmpCases GROUP BY ENP,DS1,rf_idV002,rf_idV006  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006

--SELECT @@rowcount

----------------------------------------------------------------------------------------------
ALTER TABLE #tmpCases ADD DateAkt DATE
ALTER TABLE #tmpCases ADD TypeCheckup TINYINT 
ALTER TABLE #tmpCases ADD AmountDeduction DECIMAL(11,2)
ALTER TABLE #tmpCases ADD Reason VARCHAR(250) NOT NULL DEFAULT('')

UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    


UPDATE c SET DateAkt=p.DocumentDate,c.TypeCheckup=p.TypeCheckup, c.AmountDeduction=p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,c.DocumentDate,c.TypeCheckup,c.AmountDeduction
								FROM t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt AND c.TypeCheckup IN(2,3)
								GROUP BY c.rf_idCase,c.DocumentDate,c.TypeCheckup,c.AmountDeduction
							) p ON
		c.rf_idCase=p.rf_idCase 
----------------------------------------------------------------------------------------------
;WITH cte 
AS(
SELECT distinct p.rf_idCase, rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN dbo.t_ReasonDenialPayment rd ON
								p.rf_idCase = rd.rf_idCase
								AND p.idAkt = rd.idAkt
WHERE p.DateRegistration>=@dtBegin AND p.DateRegistration<=@dtEndRegAkt 								                                     
),
cte2 AS(
SELECT rf_idCase,( SELECT distinct RTRIM(f014.Reason)+ ';' as 'data()' 
from cte t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
						t2.CodeReason=f014.ID
WHERE c.rf_idCase=t2.rf_idCase for xml path('') ) AS Reason 
FROM cte c
GROUP BY c.rf_idCase
)
UPDATE t SET t.Reason=c.Reason
FROM #tmpCases t INNER JOIN cte2 c ON
		t.rf_idCase=c.rf_idCase
----------------------------------------------------------------------------------------------
--SELECT * FROM #tmpCases WHERE eNP='0556310898000162'

SELECT distinct c.rf_idCase,c.ENP,c.CodeM,l.NAMES,c.DateBegin,c.DateEnd,c.DS1,c.Account,c.DateAccount,c.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment,CAST(c.AmountPaymentAccepted AS money) AS AmountPaymentAccepted,
		c.DateAkt,CASE WHEN c.TypeCheckup=2 THEN 'ћЁЁ' WHEN c.TypeCheckup=3 then 'Ё ћѕ' ELSE '' END AS Typechekup,CAST(ISNULL(c.AmountDeduction,0.0) AS MONEY) AS Deduction,c.reason,c.NewBorn
--INTO tmpStacionar
from #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
ORDER BY enp,DS1, DateBegin,rf_idCase
drop TABLE #tmpCases
drop TABLE #tmpCases1
GO