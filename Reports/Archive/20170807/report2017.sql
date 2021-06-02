USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20170701',
		@dtEndRAK DATETIME='20170701',
		@Year SMALLINT=2017,
		@month TINYINT=6

select	distinct 
		A.ogrn as OGRN, 
		left(A.tfomsCode,6) as MainCode, 
		LEFT(t1.tfomsCode,6) AS CodeM,
		A.mNameS as LPU, 
		B.code as CodeVP, 
		C.numlicense as License, 
		convert(date,D.beginDate) as DateBeg, 
		convert(date,case when D.terminationDate < D.endDate then D.terminationDate else D.endDate end) as DateEnd, 
		G.code as rf_idV002, 
		G.ServiceName as ProfileName  
INTO #tmpLPU
from	oms_nsi.dbo.tMO A inner join oms_nsi.dbo.tVP B on 
			A.rf_VPId = B.VPId 
						  inner join oms_nsi.dbo.tLicense C on 
			A.MOId = C.rf_MOId 
						  inner join oms_nsi.dbo.tLicensePeriod D on 
			C.LicenseId = D.rf_LicenseId 
						  inner join oms_nsi.dbo.tLicenseLocation E on 
			C.LicenseId = E.rf_LicenseId 
						  inner join oms_nsi.dbo.tMSLocation F on 
			E.LicenseLocationId = F.rf_LicenseLocationId 
						  inner join oms_nsi.dbo.tMedicalService G on 
			F.rf_MedicalServiceId = G.MedicalServiceId 
						  INNER JOIN oms_NSI.dbo.tMO t1 ON 
			a.MOId=t1.rf_FirstLvlId
where	B.code in (38,14,15,40) and 
		A.endDate >= '20170101' and 
		year(D.beginDate) <= @Year and 
		yeaR(case when D.terminationDate < D.endDate then D.terminationDate else D.endDate end) >= @Year --and 
order by 2,5,8

CREATE NONCLUSTERED INDEX ix_codem ON #tmpLPU(CodeM) INCLUDE(MainCode)


SELECT DISTINCT c.id, l.MainCode,c.AmountPayment,c.rf_idV006, c.rf_idV002, a.Letter
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN #tmpLPU l ON
		f.CodeM=l.CodeM			
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@Year AND a.ReportMonth<=@month AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtStart AND c.DateEnd<@dtEnd
		
UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 
															INNER JOIN #tmpPeople p ON
														c.rf_idCase=p.id																							
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

-----------------------------------------------------------------------------------------------------------------------------
;WITH ctePlan
AS
(
 SELECT c.id
		,t1.unitName
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM #tmpPeople p INNER JOIN t_Case c ON
		p.id=c.id
				INNER JOIN t_Meduslugi m ON
		c.id=m.rf_idCase 
				INNER JOIN RegisterCases.dbo.vw_sprMU t1 ON
		m.MU=t1.MU			
		AND t1.unitCode IS NOT NULL												
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND p.rf_idV006=3 AND p.Letter ='K'
		AND p.AmountPayment>0
GROUP BY c.id,t1.unitName
UNION ALL
 SELECT c.id
		,'Посещения для счетов не K' AS unitName
		,SUM(m.Quantity) AS Quantity
FROM #tmpPeople p INNER JOIN t_Case c ON
		p.id=c.id
				INNER JOIN t_Meduslugi m ON
		c.id=m.rf_idCase 				
WHERE p.rf_idV006=3 AND p.Letter NOT IN ('K') AND m.MUGroupCode=2 AND p.AmountPayment>0
GROUP BY c.id
UNION ALL
SELECT c.id
		,t1.unitName
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM #tmpPeople p INNER JOIN t_Case c ON
		p.id=c.id
				INNER JOIN t_Meduslugi m ON
		c.id=m.rf_idCase 
				INNER JOIN RegisterCases.dbo.vw_sprMU t1 ON
		m.MU=t1.MU			
		AND t1.unitCode IS NOT NULL												
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND p.rf_idV006 IN(1,2,4)
GROUP BY c.id,t1.unitName
--------------------------------------------------
UNION ALL
SELECT c.id
		,t1.unitName
		,SUM(CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM #tmpPeople p INNER JOIN t_Case c ON
			p.id=c.id
				INNER JOIN t_MES m ON
			c.id=m.rf_idCase 	
			and c.IsCompletedCase=1
				INNER JOIN (SELECT MU,beginDate,endDate,unitCode,unitName,ChildUET,AdultUET FROM RegisterCases.dbo.vw_sprMU 
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,unitName,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
							) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL			
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND p.rf_idV006=3 AND p.Letter='K'	AND p.AmountPayment>0
GROUP BY c.id,t1.unitName
UNION ALL
SELECT c.id
		,t1.unitName
		,SUM(CASE WHEN c.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM #tmpPeople p INNER JOIN t_Case c ON
			p.id=c.id
				INNER JOIN t_MES m ON
			c.id=m.rf_idCase 
			and c.IsCompletedCase=1
				INNER JOIN (SELECT MU,beginDate,endDate,unitCode,unitName,ChildUET,AdultUET FROM RegisterCases.dbo.vw_sprMU 
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,unitName,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit
							) t1 ON
		m.MES=t1.MU			
		AND t1.unitCode IS NOT NULL			
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND p.rf_idV006 IN(1,2,4)
GROUP BY c.id,t1.unitName	
)
SELECT id,unitName,sum(Quantity) AS Quntity INTO #tmpPlan FROM ctePlan GROUP BY id,unitname


;WITH cteTotal
AS(
SELECT p.MainCode ,p.rf_idV006,p.rf_idV002,SUM(p.AmountPayment) AS AmountPayment, pp.unitName, SUM(pp.Quntity) AS Quantity
FROM #tmpPeople p INNER JOIN #tmpPlan pp ON
		p.id=pp.id
WHERE p.AmountPayment>0
GROUP BY p.MainCode,p.rf_idV006,p.rf_idV002, pp.unitName
)
SELECT l.OGRN,l.MainCode,l.LPU, l.CodeVP, MIN(l.DateBeg) AS DateBeg, l.rf_idV002, l.ProfileName  
	,v6.name,c.unitName,CAST(c.Quantity AS MONEY) AS Quantity,cast(AmountPayment AS MONEY) AS AmountPay
from  cteTotal c INNER JOIN registerCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id
			inner JOIN #tmpLPU l ON
		c.MainCode=l.MainCode
		AND c.rf_idV002=l.rf_idV002
GROUP BY l.OGRN,l.MainCode,l.LPU, l.CodeVP, l.rf_idV002, l.ProfileName ,v6.name,c.unitName,CAST(c.Quantity AS MONEY) ,cast(AmountPayment AS MONEY)
go

DROP TABLE #tmpPeople
DROP TABLE #tmpLPU
DROP TABLE #tmpPlan