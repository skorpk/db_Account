USE AccountOMS
GO
declare @dateStartReg DATETIME='20180401',
		@dateEndReg DATETIME='20180710 23:59:59',
		@reportYear SMALLINT=2018,
		@reportMonthStart TINYINT=4,
		@reportMonthEnd TINYINT=6,
		@codeSMO VARCHAR(5)='34' 

CREATE TABLE #tmpCases(ENP VARCHAR(16),rf_idCase BIGINT, pid int)

INSERT #tmpCases( ENP, rf_idCase,pid)
SELECT distinct ps.ENP,c.id, p.pid
FROM PeopleAttach.[dbo].[CancerRegistr] p INNER JOIN dbo.t_PatientSMO ps ON
		p.ENP=ps.ENP
								INNER JOIN dbo.t_RecordCasePatient r ON
		ps.rf_idRecordCasePatient = r.id
								INNER JOIN dbo.t_Case c ON
		r.id = c.rf_idRecordCasePatient                              
WHERE p.PID IS NOT NULL and c.DateEnd>='20180101' AND c.DateEnd<'20180401' p.[Month]=6 AND p.[YEAR]=@reportYear 

---------------------------------------------------------------------------------------------------------------------------------------
SELECT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,f.DateRegistration,a.DateRegister,c.id AS rf_idCase, c1.PID, c.rf_idV006, c.rf_idV002,c.rf_idDoctor,c.DateBegin,c.DateEnd,
		d.DS1, c.AmountPayment,c.AmountPayment AS AmountPaymentAcc,c.Age
		,r.NumberPolis,r.AttachLPU,c.NumberHistoryCase,c.rf_idV009, c.rf_idV012, c.rf_idV004
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@reportYear 
		AND a.ReportMonth>=@reportMonthStart AND a.ReportMonth<=@reportMonthEnd AND a.rf_idSMO=@codeSMO
		AND d.DS1 LIKE 'C%' AND c.Comments='8'

INSERT #tmpPeople (CodeM,rf_idSMO,Account,idRecordCase,DateRegistration,DateRegister,rf_idCase,PID,rf_idV006,rf_idV002,rf_idDoctor,DateBegin,DateEnd,DS1,AmountPayment,AmountPaymentAcc,
					Age,NumberPolis,AttachLPU,NumberHistoryCase,rf_idV009,rf_idV012,rf_idV004) 
SELECT f.CodeM,a.rf_idSMO, a.Account, c.idRecordCase,f.DateRegistration,a.DateRegister,c.id AS rf_idCase, c1.PID, c.rf_idV006, c.rf_idV002,c.rf_idDoctor,c.DateBegin,c.DateEnd,
		d.DS2, c.AmountPayment,c.AmountPayment AS AmountPaymentAcc,c.Age
		,r.NumberPolis,r.AttachLPU,c.NumberHistoryCase,c.rf_idV009, c.rf_idV012, c.rf_idV004
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg AND a.ReportYear=@reportYear AND a.ReportMonth>=@reportMonthStart AND a.ReportMonth<=@reportMonthEnd AND a.rf_idSMO=@codeSMO
		AND d.DS2 LIKE 'C%'	AND c.Comments='8'


UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.TypeCheckup=1 and c.DateRegistration>=@dateStartReg AND c.DateRegistration<GETDATE()
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase


;WITH cte AS
(
SELECT p.PID,p.CodeM, l.NAMES AS LPU,
		s.sNameS AS SMO,
		p.DateRegistration, p.Account,p.DateRegister,
		p.idRecordCase ,p.DS1, 
		p.AmountPayment,
		v2.name AS Profil,
		p.NumberHistoryCase,
		p.DateBegin,p.DateEnd,
		v9.name AS RSLT,
		v12.name AS ISHOD,
		v4.name AS PRVS,
		pp.FAM,
		pp.IM,
		pp.OT,
		pp.DR,
		p.NumberPolis,
		p.AttachLPU,l1.NAMES AS AttachLPUName,p.Age, CASE WHEN pp.W=1 THEN 'Ì' ELSE 'Æ' END AS Sex
		,v6.name AS USL_OK
FROM #tmpPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
			p.PID = pp.ID
					INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprSMO s ON
				p.rf_idSMO=s.smocod
					INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
				p.rf_idV009=v9.id                  
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
				p.rf_idV002=v2.id   
					INNER JOIN dbo.vw_sprT001 l1 ON
				p.AttachLPU=l1.CodeM 
					INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
				p.rf_idV012=v12.id    
					INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
				p.rf_idV004=v4.id       
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
				p.rf_idV006=v6.id 
WHERE p.AmountPayment=0 and p.AmountPaymentAcc=0 
UNION ALL
SELECT p.PID,p.CodeM, l.NAMES AS LPU,
		s.sNameS AS SMO,
		p.DateRegistration, p.Account,p.DateRegister,
		p.idRecordCase ,p.DS1, 
		p.AmountPayment,
		v2.name AS Profil,
		p.NumberHistoryCase,
		p.DateBegin,p.DateEnd,
		v9.name AS RSLT,
		v12.name AS ISHOD,
		v4.name AS PRVS,
		pp.FAM,pp.IM,pp.OT,pp.DR,p.NumberPolis,
		p.AttachLPU,l1.NAMES AS AttachLPUName,p.Age,CASE WHEN pp.W=1 THEN 'Ì' ELSE 'Æ' END AS Sex
		,v6.name
FROM #tmpPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
				p.PID = pp.ID
					INNER JOIN dbo.vw_sprT001 l ON
				p.CodeM=l.CodeM
					INNER JOIN dbo.vw_sprSMO s ON
				p.rf_idSMO=s.smocod
					INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
				p.rf_idV009=v9.id                  
					INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
				p.rf_idV002=v2.id   
					INNER JOIN dbo.vw_sprT001 l1 ON
				p.AttachLPU=l1.CodeM 
					INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
				p.rf_idV012=v12.id    
					INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
				p.rf_idV004=v4.id     
					INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
				p.rf_idV006=v6.id           
WHERE p.AmountPayment>0 and p.AmountPaymentAcc>0 
) 
SELECT  --CodeM,
		SMO,LPU,
		CAST(DateRegistration AS DATE) AS dateregistration,
		Account,DateRegister,
		idRecordCase,DS1,m.Diagnosis,CAST(AmountPayment AS MONEY) AS AmountPayment,
		Profil,USL_OK,NumberHistoryCase,DateBegin,DateEnd,RSLT,ISHOD,PRVS,
		FAM+' '+ISNULL(IM,'')+' '+ISNULL(OT,''), Sex,CAST(DR AS DATE) AS DR, Age,NumberPolis,
		--AttachLPU,
		AttachLPUName
FROM cte INNER JOIN dbo.vw_sprMKB10 m ON
		cte.DS1=m.DiagnosisCode
ORDER BY CodeM
go
DROP TABLE #tmpCases
DROP TABLE #tmpPeople