USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20200601',
		@dateEndReg DATETIME='20200716',
		@dateStartRegRAK DATETIME='20200601',
		@dateEndRegRAK DATETIME='20200716',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=6,
		@codeSMO CHAR(5)='34007'


CREATE TABLE #tAmb(
	rf_idSMO CHAR(5) NULL,
	col26 INT NOT NULL default 0,
	Col27 INT NOT NULL default 0,
	Col28 INT NOT NULL default 0,
	Col29 INT NOT NULL default 0,
	Col30 INT NOT NULL default 0,
	Col31 INT NOT NULL default 0,
	Col32 INT NOT NULL default 0,
	Col33 INT NOT NULL default 0,
	Col34 INT NOT NULL default 0,
	Col35 DECIMAL(38, 2) NOT NULL default 0.0,
	Col36 DECIMAL(15, 2) NOT NULL default 0.0,
	Col37 DECIMAL(15, 2) NOT NULL default 0.0,
	Col38 DECIMAL(15, 2) NOT NULL default 0.0
) 

INSERT #tAmb(rf_idSMO,col26,col35)
SELECT a.rf_idSMO,COUNT(DISTINCT p.ENP) AS col26,SUM(cc.AmountPayment) AS Col35
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
GROUP BY a.rf_idSMO
---------------------------------------Covid-19---------------------------------------
INSERT #tAmb(rf_idSMO,col27,col36)
SELECT a.rf_idSMO,COUNT(DISTINCT p.ENP),SUM(cc.AmountPayment) 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d WHERE TypeDiagnosis IN(1,3) AND rf_idCase=c.id  AND d.DiagnosisCode IN('U07.1','U07.2'))
GROUP BY a.rf_idSMO 


INSERT #tAmb(rf_idSMO,col28)
SELECT a.rf_idSMO, SUM(vu.Qunatity) 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode IN(30,31,38,145,146)
GROUP BY a.rf_idSMO
---------------------------------------Covid-19---------------------------------------
INSERT #tAmb(rf_idSMO,col29)
SELECT a.rf_idSMO, SUM(vu.Qunatity) 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode IN(30,31,38,145,146)
	AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d WHERE TypeDiagnosis IN(1,3) AND rf_idCase=c.id  AND d.DiagnosisCode IN('U07.1','U07.2'))
GROUP BY a.rf_idSMO

INSERT #tAmb(rf_idSMO,col30)
SELECT a.rf_idSMO,COUNT(DISTINCT cc.id)
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode IN(32,147,322,323)
GROUP BY a.rf_idSMO
---------------------------------------Covid-19---------------------------------------
INSERT #tAmb(rf_idSMO,col31)
SELECT a.rf_idSMO, COUNT(DISTINCT cc.id) AS Col18
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode IN(32,147,322,323) AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d WHERE TypeDiagnosis IN(1,3) AND rf_idCase=c.id  AND d.DiagnosisCode IN('U07.1','U07.2'))
GROUP BY a.rf_idSMO


INSERT #tAmb(rf_idSMO,col32)
SELECT a.rf_idSMO,COUNT(DISTINCT cc.id) 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode IN(260,261,262,318, 319, 320, 321)
GROUP BY a.rf_idSMO

INSERT #tAmb(rf_idSMO,col33)
SELECT a.rf_idSMO,COUNT( DISTINCT cc.id) 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_UnitCode_V006 vu ON
            c.id=vu.rf_idCase
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND vu.UnitCode =205
GROUP BY a.rf_idSMO
INSERT #tAmb(rf_idSMO,col34)
SELECT a.rf_idSMO, SUM(m.Quantity) AS Col21
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Meduslugi m ON 
			m.rf_idCase = c.id					
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
	AND a.Letter='K' AND m.MUGroupCode<>60 AND m.MUUnGroupCode<>3
GROUP BY a.rf_idSMO

INSERT #tAmb(rf_idSMO,col37)
SELECT a.rf_idSMO,SUM(pp.AmountDeduction) AS Col23
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_PaymentAcceptedCase2 pp ON
            c.id=pp.rf_idCase         
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
GROUP BY a.rf_idSMO
---------------------------------------Covid-19---------------------------------------
INSERT #tAmb(rf_idSMO,col38)
SELECT a.rf_idSMO,SUM(pp.AmountDeduction) AS Col23
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO p ON
            r.id=p.rf_idRecordCasePatient			
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_PaymentAcceptedCase2 pp ON
            c.id=pp.rf_idCase         
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006 =3 AND a.ReportMonth=@reportMonth AND a.rf_idSMO=@codeSMO
AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis d WHERE TypeDiagnosis IN(1,3) AND rf_idCase=c.id  AND d.DiagnosisCode IN('U07.1','U07.2'))
GROUP BY a.rf_idSMO


SELECT rf_idSMO, sum(col26),sum(Col27),sum(Col28),sum(Col29),sum(Col30),sum(Col31),sum(Col32),sum(Col33),sum(Col34)
	,cast(sum(Col35) as money)
	,cast(sum(Col36) as money)
	,cast(sum(Col37) as money)
	,cast(sum(Col38) as money)
FROM #tAmb GROUP BY rf_idSMO
GO
DROP TABLE #tAmb