USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190509',
		@reportYear SMALLINT=2019,
		@dateEndAkt DATETIME='20190509'		

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,r.AttachLPU, c.AmountPayment AS AmountPay,f.CodeM,m.MU
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 			
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DirectionMU dm ON
			c.id=dm.rf_idCase					 												   					  					      
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.DS_ONK=1 AND f.CodeM<>'103001'
AND dm.TypeDirection=2 AND m.MU IN('2.78.19','2.78.45','2.78.87','2.79.18','2.79.43','2.88.24','2.88.25','2.88.63','2.88.73','2.88.89',
																			 '2.88.101','2.81.24','2.81.25','2.81.26','2.81.27','2.81.28','2.81.29','2.81.30','2.81.31','2.81.32','2.81.33','2.81.45')

CREATE TABLE #tmpMagalyz(Col17 INT NOT NULL DEFAULT 0,Col18 INT NOT NULL DEFAULT 0,Col19 INT NOT NULL DEFAULT 0,Col20 INT NOT NULL DEFAULT 0,Col21 INT NOT NULL DEFAULT 0,Col22 INT NOT NULL DEFAULT 0
						  ,Col23 INT NOT NULL DEFAULT 0,Col24 INT NOT NULL DEFAULT 0,Col25 INT NOT NULL DEFAULT 0,Col26 INT NOT NULL DEFAULT 0
						  )

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tmpMagalyz( Col17)
SELECT COUNT(DISTINCT enp) AS Col17
from #tCases 
WHERE AmountPay>0

INSERT #tmpMagalyz( Col18)
SELECT COUNT(DISTINCT enp) AS Col18
from #tCases 
WHERE AmountPay>0 AND CodeM=AttachLPU
---------------------------------------------------
----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,r.AttachLPU, c.AmountPayment AS AmountPay,f.CodeM,m.MU,DATEDIFF(day,dm.DirectionDate,c.DateBegin) AS DateDiffrence,dm.DirectionDate,c.DateBegin,
		MethodStudy
INTO #tCases2
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 			
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DirectionMU dm ON
			c.id=dm.rf_idCase					 												   					  					      
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.DS_ONK=1 
AND dm.TypeDirection=3 AND m.MU IN('2.78.19','2.78.45','2.78.87','2.79.18','2.79.43','2.88.24','2.88.25','2.88.63','2.88.73','2.88.89',
																			 '2.88.101','2.81.24','2.81.25','2.81.26','2.81.27','2.81.28','2.81.29','2.81.30','2.81.31','2.81.32','2.81.33','2.81.45')

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases2 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tmpMagalyz( Col21)
SELECT COUNT(DISTINCT enp) AS Col21
from #tCases2 
WHERE AmountPay>0 AND DateDiffrence<=1 AND MethodStudy=4

INSERT #tmpMagalyz( Col22)
SELECT COUNT(DISTINCT enp) AS Col22
from #tCases2 
WHERE AmountPay>0 AND CodeM=AttachLPU AND DateDiffrence<=1 AND MethodStudy=4

INSERT #tmpMagalyz( Col23)
SELECT COUNT(DISTINCT enp) AS Col23
from #tCases2 
WHERE AmountPay>0 AND DateDiffrence>1 AND MethodStudy=4

INSERT #tmpMagalyz( Col24)
SELECT COUNT(DISTINCT enp) AS Col24
from #tCases2 
WHERE AmountPay>0 AND CodeM=AttachLPU AND DateDiffrence>1 AND MethodStudy=4

-------------------------------------------------------------
----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,c.AmountPayment AS AmountPay, u.rf_idN013 AS USL_TIP
INTO #tCases3
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient					
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					INNER JOIN dbo.t_DirectionMU dm ON
			c.id=dm.rf_idCase
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase       
					-- INNER JOIN dbo.t_Consultation cc ON
			-- c.id=cc.rf_idCase    
					INNER JOIN dbo.t_ONK_SL o ON
			c.id=o.rf_idCase              
					INNER JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND d.DS1 LIKE 'C%' --AND cc.PR_CONS=2
		AND o.DS1_T=0 AND u.rf_idN013 IN(1,2,3,4) AND c.DateBegin>='20190101' and c.rf_idV006<3
UNION all
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,c.AmountPayment AS AmountPay, u.rf_idN013
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 			
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient	
					 -- INNER JOIN dbo.t_Consultation cc ON
			-- c.id=cc.rf_idCase                  
					 INNER JOIN dbo.t_ONK_SL o ON
			c.id=o.rf_idCase              
					INNER JOIN dbo.t_ONK_USL u ON
			c.id=u.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.DS_ONK=1 /*AND cc.PR_CONS=2*/ AND c.DateBegin>='20190101'
		AND o.DS1_T=0 AND u.rf_idN013 IN(1,2,3,4) and c.rf_idV006<3

UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases3 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tmpMagalyz( Col25)
SELECT COUNT(DISTINCT enp) AS Col25
from #tCases3 
WHERE AmountPay>0

INSERT #tmpMagalyz( Col26)
SELECT COUNT(DISTINCT enp) AS Col26
from #tCases3 
WHERE AmountPay>0 AND USL_TIP=2

select SUM(Col17) AS Col17,SUM(Col18) AS Col18,0 AS Col19,0 AS Col20,SUM(Col21) AS Col21,SUM(Col22) AS Col22,SUM(Col23) AS Col23,
		SUM(Col24) AS Col24,SUM(Col25) AS Col25,SUM(Col26) AS Col26
FROM #tmpMagalyz

GO
DROP TABLE #tCases
GO
DROP TABLE #tCases2
GO
DROP TABLE #tCases3
GO
DROP TABLE #tmpMagalyz