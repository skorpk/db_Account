USE AccountOMSReports
GO		
DECLARE @dtBegin DATETIME='20170301',	
		@dtEndReg DATETIME='20170930 23:59:59',
		@dtEndRegAkt DATETIME='20171122 23:59:59',
		@v6 TINYINT=4,--мен€ем услови€ оказани€ мед.помощи
		@codeSMO CHAR(5)='34002',
		@dayDiff INT
  
SELECT @dayDiff=CASE WHEN @v6 <3 THEN 31 WHEN @v6=3 THEN 16 WHEN @v6=4 THEN 2 END

CREATE TABLE #tmpCases1(CodeM varchar(6),rf_idCase bigint,AmountPayment decimal(15, 2),AmountPaymentAccepted decimal(15, 2),CodeSMO char(5),DS1 char(10),rf_idV006 tinyint,ENP varchar(16),
						rf_idV002 smallint,DateBegin date,DateEnd date,NewBorn varchar(9),Account varchar(15),DateAccount date,NumberHistoryCase nvarchar(50),idRecordCase bigint)

IF @v6<3
BEGIN
	SELECT DISTINCT MU INTO #tMU FROM dbo.vw_sprMUAndCSGUnit WHERE unitCode IN(141,152)

	CREATE UNIQUE CLUSTERED INDEX CL_MU ON #tMU(MU)

	INSERT #tmpCases1( CodeM ,rf_idCase ,AmountPayment ,AmountPaymentAccepted ,CodeSMO ,DS1 ,rf_idV006 ,ENP ,rf_idV002 ,DateBegin ,DateEnd ,NewBorn ,Account ,DateAccount ,NumberHistoryCase ,idRecordCase)	
	SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,c.rf_idV006,ps.ENP,c.rf_idV002,c.DateBegin,c.DateEnd,r.NewBorn
			,Account,a.DateRegister	AS DateAccount,c.NumberHistoryCase,c.idRecordCase		
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient					
						INNER JOIN dbo.t_Case c WITH (INDEX(IX_ReportShumeiko)) ON
				r.id=c.rf_idRecordCasePatient					
						INNER JOIN dbo.vw_Diagnosis d ON
				c.id=d.rf_idCase  											
	WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.rf_idSMO=@codeSMO AND c.rf_idV006=@v6
			AND NOT EXISTS(SELECT 1 
					   FROM dbo.t_MES m INNER JOIN #tMU m1 ON
	                     	  m.MES=m1.MU
					   WHERE m.rf_idCase=c.id )
	DROP TABLE #tMU
END
ELSE IF @v6=3
BEGIN
	INSERT #tmpCases1( CodeM ,rf_idCase ,AmountPayment ,AmountPaymentAccepted ,CodeSMO ,DS1 ,rf_idV006 ,ENP ,rf_idV002 ,DateBegin ,DateEnd ,NewBorn ,Account ,DateAccount ,NumberHistoryCase ,idRecordCase)
	SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,c.rf_idV006,ps.ENP,c.rf_idV002,c.DateBegin,c.DateEnd,r.NewBorn
		,Account,a.DateRegister	AS DateAccount,c.NumberHistoryCase,c.idRecordCase		
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
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
			AND c.rf_idV002 NOT IN(41,79,109) AND EXISTS(SELECT 1 FROM dbo.t_MES m WHERE m.rf_idCase=c.id AND m.MES LIKE '2.78.%') 
END
ELSE
BEGIN
	INSERT #tmpCases1( CodeM ,rf_idCase ,AmountPayment ,AmountPaymentAccepted ,CodeSMO ,DS1 ,rf_idV006 ,ENP ,rf_idV002 ,DateBegin ,DateEnd ,NewBorn ,Account ,DateAccount ,NumberHistoryCase ,idRecordCase)
	SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,c.rf_idV006,ps.ENP,c.rf_idV002,c.DateBegin,c.DateEnd,r.NewBorn
		,Account,a.DateRegister	AS DateAccount,c.NumberHistoryCase,c.idRecordCase		
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_PatientSMO ps ON
				r.id=ps.rf_idRecordCasePatient					
						INNER JOIN dbo.t_Case c WITH (INDEX(IX_ReportShumeiko)) ON
				r.id=c.rf_idRecordCasePatient					
						INNER JOIN dbo.vw_Diagnosis d ON
				c.id=d.rf_idCase  											
	WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.rf_idSMO=@codeSMO AND c.rf_idV006=@v6
