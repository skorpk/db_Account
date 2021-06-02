USE AccountOMS
go
DECLARE @dtStart DATETIME ='20180611',		
		@dtEnd DATETIME='20180710',
		@dtEndRak DATETIME='20180710',
		@reportYear smallint=2018,
		@reportMonth tinyint=6,
		@dtStartMM DATE,
		@dtEndMM DATE

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01'
SET @dtEndMM=dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01');

SELECT @dtStartMM, @dtEndMM

CREATE TABLE #tDS(DS VARCHAR(8)) 

INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'G%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'

CREATE TABLE #tDSChild(DS VARCHAR(8)) 

INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'A%'
INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'

SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type
	,c.DateBegin, c.DateEnd, CASE WHEN c.rf_idV014=1 AND c.rf_idV006<3 THEN 1 WHEN c.rf_idV014=2 AND c.rf_idV006<3 THEN 2 WHEN c.rf_idV014=3 AND c.rf_idV006<3 THEN 0 END AS Gosp_type
	, ReportMonth, ReportYear, f.CodeM
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase							
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient					              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006<>3  AND a.ReportMonth=@reportMonth 

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014,rp.BirthDay, 'Ï',c.DateBegin, c.DateEnd
		, NULL, ReportMonth, ReportYear, f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient	
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient					             
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009=313	 AND a.ReportMonth=@reportMonth 

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'Î',c.DateBegin, c.DateEnd
		, null, ReportMonth, ReportYear,f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient	
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON                
		c.id=m.rf_idCase   
				INNER JOIN dbo.vw_sprMU mu ON
		m.MES=mu.MU           
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 --AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009<>313  AND m.MES LIKE '2.78.%' AND a.ReportMonth=@reportMonth AND c.rf_idV009<>313


INSERT #tmpPeople 
SELECT distinct c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'Ï',c.DateBegin, c.DateEnd
		, null, ReportMonth, ReportYear,f.CodeM
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase									
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_Meduslugi m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.ReportMonth=@reportMonth
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009<>313 AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 

INSERT #tmpPeople
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type ,
		c.DateBegin,c.DateEnd,NULL, ReportMonth,ReportYear,f.CodeM
--INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase							
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 					              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDSChild dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND ReportMonth=@reportMonth AND c.Age>0 AND c.Age<18 --AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM 

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--DROP TABLE t_OrderAdult_104_2018
--BEGIN TRANSACTION
INSERT dbo.t_OrderAdult_104_2018( rf_idCase ,AmountPayment ,AmountDeduction ,Age ,DS1 ,	ENP ,rf_idV009 ,rf_idV006 ,rf_idV014 ,BirthDay ,AP_Type ,DateBegin ,DateEnd ,Gosp_type ,
									ReportMonth ,ReportYear ,PVT ,CodeM)
SELECT rf_idCase ,AmountPayment ,AmountDeduction ,Age ,DS1 ,	ENP ,rf_idV009 ,rf_idV006 ,rf_idV014 ,BirthDay ,AP_Type ,DateBegin ,DateEnd ,Gosp_type 
		,ReportMonth ,ReportYear ,0 asPVT ,CodeM
FROM #tmpPeople
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
--ROLLBACK
--CREATE NONCLUSTERED INDEX IX_Index_PVT
--ON [dbo].[t_OrderAdult_104_2018] ([DS1],[ENP],[rf_idV006],[DateBegin])
--INCLUDE ([rf_idCase],[DateEnd])
------------------------------------------------------------------------------------------
GO
DROP TABLE #tDS
DROP TABLE #tDSChild
DROP TABLE #tmpPeople

