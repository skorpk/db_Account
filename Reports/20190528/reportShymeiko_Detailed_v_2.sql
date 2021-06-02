USE AccountOMSReports
GO
DECLARE @codeSMo CHAR(5)='34002',
		@dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190601',
		@dateEndRAK DATETIME='20190601',
		@reportYearStart SMALLINT=2019,
		@reportYearEnd SMALLINT=2019,
		@reportMonthStart TINYINT=1,
		@reportMonthEnd TINYINT=5

DECLARE @startPeriod INT=CAST(CAST(@reportYearStart AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2) AS INT),
		@endPeriod int=CAST(CAST(@reportYearEnd AS VARCHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2) AS INT)

declare	@dateStart1 DATE,
		@dateEnd1 DATE
	

set @dateStart1=CAST(@reportYearStart AS CHAR(4))+RIGHT('0'+CAST(@reportMonthStart AS VARCHAR(2)),2)+'01'
set	@dateEnd1=DATEADD(MONTH,1,CAST((CAST(@reportYearEnd AS CHAR(4))+RIGHT('0'+CAST(@reportMonthEnd AS VARCHAR(2)),2)+'01') AS DATE))
SELECT distinct DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'	
AND MainDS NOT IN('C80','C81','C82','C83','C84','C85','C86','C88','C90', 'C91','C92','C93','C94','C95','C96')

CREATE UNIQUE CLUSTERED INDEX IX_tmp ON #tD(DiagnosisCode)

SET STATISTICS TIME ON

SELECT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,c.AmountPayment AS AmountPay,f.CodeM,a.Account,a.DateRegister,d.DiagnosisCode			
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts											
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DiagnosisCode=dd.DiagnosisCode     										     
			AND d.TypeDiagnosis=1								               
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND a.rf_idSMO=@codeSMo AND c.rf_idV006<3	
		and c.DateEnd>=@dateStart1 AND c.DateEnd<@dateEnd1 

PRINT('--------------------------------------------------------------------')
INSERT #tmpPeople 
SELECT c.id AS rf_idCase,r.id AS rf_idRecordCasePatient, c.AmountPayment,c.AmountPayment AS AmountPay,f.CodeM,a.Account,a.DateRegister,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
				INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient						
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient				
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase							
			AND d.TypeDiagnosis=1		     																   					  					      
					INNER JOIN t_DS_ONK_REAB dd ON
			c.id=dd.rf_idCase 								               
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYearMonth>=@startPeriod AND a.ReportYearMonth<=@endPeriod AND dd.DS_ONK=1 AND a.rf_idSMO=@codeSMO
	  AND c.rf_idV006<3  and c.DateEnd>=@dateStart1 AND c.DateEnd<@dateEnd1

PRINT('--------------------------------------------------------------------')

SELECT l.CodeM,l.NAMES AS LPU,ps.ENP,p.Account,p.DateRegister,cc.idRecordCase AS NumberCase,c.NumberHistoryCase,p.DiagnosisCode,cc.DateBegin,cc.DateEnd,v6.name AS USL_OK
		,d.rf_idV024,v24.DKKNAME,cc.AmountPayment
		----------------Экспертиза МЭК-----------------------
		, CASE WHEN pp.TypeCheckup=1 THEN DocNumDate ELSE NULL END AS DocNumDateMEK
		, CASE WHEN pp.TypeCheckup=1 THEN Reason ELSE NULL END AS ReasonMEK
		, CASE WHEN pp.TypeCheckup=1 THEN AmountDeduction ELSE NULL END AS DeductionMEK
		----------------Экспертиза МЭЭ-----------------------
		, CASE WHEN pp.TypeCheckup=2 THEN DocNumDate ELSE NULL END AS DocNumDateMEE
		, CASE WHEN pp.TypeCheckup=2 THEN Reason ELSE NULL END AS ReasonMEE
		, CASE WHEN pp.TypeCheckup=2 THEN AmountDeduction ELSE NULL END AS DeductionMEE
		----------------Экспертиза ЭКМП-----------------------
		, CASE WHEN pp.TypeCheckup=3 THEN DocNumDate ELSE NULL END AS DocNumDateEKMP
		, CASE WHEN pp.TypeCheckup=3 THEN Reason ELSE NULL END AS ReasonEKMP
		, CASE WHEN pp.TypeCheckup=3 THEN AmountDeduction ELSE NULL END AS DeductionEKMP
FROM #tmpPeople p inner	JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
					INNER join dbo.t_PatientSMO ps ON
		p.rf_idRecordCasePatient=ps.rf_idRecordCasePatient    
					INNER JOIN dbo.t_Case c ON
		p.rf_idCase=c.id          
					INNER JOIN dbo.t_CompletedCase cc ON
		p.rf_idRecordCasePatient=cc.rf_idRecordCasePatient 
					INNER JOIN dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id     
					INNER JOIN dbo.t_ONK_USL  u ON
		c.id=u.rf_idCase                  
					INNER JOIN dbo.t_DrugTherapy d ON
			u.rf_idCase=d.rf_idCase
			AND u.rf_idN013 = d.rf_idN013
					INNER JOIN oms_NSI.dbo.sprV024 v24 ON
			d.rf_idV024=v24.IDDKK  
					LEFT JOIN dbo.vw_PaymentAcceptedCaseReason2019 pp ON
			c.id=pp.rf_idCase 
WHERE u.rf_idN013=2  AND pp.DateRegistration>=@dateStart AND pp.DateRegistration<@dateEndRAK
PRINT('--------------------------------------------------------------------')
go

SET STATISTICS TIME OFF
GO
DROP TABLE #tD
go
DROP TABLE #tmpPeople
