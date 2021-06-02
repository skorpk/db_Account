USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150101',
		@dateEnd DATETIME='20160129',
		@dateEndPay DATETIME='20160130'

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  CodeM CHAR(6),
					  MES VARCHAR(20),	
					  NameMES VARCHAR(200),					  				  
					  rf_idV002 SMALLINT,
					  AgeType TINYINT,
					  AmountPayment decimal(11,2) 
					  )
INSERT #tPeople (rf_idCase,CodeM,MES,NameMES,rf_idV002,AgeType,AmountPayment) 
SELECT c.id,f.CodeM,m.MES,csg.name,c.rf_idV002,CASE WHEN c.Age>=0 AND c.Age<5 THEN 1 WHEN c.age>74 THEN 2 ELSE 0 END AS Age,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN dbo.vw_sprCSG csg ON
		m.MES=csg.code
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2015 AND c.rf_idV006=1 AND SUBSTRING(csg.code,3,2)IN ('00','03','04','06','07','08','09')
AND c.rf_idV008<>32

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


SELECT l.CodeM,l.NAMES,p.MES,p.NameMES,COUNT(p.rf_idCase) AS TotalCases, AgeType
FROM #tPeople p	INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		p.rf_idV002=v2.id              
WHERE p.AmountPayment>0	AND AgeType>0
GROUP BY l.CodeM,l.NAMES,p.MES,p.NameMES, AgeType
GO
DROP TABLE #tPeople