USE AccountOMS
GO
DECLARE @startDateReg DATETIME='20180110',
		@endDateReg DATETIME='20180809',
		@endDateRegAkt DATETIME='20180809',
		@reportYear smallint=2018,
		@reportMonth TINYINT=7,
		@codeSMO CHAR(5)='34002',
		@dtEndB DATE='20180801'
SET STATISTICS TIME, IO ON

SELECT c.id AS rf_idCase,c.AmountPayment,f.CodeM,p.ENP, DATEDIFF(YEAR,rp.BirthDay,GETDATE()) AS Age,rp.rf_idV005, CAST(0 AS DECIMAL(11,2)) AS AmountPaymentAccepted, CAST(0 AS DECIMAL(11,2)) AS AmountPay
, d.TypeDisp, d.IsMobileTeam, c.rf_idV009 AS RSLT, c.DateBegin, c.DateEnd,f.DateRegistration, d.TypeFailure, c.IsNeedDisp, 0 AS IsCanser
INTO #tPeople
from dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
		f.id=a.rf_idFiles				             
				inner JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient           
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase   
				INNER JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCasePatient				
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase            
WHERE f.DateRegistration>@startDateReg AND f.DateRegistration<=@endDateReg AND a.ReportMonth<=@reportMonth AND a.ReportYear=@reportYear 
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180801' AND a.Letter='O' AND d.TypeDisp IN ('ÄÂ1','ÄÂ2','ÄÂ3')
		AND a.rf_idSMO=@codeSMO

select p.rf_idCase,pp.NAZR,pp.rf_idV015
INTO #prescription
FROM #tPeople p INNER JOIN dbo.t_Prescriptions pp ON
		p.rf_idCase=pp.rf_idCase   

UPDATE p SET p.IsNeedDisp=1
FROM #tPeople p INNER JOIN (select p.rf_idCase
							FROM #tPeople p INNER JOIN dbo.t_DS2_Info pp ON
									p.rf_idCase=pp.rf_idCase
							WHERE pp.IsNeedDisp>0 AND pp.IsNeedDisp<3
							) r	on
				p.rf_idCase=r.rf_idCase

UPDATE p SET p.IsCanser=1
FROM #tPeople p INNER JOIN (
							select p.rf_idCase
							FROM #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
									p.rf_idCase=d.rf_idCase
							WHERE d.DS1 LIKE 'C%'
							UNION 
							select p.rf_idCase
							FROM #tPeople p INNER JOIN dbo.vw_Diagnosis d ON
									p.rf_idCase=d.rf_idCase
											INNER JOIN dbo.t_DS2_Info dd ON
									p.rf_idCase=dd.rf_idCase              
											INNER JOIN dbo.vw_sprMKB10 mkb ON
									dd.DiagnosisCode=mkb.DiagnosisCode              
							WHERE d.DS1 LIKE 'D70' AND dd.DiagnosisCode LIKE 'C%' AND mkb.MainDS NOT IN('C81','C82','C83','C84','C85','C86','C87','C88','C89','C90','C91','C92','C93','C94','C95','C96')
							) r	on
				p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPaymentAccepted=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>='20180101' AND p.DateRegistration<@endDateRegAkt
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountPay=r.Amount
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountPaymentAccept) AS Amount
							FROM dbo.t_PaidCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>='20180101' AND p.DateRegistration<@endDateRegAkt
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

ALTER TABLE #tPeople ADD IsLastCase TINYINT NULL 

ALTER TABLE #tPeople ADD IsTypeDisp TINYINT NULL 

ALTER TABLE #tPeople ADD IsCalc28 TINYINT NULL

CREATE NONCLUSTERED INDEX IX_temp
ON  #tPeople([TypeDisp],[AmountPaymentAccepted],[AmountPay])
INCLUDE ([rf_idCase],[ENP],[DateEnd],[DateRegistration])
 --äåëàþ ïîìåòêó ê êàêîìó âèäó îòíîñèòñÿ âòîðîé ýòàï
