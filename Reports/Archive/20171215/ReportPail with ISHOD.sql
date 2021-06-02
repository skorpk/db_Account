USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME=GETDATE(),
		@dtEndRegAkt DATETIME=GETDATE(),
		@v6 TINYINT=1,
		@reportYear SMALLINT =2017,
		@reportMM TINYINT=11
  

CREATE TABLE #tmpCases(CodeM varchar(6),rf_idCase bigint,AmountPayment decimal(15, 2),AmountPaymentAccepted decimal(15, 2)
						,AmountMEK DECIMAL(15,2) ,AmountMEE DECIMAL(15,2),AmountEKMP DECIMAL(15,2)
						,ReasonMEK VARCHAR(600) NOT NULL DEFAULT(''),ReasonMEE VARCHAR(600) NOT NULL DEFAULT(''),ReasonEKMP VARCHAR(600) NOT NULL DEFAULT(''),
						MU VARCHAR(9), MUName VARCHAR(250), MEK TINYINT,MEE TINYINT, EKMP TINYINT, rf_idV012 smallint)

SELECT MU,MUName INTO #tMU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=1 AND MUUnGroupCode IN(12,16,17,18) AND MUCode IN(498,499)

INSERT #tmpCases( CodeM ,rf_idCase ,AmountPayment ,AmountPaymentAccepted, MU,MUName,rf_idV012 )	
SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment ,mm.MU,mm.MUName,c.rf_idV012
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				    INNER JOIN (VALUES('104401'),('121125'),('101001'),('185905')) v(CodeM) ON
			f.CodeM=v.CodeM                  
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN t_mes m ON
			c.id=m.rf_idCase                      
					INNER JOIN #tMU mm ON
			m.MEs=mm.MU                  
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND c.rf_idV006=@v6 AND a.rf_idSMO IN('34001','34002','34006','34007') AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM

			
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt
								GROUP BY c.rf_idCase, TypeCheckup
							) p ON
			c.rf_idCase=p.rf_idCase    


UPDATE c SET c.AmountMEK=p.AmountDeduction,c.MEK=1
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
								FROM t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt AND c.TypeCheckup =1
								GROUP BY c.rf_idCase
							) p ON
		c.rf_idCase=p.rf_idCase 

UPDATE c SET c.AmountMEE=p.AmountDeduction, c.MEE=1
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountMEE) AS AmountDeduction
								FROM t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt AND c.TypeCheckup =2
								GROUP BY c.rf_idCase
							) p ON
		c.rf_idCase=p.rf_idCase 

UPDATE c SET c.AmountEKMP=p.AmountDeduction, c.EKMP=1
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountEKMP) AS AmountDeduction
								FROM t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt AND c.TypeCheckup =3
								GROUP BY c.rf_idCase
							) p ON
		c.rf_idCase=p.rf_idCase 
----------------------------------------------------------------------------------------------
;WITH cte 
AS(
SELECT distinct p.rf_idCase, rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN dbo.t_ReasonDenialPayment rd ON
								p.rf_idCase = rd.rf_idCase
								AND p.idAkt = rd.idAkt
WHERE p.DateRegistration>=@dtBegin AND p.DateRegistration<=@dtEndRegAkt AND TypeCheckup=1 								                                     
),
cte2 AS(
SELECT rf_idCase,( SELECT distinct RTRIM(f014.Reason)+ ';' as 'data()' 
from cte t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
						t2.CodeReason=f014.ID
WHERE c.rf_idCase=t2.rf_idCase for xml path('') ) AS Reason 
FROM cte c
GROUP BY c.rf_idCase
)
UPDATE t SET t.ReasonMEK=c.Reason
FROM #tmpCases t INNER JOIN cte2 c ON
		t.rf_idCase=c.rf_idCase

;WITH cte 
AS(
SELECT distinct p.rf_idCase, rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN dbo.t_ReasonDenialPayment rd ON
								p.rf_idCase = rd.rf_idCase
								AND p.idAkt = rd.idAkt
WHERE p.DateRegistration>=@dtBegin AND p.DateRegistration<=@dtEndRegAkt AND TypeCheckup=2 								                                     
),
cte2 AS(
SELECT rf_idCase,( SELECT distinct RTRIM(f014.Reason)+ ';' as 'data()' 
from cte t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
						t2.CodeReason=f014.ID
WHERE c.rf_idCase=t2.rf_idCase for xml path('') ) AS Reason 
FROM cte c
GROUP BY c.rf_idCase
)
UPDATE t SET t.ReasonMEE=c.Reason
FROM #tmpCases t INNER JOIN cte2 c ON
		t.rf_idCase=c.rf_idCase

;WITH cte 
AS(
SELECT distinct p.rf_idCase, rd.CodeReason
FROM dbo.t_PaymentAcceptedCase2 p INNER JOIN dbo.t_ReasonDenialPayment rd ON
								p.rf_idCase = rd.rf_idCase
								AND p.idAkt = rd.idAkt
WHERE p.DateRegistration>=@dtBegin AND p.DateRegistration<=@dtEndRegAkt AND TypeCheckup=3
),
cte2 AS(
SELECT rf_idCase,( SELECT distinct RTRIM(f014.Reason)+ ';' as 'data()' 
from cte t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
						t2.CodeReason=f014.ID
WHERE c.rf_idCase=t2.rf_idCase for xml path('') ) AS Reason 
FROM cte c
GROUP BY c.rf_idCase
)
UPDATE t SET t.ReasonEKMP=c.Reason
FROM #tmpCases t INNER JOIN cte2 c ON
		t.rf_idCase=c.rf_idCase
----------------------------------------------------------------------------------------------
SELECT c.CodeM,l.NAMES,c.MUName,c.rf_idV012, v12.name AS ISHOD,COUNT(c.rf_idcase) AS CountCases
		,COUNT(CASE WHEN c.AmountPaymentAccepted>0 THEN rf_idCase ELSE NULL END) AS CountPayCases
		,CAST(SUM(c.AmountPayment) AS MONEY) AS SumCases
		,CAST(sum(c.AmountPaymentAccepted) AS MONEY) AS SumPayCases
		,COUNT(CASE WHEN c.MEK IS NOT null THEN c.rf_idCase ELSE NULL END ) AS CasesMEK
		,CAST(SUM(ISNULL(c.AmountMEK,0.0)) AS MONEY) AS SumMEK
		,c.ReasonMEK
		--------------------------------------------------------
		,COUNT(CASE WHEN c.MEE IS NOT null THEN c.rf_idCase ELSE NULL END ) AS CasesMEE
		,CAST(SUM(ISNULL(c.AmountMEE,0.0)) AS MONEY) AS SumMEE
		,c.ReasonMEE
		--------------------------------------------------------
		,COUNT(CASE WHEN c.EKMP IS NOT null THEN c.rf_idCase ELSE NULL END ) AS CasesEKMP
		,CAST(SUM(ISNULL(c.AmountEKMP,0.0)) AS MONEY) AS SumEKMP
		,c.ReasonEKMP
from #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
			c.rf_idV012=v12.id              
GROUP BY c.CodeM,l.NAMES,c.MUName,c.rf_idV012, v12.name,c.ReasonMEK,c.ReasonMEE,c.ReasonEKMP
go
drop TABLE #tmpCases
drop TABLE #tMU