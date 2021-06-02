USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME='20190409',
		@reportYear SMALLINT=2019,
		@dateEndAkt DATETIME='20190409'		

----берем с диагнозом из списка
SELECT DISTINCT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient,ps.ENP,r.AttachLPU, c.AmountPayment AS AmountPay ,f.CodeM, DATEDIFF(DAY, dm.DirectionDate,c.DateBegin) AS DiffDay
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
			--		INNER JOIN dbo.t_Meduslugi m ON
			--c.id=m.rf_idCase                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND dd.DS_ONK=1 --AND f.CodeM<>'103001'
AND dm.TypeDirection IN(1,2) and c.rf_idV002=60 --AND m.MU IN('2.78.19','2.78.45','2.78.87','2.79.18','2.79.43','2.88.24','2.88.25','2.88.63','2.88.73','2.88.89',
								--											 '2.88.101','2.81.24','2.81.25','2.81.26','2.81.27','2.81.28','2.81.29','2.81.30','2.81.31','2.81.32','2.81.33','2.81.45')


UPDATE p SET p.AmountPay=p.AmountPay-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT COUNT(DISTINCT ENP) AS Col17--, COUNT(DISTINCT rf_idCase) AS Col17_cases
from #tCases WHERE AmountPay>0 AND DiffDay IN (0,1)	

SELECT COUNT(DISTINCT ENP) AS Col18--, COUNT(DISTINCT rf_idCase) AS Col18_cases
from #tCases WHERE AmountPay>0 AND DiffDay IN (0,1)	AND AttachLPU=CodeM

SELECT COUNT(DISTINCT ENP) AS Col19--, COUNT(DISTINCT rf_idCase) AS Col19_cases
from #tCases WHERE AmountPay>0 AND DiffDay<0

SELECT COUNT(DISTINCT ENP) AS Col20--, COUNT(DISTINCT rf_idCase) AS Col20_cases
from #tCases WHERE AmountPay>0 AND DiffDay<0	AND AttachLPU=CodeM


GO
DROP TABLE #tCases