UPDATE pp SET IsTypeDisp=3
FROM #tPeople pp 
WHERE AmountPaymentAccepted>0 AND AmountPay>0 AND  TypeDisp='ÄÂ2' AND EXISTS(SELECT * FROM #tPeople WHERE ENP=pp.ENP AND TypeDisp= 'ÄÂ1' AND AmountPay>0 AND AmountPaymentAccepted>0)

UPDATE pp SET IsTypeDisp=2
FROM #tPeople pp 
WHERE AmountPaymentAccepted>0 AND AmountPay>0 AND  TypeDisp='ÄÂ2' AND EXISTS(SELECT * FROM #tPeople WHERE ENP=pp.ENP AND TypeDisp= 'ÄÂ3' AND AmountPay>0 AND AmountPaymentAccepted>0)

UPDATE pp SET IsCalc28=1
FROM #tPeople pp 
WHERE AmountPaymentAccepted>0 AND AmountPay>0 AND RSLT IN(352,343,357,358)


;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd desc,DateRegistration desc) AS id, rf_idCase
FROM #tPeople pp 
WHERE AmountPaymentAccepted>0 AND AmountPay>0 AND  TypeDisp IN('ÄÂ2') AND EXISTS(SELECT * FROM #tPeople WHERE ENP=pp.ENP AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 AND AmountPaymentAccepted>0)
)
UPDATE p SET p.IsLastCase=1
FROM #tPeople p INNER JOIN cte c ON
		p.rf_idCase=c.rf_idCase
WHERE id=1

;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd desc,DateRegistration desc) AS id, rf_idCase
FROM #tPeople pp WHERE AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND
NOT EXISTS(SELECT * FROM #tPeople WHERE ENP=pp.ENP AND TypeDisp='ÄÂ2' AND AmountPay>0 AND AmountPaymentAccepted>0)
)
UPDATE p SET p.IsLastCase=1
FROM #tPeople p INNER JOIN cte c ON
		p.rf_idCase=c.rf_idCase
WHERE id=1

CREATE TABLE #tTotal(idRow INT,
					Col3 int  not null default(0),
					Col4 int  not null default(0),
					Col5 int  not null default(0),
					Col6 int  not null default(0),
					Col7 int  not null default(0),
					Col8 decimal(15,1)  not null default(0.0),
					Col9  int not null default(0),
					Col10 int not null default(0),
					Col11 decimal(15,1) not null default(0.0),
					Col12 int not null default(0),
					Col13 int not null default(0),
					Col14 int not null default(0),
					Col15 int not null default(0),
					Col16  decimal(15,1) not null default(0.0),
					Col17  decimal(15,1) not null default(0.0),
					Col18 int not null default(0),
					Col19 int not null default(0),
					Col20 int not null default(0),
					Col21  decimal(15,1) not null default(0.0),
					Col22 int not null default(0),
					Col23 int not null default(0),
					Col24 int not null default(0),
					Col25 decimal(15,1) not null default(0.0),
					Col26 int not null default(0),
					Col27 decimal(15,1) not null default(0.0),
					Col28 int not null default(0),
					Col29 int not null default(0),
					Col30 int not null default(0),
					Col31 int not null default(0),
					Col32 int not null default(0),
					Col33 int not null default(0),
					Col34 int not null default(0),
					Col34_1 int not null default(0),
					Col35 int not null default(0),
					Col36 int not null default(0),
					Col37 int not null default(0),
					Col38 int not null default(0),
					Col39 int not null default(0),
					Col39_1 int not null default(0)
					)
 INSERT #tTotal( idRow ,Col3 ,Col4 ,Col5 ,Col6 ,Col7 ,Col8 ,Col9 ,Col10 ,Col11 ,Col12 ,Col13 ,Col14 ,Col15 ,Col16 ,Col17 ,Col18 ,Col19 ,Col20 ,Col21 ,Col22 ,Col23 ,Col24 ,Col25 ,
				Col26 ,Col27 ,Col28 ,Col29 ,Col30 ,Col31 ,Col32 ,Col33 ,Col34 ,Col34_1 ,Col35 ,Col36 ,Col37 ,Col38 ,Col39 ,Col39_1)