END  
---------------------------------------------------------------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_Cases
ON #tmpCases1(rf_idCase)
INCLUDE ([CodeM],[AmountPayment],[AmountPaymentAccepted],[CodeSMO],[DS1],[rf_idV006],[ENP],[rf_idV002],[DateBegin],[DateEnd],[NewBorn],[Account],[DateAccount],[NumberHistoryCase],[idRecordCase])

DELETE FROM #tmpCases1
FROM #tmpCases1 c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006,NewBorn FROM #tmpCases1 GROUP BY ENP,DS1,rf_idV002,rf_idV006,NewBorn  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006
		AND c.NewBorn=t.NewBorn

;WITH cteD																						 
as
(																								 
SELECT  ROW_NUMBER() OVER(PARTITION BY ENP,DS1, rf_idV002,rf_idV006,NewBorn ORDER BY t1.DateBegin,t1.rf_idCase ) AS id,
		t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn		
FROM #tmpCases1 t1 
), cteA AS
( SELECT DISTINCT t1.rf_idCase,t2.rf_idCase AS rf_idCase2,ABS(DATEDIFF(DAY,t1.DateEnd,t2.DateBegin)) AS diffD
  FROM cteD t1 left JOIN cteD t2 ON
		t1.ENP=t2.ENP
		AND t1.DS1=t2.ds1
		AND t1.rf_idV002 = t2.rf_idV002
		AND t1.rf_idV006 = t2.rf_idV006
		AND t1.rf_idCase>t2.rf_idCase --мен€ем здесь
		AND t1.NewBorn=t2.NewBorn
)
SELECT distinct t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn ,c.diffD
INTO #tmpCases
FROM cteA c INNER JOIN  cteD t1 ON
		c.rf_idCase=t1.rf_idCase
WHERE diffD<@dayDiff
UNION 
SELECT DISTINCT t1.CodeM , t1.rf_idCase ,t1.AmountPayment ,t1.AmountPaymentAccepted ,t1.CodeSMO ,t1.DS1 ,t1.rf_idV006 ,t1.ENP ,t1.rf_idV002 ,t1.DateBegin ,t1.DateEnd ,t1.Account,	
		t1.DateAccount,	t1.NumberHistoryCase,	t1.idRecordCase,  	t1.NewBorn,c.diffD
FROM cteA c INNER JOIN  cteD t1 ON
		c.rf_idCase2=t1.rf_idCase
WHERE diffD<@dayDiff

------------------удаление не дублирующих записей после расчета промежутков----------------------------
DELETE FROM #tmpCases
FROM #tmpCases c  INNER JOIN (SELECT ENP,DS1,rf_idV002,rf_idV006,NewBorn FROM #tmpCases GROUP BY ENP,DS1,rf_idV002,rf_idV006,NewBorn  HAVING COUNT(*)=1) t on
		c.ENP = t.ENP
		AND c.DS1 = t.DS1
		AND c.rf_idV002 = t.rf_idV002
		AND c.rf_idV006 = t.rf_idV006
		AND c.NewBorn=t.NewBorn

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
SELECT distinct c.rf_idCase,c.ENP,c.CodeM,l.NAMES,c.DateBegin,c.DateEnd,c.DS1,c.Account,c.DateAccount,c.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment,CAST(c.AmountPaymentAccepted AS money) AS AmountPaymentAccepted,
		c.DateAkt,CASE WHEN c.TypeCheckup=2 THEN 'ћЁЁ' WHEN c.TypeCheckup=3 then 'Ё ћѕ' ELSE '' END AS Typechekup,CAST(ISNULL(c.AmountDeduction,0.0) AS MONEY) AS Deduction,c.reason,c.NewBorn
from #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
ORDER BY enp,DS1, DateBegin,rf_idCase
go
drop TABLE #tmpCases
drop TABLE #tmpCases1