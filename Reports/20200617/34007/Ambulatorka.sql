USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20190601',
		@dateEndReg DATETIME='20190716',
		@dateStartRegRAK DATETIME='20190601',
		@dateEndRegRAK DATETIME='20200716',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=6,
		@codeSMO CHAR(5)='34007'


;WITH cteAmb
AS(
SELECT a.rf_idSMO,COUNT(DISTINCT p.ENP) AS col16, 0 AS Col17, 0 AS Col18, 0 AS Col19, 0 AS Col20, 0 AS Col21,SUM(cc.AmountPayment) AS Col22,CAST(0.0 AS decimal(15,2)) AS Col23
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
UNION all
SELECT a.rf_idSMO,0 AS col16, SUM(vu.Qunatity) AS Col17, 0 AS Col18, 0 AS Col19, 0 AS Col20, 0 AS Col21,0.0 ,0.0
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
UNION all
SELECT a.rf_idSMO,0 AS col16, 0 AS Col17, COUNT(DISTINCT cc.id) AS Col18, 0 AS Col19, 0 AS Col20, 0 AS Col21,0.0 ,0.0
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
	AND vu.UnitCode IN(32,147)
GROUP BY a.rf_idSMO
UNION all
SELECT a.rf_idSMO,0 AS col16, 0 AS Col17, 0 AS Col18, COUNT(DISTINCT cc.id) AS Col19, 0 AS Col20, 0 AS Col21,0.0 ,0.0
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
	AND vu.UnitCode IN(260,261,262)
GROUP BY a.rf_idSMO
UNION all
SELECT a.rf_idSMO,0 AS col16, 0 AS Col17, 0 AS Col18, 0 AS Col19, COUNT( DISTINCT cc.id) AS Col20, 0 AS Col21,0.0 ,0.0
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
UNION all
SELECT a.rf_idSMO,0 AS col16, 0 AS Col17, 0 AS Col18, 0 AS Col19, 0 AS Col20, SUM(m.Quantity) AS Col21,0.0,0.0
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
UNION all			
SELECT a.rf_idSMO,0 AS col16, 0 AS Col17, 0 AS Col18, 0 AS Col19, 0 AS Col20, 0 AS Col21,0 AS Col22,SUM(pp.AmountDeduction) AS Col23
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
)
SELECT c.rf_idSMO,SUM(Col16),SUM(Col17),SUM(Col18),SUM(Col19),SUM(Col20),SUM(Col21),SUM(Col22),SUM(Col23)
FROM cteAmb c GROUP BY c.rf_idSMO