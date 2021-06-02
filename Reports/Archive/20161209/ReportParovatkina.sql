USE AccountOMSReports
GO
DECLARE @dtStart DATETIME='20160101',
		@dtEnd DATETIME='20161208 23:59:59'

SELECT c.id AS rf_idCase, c.rf_idV006,c.AmountPayment,p.IDPeople AS PID,CASE WHEN a.rf_idSMO='34' THEN 1 ELSE 0 END AS NonResident
INTO  #tmpPeople
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
					INNER JOIN dbo.t_People_Case p ON
			c.id=p.rf_idCase                  
WHERE f.DateRegistration>@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=2016 AND a.ReportMonth<12 
		AND mkb.MainDS IN ('J12','J13','J14','J15','J16','J18') 

UPDATE p SET p.AmountPayment=p.AmountPayment-pr.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT p.rf_idCase,SUM(AmountDeduction) AS AmountDeduction
							  FROM #tmpPeople p INNER JOIN dbo.t_PaymentAcceptedCase pd ON
										p.rf_idCase=pd.rf_idCase
							  WHERE pd.DateRegistration>@dtStart AND pd.DateRegistration<=GETDATE()
							  GROUP BY p.rf_idCase)	pr ON
				p.rf_idCase=pr.rf_idCase                            

SELECT 'Жители Волгоградской области' AS Col1,COUNT(DISTINCT PID) 
FROM #tmpPeople p
WHERE p.AmountPayment>0 AND NonResident=0
UNION ALL
SELECT 'Жители других регионов',COUNT(DISTINCT PID) 
FROM #tmpPeople p
WHERE p.AmountPayment>0 AND NonResident=1
UNION ALL
SELECT 'Жители Волгоградской области(амбулаторка)' AS Col1,COUNT(DISTINCT PID) 
FROM #tmpPeople p
WHERE p.AmountPayment>0 AND NonResident=0 AND rf_idV006=3
GO
DROP TABLE #tmpPeople