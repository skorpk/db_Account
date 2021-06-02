USE AccountOMS
GO
DECLARE @dtStart DATETIME='20150101',
		@dtEnd DATETIME='20160124',
		@dtEndRAK DATETIME='20170711',
		@Year SMALLINT=2015,
		@month TINYINT=12

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
		A.endDate >= @dtStart and 
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

ALTER TABLE #tmpPeople ADD IsMEE TINYINT NOT NULL DEFAULT(0)
ALTER TABLE #tmpPeople ADD IsEKMP TINYINT NOT NULL DEFAULT(0)
ALTER TABLE #tmpPeople ADD IsReasonMEE TINYINT NOT NULL DEFAULT(0)
ALTER TABLE #tmpPeople ADD IsReasonEKMP TINYINT NOT NULL DEFAULT(0)


UPDATE p SET p.IsMEE=r.IsMEE, p.IsEKMP=r.IsEKMP
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase, CASE WHEN TypeCheckup=2 THEN 1 ELSE 0 END IsMEE, CASE WHEN TypeCheckup=3 THEN 1 ELSE 0 END IsEKMP									
							  FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
							  						f.id=d.rf_idAFile
							  									INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
							  						d.id=a.rf_idDocumentOfCheckup
							  							INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
							  						a.id=c.rf_idCheckedAccount 								  							
							  WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND d.TypeCheckup>1
							  GROUP BY c.rf_idCase, CASE WHEN TypeCheckup=2 THEN 1 ELSE 0 END , CASE WHEN TypeCheckup=3 THEN 1 ELSE 0 END 
							) r ON
			p.id=r.rf_idCase

UPDATE p SET p.IsReasonMEE=1
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase
							  FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
							  						f.id=d.rf_idAFile
							  									INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
							  						d.id=a.rf_idDocumentOfCheckup
							  							INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
							  						a.id=c.rf_idCheckedAccount 	
														INNER JOIN #tmpPeople tp ON
													c.rf_idCase=tp.id																														  							
															INNER JOIN ExchangeFinancing.dbo.t_ReasonDenialPayment rp ON
													c.id=rp.rf_idCheckedCase                                                          
							  WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND tp.IsMEE=1 AND rp.CodeReason IS NOT NULL
							  GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

UPDATE p SET p.IsReasonEKMP=1
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase
							  FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
							  						f.id=d.rf_idAFile
							  									INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
							  						d.id=a.rf_idDocumentOfCheckup
							  							INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
							  						a.id=c.rf_idCheckedAccount 	
														INNER JOIN #tmpPeople tp ON
													c.rf_idCase=tp.id																														  							
															INNER JOIN ExchangeFinancing.dbo.t_ReasonDenialPayment rp ON
													c.id=rp.rf_idCheckedCase                                                          
							  WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND tp.IsEKMP=1 AND rp.CodeReason IS NOT NULL
							  GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase
;WITH cteExp
AS(
SELECT l.OGRN,l.MainCode,l.LPU, l.CodeVP, MIN(l.DateBeg) AS DateBeg, l.rf_idV002, l.ProfileName  
	, sum(c.IsMEE) AS CountMEE, sum(c.IsEKMP) AS CountEKMP
	,SUM(c.IsReasonMEE) AS IsReasonMEE, SUM(c.IsReasonEKMP) AS IsReasonEKMP
from  #tmpPeople c inner JOIN #tmpLPU l ON
		c.MainCode=l.MainCode
		AND c.rf_idV002=l.rf_idV002
GROUP BY l.OGRN,l.MainCode,l.LPU, l.CodeVP, l.rf_idV002, l.ProfileName 
)
SELECT OGRN,MainCode,LPU, CodeVP, DateBeg ,rf_idV002,ProfileName ,CountMEE,IsReasonMEE ,CountEKMP ,IsReasonEKMP
FROM cteExp WHERE CountMEE>0 or CountEKMP>0
 
GO
DROP TABLE #tmpLPU
DROP TABLE #tmpPeople