SELECT 1,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1

UNION ALL
SELECT 2,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 3,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>17 AND Age<40 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 4,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>39 AND Age<60 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 5,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>59 AND Age<66 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 6,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>65 AND Age<75 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 7,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>74 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 8,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73)
UNION ALL
----------------------------------------------------------Women-------------------------------------------
SELECT 9,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2
UNION ALL
SELECT 10,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ2') THEN AmountPaymentAccepted ELSE 0 end) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 11,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>17 AND Age<40 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 12,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>39 AND Age<55 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 13,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	 ----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>54 AND Age<66 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 14,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp='ÄÂ1' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>65 AND Age<75 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 15,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>74 AND ISNULL(IsTypeDisp,3)=3
UNION ALL
SELECT 16,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(CASE WHEN TypeDisp IN('ÄÂ2','ÄÂ3') THEN AmountPaymentAccepted ELSE 0 end) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73,50,52,56,58,62,64,68,70) 
UNION ALL
SELECT 17,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73)
UNION ALL
SELECT 18,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
	 ,SUM(AmountPaymentAccepted) AS Col8
	 ,count( DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col9
	 ,0 AS Col10
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') THEN AmountPaymentAccepted ELSE 0.0 END) AS Col11
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col12
	 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
	 ,sum(CASE WHEN TypeDisp='ÄÂ2' THEN AmountPaymentAccepted ELSE 0.0 END) AS Col14
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col15
	 ,sum( CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 THEN AmountPaymentAccepted ELSE 0.0 END) AS Col16
	 ,sum(CASE WHEN AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col17
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND AmountPay>0 THEN ENP ELSE null END) AS Col18
	 ,0 AS Col19,0 AS Col20
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col21
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col22
	 ,count(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' THEN ENP ELSE null END) AS Col23
	 ,0 AS Col24
	 ,sum(CASE WHEN TypeDisp ='ÄÂ2' and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col25
	 ,count(DISTINCT CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 AND AmountPay>0 THEN ENP ELSE null END) AS Col26
	 ,sum(CASE WHEN TypeDisp IN('ÄÂ1','ÄÂ3') AND IsMobileTeam=1 and AmountPaymentAccepted>0 THEN AmountPay ELSE 0.0 END) AS Col27
	----------------------------------------------------------------------------------------------------------------------	  
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND IsCalc28=1 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND IsCalc28=1 and TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsCalc28=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 and TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND IsLastCase=1 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
	 -----------------------------------------------------------------------------------------------------------------------
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)>0 AND ISNULL(pp.NAZR,9)<3 then p.ENP ELSE NULL END ) AS col34
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.rf_idV015,9)=17 then p.ENP ELSE NULL END ) AS col34_1
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=3 then p.ENP ELSE NULL END ) AS col35
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=4 then p.ENP ELSE NULL END ) AS col36
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=5 then p.ENP ELSE NULL END ) AS col37
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(pp.NAZR,9)=6 then p.ENP ELSE NULL END ) AS col38	 
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND ISNULL(IsNeedDisp,9)>0 AND ISNULL(IsNeedDisp,9)<3 THEN p.ENP ELSE NULL END ) AS col39
	 ,COUNT(DISTINCT CASE WHEN AmountPaymentAccepted>0 AND AmountPay>0 AND IsCanser=1 then p.ENP ELSE NULL END ) AS col39_1
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(50,52,56,58,62,64,68,70) 


 INSERT #tTotal( idRow ,Col10 ,Col19 ,Col20 ,Col24)
