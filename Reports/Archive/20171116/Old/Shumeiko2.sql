USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170301',	
		@dtEndReg DATETIME='20170630',
		@dtEndRegAkt DATETIME='20170930',
		@v6 TINYINT=3
				
SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,c.rf_idV006,ps.ENP,c.rf_idV002,c.DateBegin,c.DateEnd,r.NewBorn
		,Account,a.DateRegister	AS DateAccount,c.NumberHistoryCase,c.idRecordCase		
INTO #tmpCases1
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase  											
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.Letter NOT IN('K','T','O','R','F','V','U','D') AND a.rf_idSMO='34002' AND c.rf_idV006=@v6
		AND c.rf_idV002 NOT IN(41,79,109) AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode>78 AND m.MUUnGroupCode<83)

DELETE FROM #tmpCases1
FROM #tmpCases1 c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006 FROM #tmpCases1 GROUP BY ENP,DS1,rf_idV002,rf_idV006  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006
		
/*
;WITH cteD																						 
as
(																								 
SELECT  ROW_NUMBER() OVER(PARTITION BY ENP,DS1, rf_idV002,rf_idV006,NewBorn ORDER BY t1.rf_idCase ) AS id,
		t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn		
FROM #tmpCases1 t1
), cteA AS(
			SELECT TOP 100 PERCENT t1.id,t1.CodeM ,t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,
			        t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,t1.DateAccount,t1.NumberHistoryCase,t1.idRecordCase, t1.NewBorn		
			FROM cteD t1
			WHERE EXISTS(SELECT 1 FROM cteD t WHERE t.id>1 and t.ENP=t1.ENP AND t.DS1=t1.ds1 AND t1.rf_idV002 = t.rf_idV002 AND t1.rf_idV006 = t.rf_idV006 AND t1.NewBorn = t.NewBorn)
			ORDER BY enp,t1.DS1,t1.id
), cteF	AS
(
SELECT TOP 100 PERCENT t1.id,t1.CodeM ,t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,
        t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,t1.DateAccount,t1.NumberHistoryCase,t1.idRecordCase, t1.NewBorn,
		ABS(DATEDIFF(DAY,t1.DateEnd,t2.DateBegin)) AS DayDiff
FROM cteA t1 left JOIN cteA t2 ON
		t1.ENP=t2.ENP
		AND t1.DS1=t2.ds1
		AND t1.rf_idV002 = t2.rf_idV002
		AND t1.rf_idV006 = t2.rf_idV006
		AND t1.NewBorn = t2.NewBorn
		AND t1.id=t2.id+1
ORDER BY t1.ENP,DS1,t1.id
)
SELECT *
INTO #tmpCases
FROM cteF  WHERE ISNULL(DayDiff,1)<16
*/

;WITH cteD																						 
as
(																								 
SELECT  ROW_NUMBER() OVER(PARTITION BY ENP,DS1, rf_idV002,rf_idV006,NewBorn ORDER BY t1.DateBegin,t1.rf_idCase ) AS id,
		t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn		
FROM #tmpCases1 t1
) 
, cteF	AS
(
SELECT TOP 100 PERCENT t1.id,t1.CodeM ,t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,
        t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,t1.DateAccount,t1.NumberHistoryCase,t1.idRecordCase, t1.NewBorn,
		0 AS DayDiff
FROM cteD t1 WHERE t1.id=1
UNION all
SELECT TOP 100 PERCENT t1.id,t1.CodeM ,t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,
        t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,t1.DateAccount,t1.NumberHistoryCase,t1.idRecordCase, t1.NewBorn,
		DATEDIFF(DAY,t1.DateEnd,t2.DateBegin) AS DayDiff
FROM cteD t1 inner JOIN cteD t2 ON
		t1.ENP=t2.ENP
		AND t1.DS1=t2.ds1
		AND t1.rf_idV002 = t2.rf_idV002
		AND t1.rf_idV006 = t2.rf_idV006
		AND t1.NewBorn = t2.NewBorn
		AND t1.id=t2.id+1
WHERE DATEDIFF(DAY,t1.DateEnd,t2.DateBegin)<16
ORDER BY t1.ENP,DS1,t1.id
)
SELECT *
INTO #tmpCases
FROM cteF 

DELETE FROM #tmpCases
FROM #tmpCases c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006 FROM #tmpCases GROUP BY ENP,DS1,rf_idV002,rf_idV006  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006

SELECT @@rowcount

SELECT ENP,DS1,rf_idV002,rf_idV006 FROM #tmpCases GROUP BY ENP,DS1,rf_idV002,rf_idV006  HAVING COUNT(*)=1


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
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg AND c.TypeCheckup IN(2,3)
								GROUP BY c.rf_idCase,c.DocumentDate,c.TypeCheckup,c.AmountDeduction
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cte 
AS(
SELECT distinct p.rf_idCase, rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN dbo.t_ReasonDenialPayment rd ON
								p.rf_idCase = rd.rf_idCase
								AND p.idAkt = rd.idAkt
WHERE p.DateRegistration>=@dtBegin AND p.DateRegistration<=@dtEndReg 								                                     
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

SELECT * FROM #tmpCases WHERE eNP='0556310898000162'

SELECT distinct c.rf_idCase,c.ENP,c.CodeM,l.NAMES,c.DateBegin,c.DateEnd,c.DS1,c.Account,c.DateAccount,c.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment,CAST(c.AmountPaymentAccepted AS money) AS AmountPaymentAccepted,
		c.DateAkt,CASE WHEN c.TypeCheckup=2 THEN 'ÌÝÝ' WHEN c.TypeCheckup=3 then 'ÝÊÌÏ' ELSE '' END AS Typechekup,CAST(ISNULL(c.AmountDeduction,0.0) AS MONEY) AS Deduction,c.reason,c.NewBorn,DayDiff
from #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
ORDER BY enp,DS1,rf_idCase
go
drop TABLE #tmpCases
go
drop TABLE #tmpCases1