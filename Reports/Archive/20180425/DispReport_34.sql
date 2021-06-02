USE AccountOMS
GO
DECLARE @startDateReg DATETIME='20180110',
		@endDateReg DATETIME='20180612',
		@endDateRegAkt DATETIME='20180620',
		@reportYear smallint=2018,
		@reportMonth TINYINT=5,
		@codeSMO CHAR(5)='34'

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
		AND c.DateEnd>='20180101' AND c.DateEnd<'20180601' AND a.Letter='O' AND d.TypeDisp IN ('ÄÂ1','ÄÂ2','ÄÂ3')
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
							FROM dbo.t_PaymentAcceptedCase2018 p INNER  JOIN #tPeople t ON			
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

;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd desc,DateRegistration desc) AS id, rf_idCase
FROM #tPeople pp WHERE TypeDisp IN('ÄÂ1') AND RSLT IN(352,353,354,357,358)
AND NOT EXISTS(SELECT 1 FROM #tPeople p WHERE p.TypeDisp='ÄÂ2' AND p.ENP=pp.ENP)
)
UPDATE p SET p.IsLastCase=1
FROM #tPeople p INNER JOIN cte c ON
		p.rf_idCase=c.rf_idCase
WHERE id=1

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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2')
UNION ALL
SELECT 3,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>17 AND Age<40
UNION ALL
SELECT 4,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>39 AND Age<60
UNION ALL
SELECT 5,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>59 AND Age<66
UNION ALL
SELECT 6,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>65 AND Age<75
UNION ALL
SELECT 7,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>74
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=1 AND TypeDisp ='ÄÂ3' AND Age IN(49,53,55,59,61,65,67,71,73)
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2')
UNION ALL
SELECT 11,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>17 AND Age<40
UNION ALL
SELECT 12,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>39 AND Age<55
UNION ALL
SELECT 13,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>54 AND Age<66
UNION ALL
SELECT 14,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>65 AND Age<75
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp IN('ÄÂ1','ÄÂ2') AND Age>74
UNION ALL
SELECT 16,0 AS Col3,0 AS Col4,0 AS Col5,0 AS Col6,0 AS Col7
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1 */AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp ='ÄÂ3' 
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp ='ÄÂ3' AND Age IN(49,53,55,59,61,65,67,71,73)
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
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2') OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1) THEN ENP ELSE NULL END) AS col28
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND TypeFailure=1) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND IsLastCase=1 AND TypeFailure=1) THEN ENP ELSE NULL END) AS col29
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=317) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=352) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=317) THEN ENP ELSE NULL END) AS col30
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=318) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=353) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=318) THEN ENP ELSE NULL END) AS col31
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=355) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=357) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=355) THEN ENP ELSE NULL END) AS col32
	 ,COUNT( DISTINCT CASE WHEN (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp='ÄÂ2' AND RSLT=356) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') /*AND IsLastCase=1*/ AND RSLT=358) OR (AmountPaymentAccepted>0 AND AmountPay>0 AND TypeDisp IN('ÄÂ1','ÄÂ3') AND RSLT=356) THEN ENP ELSE NULL END) AS col33
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
WHERE rf_idV005=2 AND TypeDisp ='ÄÂ3' AND Age IN(50,52,56,58,62,64,68,70)
GO
DROP TABLE #tPeople
DROP TABLE #prescription