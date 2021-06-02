USE AccountOMS
GO
DECLARE @dateStart DATETIME='20160101',
		@dateEnd DATETIME='20160701',
		@dateEndPay DATETIME='20160922 23:59:59' ,
		@reportYear SMALLINT=2017

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  ReportMonth TINYINT,
					  ReportYear SMALLINT,
					  C_POKL TINYINT,
					  Agge TINYINT,
					  Sex TINYINT,
					  ENP VARCHAR(20),
					  DR DATE,
					  NumberCase INT,
					  DateBegin DATE,
					  DateEnd DATE,
					  rf_idV006 TINYINT,
					  rf_idV008 SMALLINT,
					  AmountPayment decimal(11,2),
					  AmountDeduction DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  PID INT,
					  DS1 varchar(6) ,
					  GUIDCase UNIQUEIDENTIFIER
					  )
INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,rf_idV006,rf_idV008,AmountPayment,ENP,PID, DS1,GUIDCase)
SELECT c.id,a.ReportMonth, a.ReportYear, 6, c.Age, rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,c.rf_idV006,c.rf_idV008,c.AmountPayment,p.ENP,p.PID, d.DiagnosisCode
		,c.GUID_Case
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I1[0-5]%' 

INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,rf_idV006,rf_idV008,AmountPayment,ENP,PID, DS1,GUIDCase)
SELECT c.id,a.ReportMonth, a.ReportYear, 7, c.Age, rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,c.rf_idV006,c.rf_idV008,c.AmountPayment,p.ENP,p.PID, d.DiagnosisCode
		,c.GUID_Case
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I6[0-4]%' 

INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,rf_idV006,rf_idV008,AmountPayment,ENP,PID, DS1)
SELECT c.id,a.ReportMonth, a.ReportYear, 8, c.Age, rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,c.rf_idV006,c.rf_idV008,c.AmountPayment,p.ENP,p.PID, d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode ='I20.0'

INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,rf_idV006,rf_idV008,AmountPayment,ENP,PID, DS1)
SELECT c.id,a.ReportMonth, a.ReportYear, 9, c.Age, rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,c.rf_idV006,c.rf_idV008,c.AmountPayment,p.ENP,p.PID, d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I21.%'

INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,rf_idV006,rf_idV008,AmountPayment,ENP,PID, DS1)
SELECT c.id,a.ReportMonth, a.ReportYear, 10, c.Age, rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,c.rf_idV006,c.rf_idV008,c.AmountPayment,p.ENP,p.PID, d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<4 AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I22.%' 

---------------------------------------------------------------------------------------------------------------------------
UPDATE c SET c.ENP=p.ENP, c.DR=p.DR
FROM #tPeople c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			c.PID=p.ID

---------------------------------------------------------------------------------------------------------------------------

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DROP TABLE dbo.t_Report2FFOMS

SELECT *
INTO t_Report2FFOMS
FROM #tPeople p	        
WHERE p.AmountDeduction>0 AND EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS f WHERE f.ReportYear=@reportYear AND r.rf_idCase=f.rf_idCase)	

DELETE FROM dbo.t_Report2FFOMS  WHERE ENP IS NULL

--DELETE FROM dbo.t_Report2FFOMS 
--FROM dbo.t_Report2FFOMS r
--WHERE NOT EXISTS(SELECT * FROM dbo.t_SendingDataIntoFFOMS f WHERE f.ReportYear=2016 AND r.rf_idCase=f.rf_idCase)
GO
DROP TABLE #tPeople