SELECT 1
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3                  
WHERE SMO=@codeSMO AND e.Sex=1 
UNION ALL
SELECT 2
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2')
UNION ALL
SELECT 3
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>17 AND p.Age<40
UNION ALL
SELECT 4
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>39 AND p.Age<60
UNION ALL
SELECT 5
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>59 AND p.Age<66
UNION ALL
SELECT 6
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>65 AND p.Age<75
UNION ALL
SELECT 7
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>74 
UNION ALL
SELECT 8
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=1 AND TypeDisp ='ÄÂ3'
---------------------------------------------------------------------
UNION ALL
SELECT 9
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2
UNION ALL
SELECT 10
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2')
UNION ALL
SELECT 11
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') and p.Age>17 AND p.Age<40
UNION ALL
SELECT 12
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>39 AND p.Age<55
UNION ALL
SELECT 13
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		 ,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>54 AND p.Age<66
UNION ALL
SELECT 14
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND p.Age>65 AND p.Age<75
UNION ALL
SELECT 15
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') and p.Age>74
UNION ALL
SELECT 16
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp ='ÄÂ3'
UNION ALL
SELECT 17
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp ='ÄÂ3' AND p.Age IN(49,53,55,59,61,65,67,71,73)
UNION ALL
SELECT 18
		,count( DISTINCT CASE WHEN p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPaymentAccepted>0 THEN p.ENP ELSE NULL END) AS Col10
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 THEN p.ENP ELSE null END) AS Col19
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp IN('ÄÂ1','ÄÂ3') AND p.AmountPay>0 AND stage=1 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col120
		,count(DISTINCT CASE WHEN p.AmountPaymentAccepted>0 AND p.TypeDisp ='ÄÂ2' AND p.AmountPay>0 AND stage=2 AND Date_I<@dtEndB THEN ENP3 ELSE null END) AS Col124
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
					LEFT JOIN dbo.t_R03Enp r ON
			p.enp=r.enp3
WHERE SMO=@codeSMO AND e.Sex=2 AND TypeDisp ='ÄÂ3' AND p.Age IN(50,52,56,58,62,64,68,70)
------------------------------------------------------------------------------------------------------------------------
 INSERT #tTotal( idRow ,Col5 ,Col6 ,Col7)
SELECT 1,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 
UNION ALL
SELECT 2,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp	  			
WHERE SMO=@codeSMO AND e.Sex=1	 aND e.age NOT IN( 49, 53, 55, 59, 61, 65, 67, 71, 73)
UNION ALL
SELECT 3,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7		
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.Age>17 AND e.Age<40
UNION ALL
SELECT 4,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.Age>39 AND e.Age<60  AND e.age not IN( 49, 53, 55, 59)
UNION ALL
SELECT 5,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7		
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.Age>59 AND e.Age<66 AND e.age not IN(61, 65)
UNION ALL
SELECT 6,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7			
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.Age>65 AND e.Age<75 AND e.age not IN( 67, 71, 73)
UNION ALL
SELECT 7,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.Age>74 
UNION ALL
SELECT 8,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp					
WHERE SMO=@codeSMO AND e.Sex=1 AND e.age IN( 49, 53, 55, 59, 61, 65, 67, 71, 73) --TypeDisp ='ÄÂ3'
---------------------------------------------------------------------
UNION ALL
SELECT 9,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2
UNION ALL
SELECT 10,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7		
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 AND e.Age not IN(50,52,56,58,62,64,68,70,49,53,55,59,61,65,67,71,73) 
UNION ALL
SELECT 11,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 and e.Age>17 AND e.Age<40
UNION ALL
SELECT 12,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7			
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 AND e.Age>39 AND e.Age<55  AND e.Age not IN(50,52,49,53)
UNION ALL
SELECT 13,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 AND e.Age>54 AND e.Age<66 AND e.Age not IN(56,58,62,64,55,59,61,65)
UNION ALL
SELECT 14,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 AND e.Age>65 AND e.Age<75 AND e.Age not IN(68,70,67,71,73)
UNION ALL
SELECT 15,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 and e.Age>74
UNION ALL
SELECT 16,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7				
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 AND e.Age  IN(50,52,56,58,62,64,68,70,49,53,55,59,61,65,67,71,73)--TypeDisp ='ÄÂ3'
UNION ALL
SELECT 17,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7			
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 /*AND TypeDisp ='ÄÂ3' */AND e.Age IN(49,53,55,59,61,65,67,71,73)
UNION ALL
SELECT 18,COUNT(DISTINCT ENP2) AS Col5
		,COUNT(DISTINCT ENP2) AS Col6
		,COUNT(DISTINCT CASE WHEN Date_B<@dtEndB then ENP2 ELSE NULL END ) AS Col7			
