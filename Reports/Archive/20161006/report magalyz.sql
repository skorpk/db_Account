USE AccountOMS
GO
CREATE TABLE #tmpCases(PID INT,rf_idCase BIGINT, id INT,isTypeCanser TINYINT)

INSERT #tmpCases( PID, rf_idCase,id, isTypeCanser )
SELECT c.PID,c.rf_idCase, t.id ,Step
FROM tmpCanserPeople t INNER JOIN PolicyRegister.dbo.PEOPLE p ON
		t.Fam=p.FAM
		AND t.IM=p.IM
		AND t.Ot=p.OT
		AND t.DR=p.DR
			INNER JOIN dbo.t_Case_PID_ENP c ON
		p.id=c.PID  
WHERE c.ReportYear=2016		        

SELECT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,a.ReportMonth,a.ReportYear,c.id AS rf_idCase, c1.PID, c.rf_idV006, c.rf_idV002,c.rf_idDoctor,c.DateBegin,c.DateEnd,
		d.DS1, CASE WHEN d.DS2 LIKE 'R%' THEN d.DS2 ELSE NULL END AS DS2,c.AmountPayment,c.AmountPayment AS AmountPaymentAcc
		,r.NumberPolis,r.AttachLPU,c1.isTypeCanser
		,pc.dateUchet ,pc.DateDS ,pc.DateEnd AS DateEndUchet
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN 	#tmpCases c1 ON
		c.id=c1.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase								
				INNER JOIN RegisterCases.dbo.vw_sprV010 v10 ON
		c.rf_idV010=v10.id	
				INNER JOIN dbo.tmpCanserPeople pc ON
		c1.id=pc.id																					  		
WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20160906' AND a.ReportYear=2016 AND c.rf_idV006 IN(1,3,4) AND a.rf_idSMO<>'34' 
		AND d.DS1 LIKE 'C%'

ALTER TABLE #tmpPeople ADD IsMEE TINYINT
ALTER TABLE #tmpPeople ADD IsDrags TINYINT

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20161005 23:59:59'
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT * FROM #tmpPeople WHERE CodeM='806501'

UPDATE p SET p.IsMEE=2
FROM #tmpPeople p INNER JOIN (SELECT rf_idCase
								FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount 																							
								WHERE f.DateRegistration>='20160101' AND f.DateRegistration<'20161005 23:59:59'	AND d.TypeCheckup=2
							) r ON
			p.rf_idCase=r.rf_idCase
UPDATE p SET p.IsDrags=1
FROM dbo.t_PeopleDrags d INNER JOIN #tmpPeople p ON
			d.PID=p.PID

;WITH cte AS
(
SELECT p.CodeM,l.NAMES AS LPU,s.sNameS AS SMO,p.Account,p.idRecordCase,p.ReportMonth,p.ReportYear, v6.name AS Usl_OK, v2.name AS Profil,
		p.rf_idDoctor AS SS, p.DateBegin,p.DateEnd,p.DS1,p.DS2,p.IsMEE, p.AmountPayment,p.AmountPaymentAcc,pp.FAM,pp.IM,pp.OT,pp.DR,p.NumberPolis,
		p.AttachLPU,l1.NAMES AS AttachLPUName, p.isTypeCanser,p.IsDrags,p.dateUchet ,p.DateDS ,p.DateEndUchet
FROM #tmpPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
			p.PID = pp.ID
					INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprSMO s ON
				p.rf_idSMO=s.smocod
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
				p.rf_idV006=v6.id                  
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
				p.rf_idV002=v2.id   
					INNER JOIN dbo.vw_sprT001 l1 ON
				p.AttachLPU=l1.CodeM 
WHERE p.CodeM<>'806501' AND p.rf_idV002=4 and p.AmountPaymentAcc=0 
UNION ALL
SELECT p.CodeM,l.NAMES,s.sNameS AS SMO,p.Account,p.idRecordCase,p.ReportMonth,p.ReportYear, v6.name AS Usl_OK, v2.name AS Profil,
		p.rf_idDoctor AS SS, p.DateBegin,p.DateEnd,p.DS1,p.DS2,p.IsMEE, p.AmountPayment,p.AmountPaymentAcc,pp.FAM,pp.IM,pp.OT,pp.DR,p.NumberPolis,
		p.AttachLPU,l1.NAMES, p.isTypeCanser,p.IsDrags,p.dateUchet ,p.DateDS ,p.DateEndUchet
FROM #tmpPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
			p.PID = pp.ID
					INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprSMO s ON
				p.rf_idSMO=s.smocod
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
				p.rf_idV006=v6.id                  
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
				p.rf_idV002=v2.id   
					INNER JOIN dbo.vw_sprT001 l1 ON
				p.AttachLPU=l1.CodeM 
WHERE p.CodeM='806501' AND p.rf_idV006=4 and p.AmountPaymentAcc>0 
UNION ALL
SELECT p.CodeM,l.NAMES,s.sNameS AS SMO,p.Account,p.idRecordCase,p.ReportMonth,p.ReportYear, v6.name AS Usl_OK, v2.name AS Profil,
		p.rf_idDoctor AS SS, p.DateBegin,p.DateEnd,p.DS1,p.DS2,p.IsMEE, p.AmountPayment,p.AmountPaymentAcc,pp.FAM,pp.IM,pp.OT,pp.DR,p.NumberPolis,
		p.AttachLPU,l1.NAMES, p.isTypeCanser,p.IsDrags,p.dateUchet ,p.DateDS ,p.DateEndUchet
FROM #tmpPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
			p.PID = pp.ID
					INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprSMO s ON
				p.rf_idSMO=s.smocod
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
				p.rf_idV006=v6.id                  
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
				p.rf_idV002=v2.id   
					INNER JOIN dbo.vw_sprT001 l1 ON
				p.AttachLPU=l1.CodeM 
WHERE p.rf_idV006 IN(1,3) and p.AmountPaymentAcc>0 
) 
SELECT  CodeM,LPU,SMO,Account,idRecordCase,ReportMonth,ReportYear, Usl_OK, Profil,SS AS SS_Doc, DateBegin,DateEnd
		,DS1+' - '+m.Diagnosis,DS2,IsMEE, CAST(AmountPayment AS MONEY)
	,CAST(AmountPaymentAcc AS MONEY),FAM,IM,OT,CAST(DR AS DATE) AS DR,NumberPolis,AttachLPU,AttachLPUName, isTypeCanser,IsDrags,dateUchet ,CAST(DateDS AS DATE) AS DateDS,DateEndUchet
FROM cte INNER JOIN dbo.vw_sprMKB10 m ON
		cte.DS1=m.DiagnosisCode
ORDER BY CodeM,reportMonth

 

go
DROP TABLE #tmpCases
DROP TABLE #tmpPeople