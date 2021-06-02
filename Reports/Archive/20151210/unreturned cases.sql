USE AccountOMS
GO
DECLARE @dateEnd DATETIME=GETDATE()

;WITH accNew
as
(
SELECT f.CodeM,c.GUID_Case
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
WHERE c.rf_idV006=1 AND f.DateRegistration>'20151207' AND f.DateRegistration<@dateEnd AND a.ReportMonth=11 AND a.ReportYear=2015
)	
SELECT n.CodeM, l.NAMES, n.CodeSMO,n.NSCHET,c.idRecordCase AS NumberCase,p.Fam+' '+p.Im+' '+ISNULL(p.Ot,'') AS FIO,c.DateBegin,c.DateEnd,d.DS1, mkb.Diagnosis, m.MES, spr.MUName,c.GUID_Case
FROM RegisterCases.dbo.tmpWrongCaseNovember2 n INNER JOIN RegisterCases.dbo.t_Case c ON
					n.id=c.id
								INNER JOIN RegisterCases.dbo.vw_Diagnosis d ON
					c.id=d.rf_idCase        
								INNER JOIN RegisterCases.dbo.t_RecordCase r ON
					c.rf_idRecordCase=r.id
								INNER JOIN RegisterCases.dbo.t_RefRegisterPatientRecordCase ref ON
					r.id=ref.rf_idRecordCase
								INNER JOIN RegisterCases.dbo.t_RegisterPatient p ON
					ref.rf_idRegisterPatient=p.id                      
								INNER JOIN RegisterCases.dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN RegisterCases.dbo.vw_sprMKB10 mkb ON
					d.DS1=mkb.DiagnosisCode
								INNER JOIN (SELECT MU,MUName FROM RegisterCases.dbo.vw_sprMUCompletedCase UNION ALL SELECT code,name FROM RegisterCases.dbo.vw_sprCSG) spr ON
					m.MES=spr.MU         
								INNER JOIN dbo.vw_sprT001 l ON
					n.CodeM=l.CodeM                     
WHERE n.CodeSMO<>'34' and NOT EXISTS(SELECT * FROM accNew a WHERE a.CodeM=n.CodeM AND a.GUID_Case=n.GUID_Case)
ORDER BY n.CodeM


--;WITH accNew
--as
--(
--SELECT f.CodeM,c.GUID_Case
--FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
--			f.id=a.rf_idFiles
--			AND a.rf_idSMO<>'34'
--					INNER JOIN dbo.t_RecordCasePatient r ON
--			a.id=r.rf_idRegistersAccounts
--					INNER JOIN dbo.t_Case c ON
--			r.id=c.rf_idRecordCasePatient
--WHERE c.rf_idV006=1 AND f.DateRegistration>'20151207' AND f.DateRegistration<@dateEnd AND a.ReportMonth=11 AND a.ReportYear=2015
--)	
--SELECT n.CodeM,n.GUID_Case
--FROM RegisterCases.dbo.tmpWrongCaseNovember2 n INNER JOIN RegisterCases.dbo.t_Case c ON
--					n.id=c.id                 
--WHERE n.CodeSMO<>'34' and NOT EXISTS(SELECT * FROM accNew a WHERE a.CodeM=n.CodeM AND a.GUID_Case=n.GUID_Case)
--ORDER BY n.CodeM