FROM dbo.t_R02ENP e LEFT JOIN #tPeople p ON
			e.enp2=p.enp
WHERE SMO=@codeSMO AND e.Sex=2 /*AND TypeDisp ='ÄÂ3'*/ AND e.Age IN(50,52,56,58,62,64,68,70) 

----------------------------------------------------------------- 
SELECT idRow ,SUM(Col3) Col3 ,sum(Col4) AS Col4 ,sum(Col5) AS Col5 ,sum(Col6) AS Col6,sum(Col7) AS Col7 ,sum(Col8) AS Col8 ,sum(Col9) AS Col9,sum(Col10) AS Col10 ,sum(Col11) AS Col11 
			,sum(Col12) AS Col12 ,sum(Col13) AS Col13 ,sum(Col14) AS Col14,sum(Col15) AS Col15,sum(Col16) AS Col16,sum(Col17) AS Col17,sum(Col18) AS Col18,sum(Col19) AS Col19,sum(Col20) AS Col20 
			,sum(Col21) AS Col21,sum(Col22) AS Col22,sum(Col23) AS Col23,sum(Col24) AS Col24,sum(Col25) AS Col25,sum(Col26) AS Col26,sum(Col27) AS Col27,sum(Col28) AS Col28,sum(Col29) AS Col29
			,sum(Col30) AS Col30,sum(Col31) AS Col31,sum(Col32) AS Col32,sum(Col33) AS Col33,sum(Col34) AS Col34,sum(Col34_1) AS Col34_1,sum(Col35) AS Col35,sum(Col36) AS Col36,sum(Col37) AS Col37
			,sum(Col38) AS Col38,sum(Col39) AS Col39,sum(Col39_1) AS Col39_1
FROM #tTotal
GROUP BY idRow
ORDER BY idRow 

SELECT 9,0 ,SUM(AmountPaymentAccepted) AS Col8, IsTypeDisp, TypeDisp
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2
GROUP BY IsTypeDisp, TypeDisp
--------------------------------------------------------------------------------
/*
SELECT 9,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2

SELECT 10,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13	 
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND ISNULL(IsTypeDisp,3)=3

SELECT 16 ,count( DISTINCT CASE WHEN TYpeDisp='ÄÂ2' and AmountPaymentAccepted>0 THEN ENP ELSE NULL END) AS Col13
FROM #tPeople p LEFT JOIN #prescription pp ON
		p.rf_idCase=pp.rf_idCase
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73,50,52,56,58,62,64,68,70) 
*/

;WITH cte1
AS(
SELECT 16 AS Col1 ,ENP,TYpeDisp, IsTypeDisp
FROM #tPeople p 
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73,50,52,56,58,62,64,68,70) AND AmountPaymentAccepted>0
),cte2 AS(
SELECT 10 AS Col2,ENP,TYpeDisp, IsTypeDisp
FROM #tPeople p 
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ2') AND ISNULL(IsTypeDisp,3)=3 AND AmountPaymentAccepted>0
)
SELECT *
FROM cte1 c1 INNER JOIN cte2 c2 ON
		c1.enp=c2.enp
order BY c1.enp


--SELECT ENP, TYpeDisp
--FROM #tPeople p 
--WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ3','ÄÂ2') AND ISNULL(IsTypeDisp,2)=2 AND Age IN(49,53,55,59,61,65,67,71,73,50,52,56,58,62,64,68,70) AND AmountPaymentAccepted>0
--GROUP BY ENP, TYpeDisp
--HAVING COUNT(*)>1


--SELECT ENP, TYpeDisp
--FROM #tPeople p 
--WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND ISNULL(IsTypeDisp,3)=3 AND AmountPaymentAccepted>0
--GROUP BY ENP, TYpeDisp
--HAVING COUNT(*)>1

SELECT *
FROM #tPeople WHERE ENP='3458730868000699'

SET STATISTICS TIME, IO OFF

GO
DROP TABLE #tPeople
DROP TABLE #prescription
DROP TABLE #tTotal