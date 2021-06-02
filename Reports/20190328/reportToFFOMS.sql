USE AccountOMS
GO
DECLARE @dateStart DATETIME='20170101',
		@dateEnd DATETIME=GETDATE(),
		@dateEndAkt DATETIME=GETDATE(),
		@reportYear SMALLINT=2017

							
SELECT c.id AS rf_idCase, c.AmountPayment, c.AmountPayment AS AmountPay,p.ENP, a.ReportYear,c.rf_idV006, r.id
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
			r.id = p.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN PeopleAttach.dbo.p3473301591 pp ON
			p.ENP=pp.Enp					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear>=@reportYear AND a.ReportYear<2019 AND a.rf_idSMO<>'34'

INSERT #tCases
SELECT c.id rf_idCase, cc.AmountPayment, cc.AmountPayment AS AmountPay,p.ENP, a.ReportYear,c.rf_idV006,r.id  
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
			r.id = p.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient	
					INNER JOIN PeopleAttach.dbo.p3473301591 pp ON
			p.ENP=pp.ENP					
WHERE f.DateRegistration>'20190101' AND f.DateRegistration<@dateEnd  AND a.ReportYear=2019 AND a.ReportMonth<3 AND a.rf_idSMO<>'34'


UPDATE p SET p.AmountPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndAkt	 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT v6.id,v6.Name
		,COUNT(CASE WHEN ReportYear=2017 THEN c.id ELSE NULL END) AS Col2017_Count
		,SUM(CASE WHEN ReportYear=2017 THEN AmountPay ELSE 0.0 END) AS Col2017_Sum
		----------2018------------------------------
		,COUNT(CASE WHEN ReportYear=2018 THEN c.id ELSE NULL END) AS Col2017_Count
		,SUM(CASE WHEN ReportYear=2018 THEN AmountPay ELSE 0.0 END) AS Col2017_Sum
		----------2019------------------------------
		,COUNT(CASE WHEN ReportYear=2019 THEN c.id ELSE NULL END) AS Col2017_Count
		,SUM(CASE WHEN ReportYear=2019 THEN AmountPay ELSE 0.0 END) AS Col2017_Sum
from #tCases c INNER JOIN oms_nsi.dbo.sprV006 v6 ON
		c.rf_idV006=v6.Id
WHERE rf_idV006<4
GROUP BY v6.id,v6.Name
ORDER BY v6.id
-------------------------------------------яло------------------------------
SELECT  COUNT(CASE WHEN ReportYear=2017 AND AmountPayment=0 AND AmountPay=0 THEN c.id ELSE NULL END) AS Col2017_Count_Empty
		,SUM(CASE WHEN ReportYear=2017 and AmountPayment=0 AND AmountPay=0 THEN AmountPay ELSE 0.0 END) AS Col2017_Sum_Empty
		,COUNT(CASE WHEN ReportYear=2017 AND AmountPayment>0 AND AmountPay>0 THEN c.id ELSE NULL END) AS Col2017_Count_Not_Empty
		,SUM(CASE WHEN ReportYear=2017 and AmountPayment>0 AND AmountPay> 0THEN AmountPay ELSE 0.0 END) AS Col2017_Sum_Not_Empty
		----------2018------------------------------
		,COUNT(CASE WHEN ReportYear=2018 AND AmountPayment=0 AND AmountPay=0 THEN c.id ELSE NULL END) AS Col2018_Count_Empty
		,SUM(CASE WHEN ReportYear=2018 and AmountPayment=0 AND AmountPay=0 THEN AmountPay ELSE 0.0 END) AS Col2018_Sum_Empty
		,COUNT(CASE WHEN ReportYear=2018 AND AmountPayment>0 AND AmountPay>0 THEN c.id ELSE NULL END) AS Col2018_Count_Not_Empty
		,SUM(CASE WHEN ReportYear=2018 and AmountPayment>0   AND AmountPay>0THEN AmountPay ELSE 0.0 END) AS Col2018_Sum_Not_Empty
		----------2019------------------------------
		,COUNT(CASE WHEN ReportYear=2019 AND AmountPayment=0 AND AmountPay=0 THEN c.id ELSE NULL END) AS Col2019_Count_Empty
		,SUM(CASE WHEN ReportYear=2019 and AmountPayment=0 AND AmountPay=0 THEN AmountPay ELSE 0.0 END) AS Col2019_Sum_Empty
		,COUNT(CASE WHEN ReportYear=2019 AND AmountPayment>0  AND AmountPay>0 THEN c.id ELSE NULL END) AS Col2019_Count_Not_Empty
		,SUM(CASE WHEN ReportYear=2019 and AmountPayment>0    AND AmountPay>0 THEN AmountPay ELSE 0.0 END) AS Col2019_Sum_Not_Empty
from #tCases c 
WHERE c.rf_idV006=4
GO
DROP TABLE #tCases