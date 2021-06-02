USE AccountOMS
GO		
DECLARE @dtBegin DATETIME,	
		@dtEndReg DATETIME=GETDATE(),
		@dtEnd DATE,
		@reportYear SMALLINT=2016

SET @dtBegin=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEnd=DATEADD(YEAR,1,@dtBegin)
SELECT @dtBegin,@dtEnd,@dtEndReg

				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,d.DS1,mkb.Diagnosis,c.rf_idV006
	,CASE WHEN a.ReportMonth>6 THEN 2 ELSE 1 END AS ReportPeriod
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode                  					
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear 
	AND MainDS IN('O01','O02','O03','O04','O05','O06','O07','O08','O00')
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEnd

ALTER TABLE #tmpCases ADD MEK DECIMAL(11,2) NOT NULL DEFAULT 0.0
ALTER TABLE #tmpCases ADD MEE  DECIMAL(11,2) NOT NULL DEFAULT 0.0
ALTER TABLE #tmpCases ADD EKMP DECIMAL(11,2) NOT NULL DEFAULT 0.0
ALTER TABLE #tmpCases ADD Reason VARCHAR(250) 

UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase    

UPDATE c SET c.MEK=AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

UPDATE c SET MEE=AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountMEE) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND TypeCheckup=2
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 

UPDATE c SET MEE=AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountEKMP) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND TypeCheckup=3
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase 						 

;WITH cte 
AS(
SELECT distinct cc.ReportPeriod,cc.rf_idV006,cc.CodeM,cc.Ds1,rd.CodeReason
FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
								f.id=d.rf_idAFile
										INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
								d.id=a.rf_idDocumentOfCheckup
										INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
								a.id=c.rf_idCheckedAccount 
										INNER JOIN #tmpCases cc ON
								cc.rf_idCase=c.rf_idCase 
										 INNER JOIN ExchangeFinancing.dbo.t_ReasonDenialPayment rd ON
								c.id=rd.rf_idCheckedCase 										
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg 								                                     
)
SELECT c.CodeM,c.ReportPeriod,c.rf_idV006,c.Ds1,( SELECT distinct RTRIM(f014.Reason)+ ';' as 'data()' 
						from cte t2 INNER JOIN OMS_NSI.dbo.sprF014 f014 ON
												t2.CodeReason=f014.ID
						WHERE c.rf_idV006=t2.rf_idV006 and c.CodeM=t2.CodeM and c.DS1=t2.DS1 for xml path('') ) AS Reason 
INTO #tmpReason
FROM cte c
GROUP BY c.CodeM,c.ReportPeriod,c.rf_idV006,c.DS1

-----------------------------Стационар-----------------------------------------------------------
Declare @rf_idV006 TINYINT=1,
		@period TINYINT=1

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,'')	,
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period		

set @period =2

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,'')	,
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period	

-----------------------------Дневной Стационар-----------------------------------------------------------
select @rf_idV006 =2, @period=1

;WITH cte1
AS(
	SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
	FROM #tmpCases c INNER JOIN vw_sprT001 l ON
			c.CodeM=l.CodeM
	WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
	Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period			

set @period=2

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period	
-----------------------------Амбулатория-----------------------------------------------------------
select @rf_idV006 =3,@period =1

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period			

set @period =2

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period	
-----------------------------СМП-----------------------------------------------------------
select @rf_idV006 =4, @period =1

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period	
set @period =2

;WITH cte1
AS(
SELECT l.CodeM,l.NAMES AS LPU,c.DS1,SUM(c.AmountPayment) AS AmountPayment,SUM(AmountPaymentAccepted) AS AmountPaymentAccepted,
		SUM(MEK) AS MEK, SUM(MEE) AS MEE, SUM(EKMP) AS EKMP,c.rf_idV006
FROM #tmpCases c INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.rf_idV006=@rf_idV006 AND c.ReportPeriod=@period
Group BY l.CodeM,l.NAMES ,c.DS1,c.rf_idV006
)
SELECT  t1.LPU ,t1.DS1,
        CAST(t1.AmountPayment AS MONEY) as AmountPayment,
        CAST(t1.AmountPaymentAccepted AS MONEY) AS AmountPaymentAccepted ,
		isnull(r.Reason,''),
        cast(t1.MEK  as money) AS MEK,
        cast(t1.MEE  as money) AS MEE,
        cast(t1.EKMP as money) AS EKMP
FROM cte1 t1 left JOIN #tmpReason r ON		
		t1.CodeM = r.CodeM
		AND t1.DS1=r.DS1
		AND t1.rf_idV006=r.rf_idV006
		and r.ReportPeriod=@period		
GO 
DROP TABLE #tmpCases
DROP TABLE #tmpReason