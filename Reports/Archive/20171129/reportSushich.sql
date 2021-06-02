USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20171001 23:59:59',
		@dtEndRAK DATETIME='20171121 23:59:59'
		--@reportYear SMALLINT=2017,
		--@reportMonth tinyint=10	  

SELECT distinct c.id, c.GUID_Case,a.rf_idSMO, l.NAMES,a.Account,a.DateRegister,f.DateRegistration
		,c.idRecordCase,d.DS1,mkb10.Diagnosis,CAST(c.AmountPayment AS MONEY) AS AmountPayment,v2.name AS PROFIL
		,0 AS Tariff,c.NumberHistoryCase,c.DateBegin,c.DateEnd,v9.name AS RSLT,v12.name AS ISHOD,v4.name AS PRVS
		,p.Fam+' '+p.Im+' '+p.Ot AS Fio,p.Sex,p.BirthDay,c.Age,r.NumberPolis,v6.name AS USL_OK,
		c.AmountPayment AS AmountDeduction, r.AttachLPU, m.MUSurgery
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_RegisterPatient p ON
		r.id=p.rf_idRecordCase
		AND f.id=p.rf_idFiles				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_sprMKB10 mkb10 ON
		d.DS1=mkb10.DiagnosisCode			
				INNER JOIN RegisterCases.dbo.vw_sprV009 v9 ON
		c.rf_idV009=v9.id
				INNER JOIN RegisterCases.dbo.vw_sprV012 v12 ON
		c.rf_idV012=v12.id		
				INNER JOIN RegisterCases.dbo.vw_sprV004 v4 ON
		c.rf_idV004=v4.id	
		AND c.DateEnd>=v4.DateBeg
		AND c.DateEnd<=v4.DateEnd	
				INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
		c.rf_idV002=v2.id
				INNER JOIN dbo.vw_sprT001 l ON
		f.CodeM=l.CodeM		
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id				
				INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase
				INNER JOIN oms_nsi.dbo.V001 v1 ON
		m.MUSurgery=v1.IDRB              
WHERE f.CodeM='621001' AND f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.rf_idSMO<>'34'
		AND c.rf_idV006=1 AND c.rf_idV002 IN(112,136) AND v1.IDRB LIKE 'A%'
ORDER BY FIO,DateRegister

UPDATE p SET p.AmountDeduction=p.AmountDeduction-Deduction
FROM #tmpCases p INNER JOIN (SELECT f.rf_idCase,SUM(f.AmountDeduction) AS Deduction
								FROM dbo.t_PaymentAcceptedCase2 f																					
								WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<=@dtEndRak AND f.TypeCheckup=1
								GROUP BY f.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT s.smocod,s.sNameS,c.Names,CAST(DateRegistration AS DATE) AS DateReg,Account,DateRegister,idRecordCase,DS1,Diagnosis,AmountPayment,PROFIL,USL_OK, NumberHistoryCase, 
		c.DateBegin,c.DateEnd,c.RSLT,c.ISHOD,PRVS,Fio,Sex,BirthDay,Age,NumberPolis, l.NAMES AS LPUAttach, c.MUSurgery
FROM #tmpCases c INNER JOIN dbo.vw_sprSMO s ON
			c.rf_idSMO=s.smocod
				left JOIN dbo.vw_sprT001 l ON
			c.AttachLPU=l.CodeM              
WHERE AmountDeduction>0

go
DROP TABLE #tmpCases
--DROP TABLE #tmpPeople