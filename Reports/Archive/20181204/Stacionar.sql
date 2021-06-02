USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20181130',
		@dateEndPay DATETIME='20181130',
		@reportYear SMALLINT=2018
		
SELECT  code,name INTO #tmpCSG FROM dbo.vw_sprCSG WHERE dateBeg>'20171231' 

SELECT code into #tCSGS FROM dbo.vw_sprCSG WHERE code LIKE '114[6-9]._'
UNION ALL
SELECT code FROM dbo.vw_sprCSG WHERE code LIKE '115[0-5]._'

SELECT c.id,f.CodeM,c.AmountPayment,m.MES,Name, LEFT(m.MES,4) AS CodeCSG,c.Age
INTO #tPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
					INNER JOIN #tmpCSG	csg ON
			m.MES=csg.code                  									
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<11 AND a.ReportYear=@reportYear AND c.rf_idV008=31 AND c.rf_idV010=33		
		AND c.rf_idV006=1
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 									 
							FROM dbo.t_PaymentAcceptedCase2 a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay 
							GROUP BY rf_idCase
							) r ON
			p.id=r.rf_idCase


SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,c2019.CSG2019,c2019.NameCSG2019 AS NameCSG, p.id
into #total
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				 INNER JOIN dbo.tmpCASG2019 c2019 ON
			p.CodeCSG=c2019.CodeCSG				          			
WHERE AmountPayment>0			
UNION ALL
SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,c2019.CSG2019,c2019.NameCSG2019 AS NameCSG, p.id
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				INNER JOIN #tCSGS s ON
			p.MES=s.code              
				INNER JOIN dbo.t_AdditionalCriterion a ON
			p.id=a.rf_idCase              
				 INNER JOIN dbo.tmpCSGSchema cc ON
			a.rf_idAddCretiria=cc.CodeSchema	
				INNER JOIN dbo.tmpCASG2019 c2019 ON
			cc.CodeCSG2019=c2019.CSG2019		
WHERE AmountPayment>0  AND cc.rf_idV006=1
UNION ALL
SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,'st23.003',(SELECT DISTINCT NameCSG2019 FROM dbo.tmpCASG2019 WHERE CSG2019='st23.003'), p.id
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				 INNER JOIN dbo.vw_Diagnosis d ON
			p.id=d.rf_idCase       			
WHERE AmountPayment>0 AND p.MES='1015.0' AND d.DS1 IN('D86.0','86,2')
UNION ALL
SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,'st23.001',(SELECT DISTINCT NameCSG2019 FROM dbo.tmpCASG2019 WHERE CSG2019='st23.001'), p.id
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				 INNER JOIN dbo.vw_Diagnosis d ON
			p.id=d.rf_idCase       			
WHERE AmountPayment>0 AND p.MES='1015.0' AND d.DS1 NOT IN('D86.0','D86,2')
UNION ALL
SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,'st23.009',(SELECT DISTINCT NameCSG2019 FROM dbo.tmpCASG2019 WHERE CSG2019='st15.009'), p.id
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				 INNER JOIN dbo.vw_Diagnosis d ON
			p.id=d.rf_idCase       			
WHERE AmountPayment>0 AND p.MES='1086.0' AND d.DS1 IN('G82.1','G82.4','G82.5')
UNION ALL
SELECT l.filialCode,l.filialName,p.CodeM+' - '+l.NAMES AS LPU,'st23.008',(SELECT DISTINCT NameCSG2019 FROM dbo.tmpCASG2019 WHERE CSG2019='st15.008'), p.id
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM
				 INNER JOIN dbo.vw_Diagnosis d ON
			p.id=d.rf_idCase       			
WHERE AmountPayment>0 AND p.MES='1086.0' AND d.DS1 not IN('G82.1','G82.4','G82.5')

SELECT  filialCode ,filialName ,LPU ,CSG2019 ,NameCSG ,COUNT(id)
FROM #total 
GROUP BY filialCode ,filialName ,LPU ,CSG2019 ,NameCSG


-----------------------MISSING
SELECT p.codem,p.CodeM+' - '+l.NAMES AS LPU, d.DS1,p.Age , ISNULL(a.rf_idAddCretiria,'') AS Ad_Criterion,p.mes,p.NAME AS NameCSG, COUNT(p.id) AS CountCase
		,MAX(CASE WHEN idMU=1 THEN m.MUSurgery ELSE '' END) AS MUSurgery1 
		,MAX(CASE WHEN idMU=2 THEN m.MUSurgery ELSE '' END) AS MUSurgery2
		,MAX(CASE WHEN idMU=3 THEN m.MUSurgery ELSE '' END) AS MUSurgery3
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
			p.CodeM=l.CodeM			
				INNER JOIN dbo.vw_Diagnosis d ON
			p.id=d.rf_idCase       	
				LEFT JOIN dbo.t_AdditionalCriterion a ON
			p.id=a.rf_idCase  
				LEFT JOIN (SELECT ROW_NUMBER() OVER(PARTITION BY m.rf_idCase ORDER BY m.id) AS idMU, rf_idCase ,m.MUSurgery
							from dbo.t_Meduslugi m WHERE m.MUSurgery IS NOT NULL
						 	) m ON
			p.id=m.rf_idCase            
WHERE AmountPayment>0 AND NOT EXISTS(SELECT 1 FROM #total WHERE id=p.id) 
GROUP BY p.codem,p.CodeM+' - '+l.NAMES, d.DS1,p.Age , ISNULL(a.rf_idAddCretiria,'') , p.mes,p.NAME
	--,CASE WHEN idMU=1 THEN m.MUSurgery ELSE '' END
	--,CASE WHEN idMU=2 THEN m.MUSurgery ELSE '' END
	--,CASE WHEN idMU=3 THEN m.MUSurgery ELSE '' END
ORDER BY codeM,MES,age,DS1 
GO
DROP TABLE #tmpCSG
DROP  TABLE #tPeople
DROP TABLE #tCSGS 
DROP TABLE #total