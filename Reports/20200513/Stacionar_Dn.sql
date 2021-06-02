USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=4



SELECT DiagnosisCode,MainDS  INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

--INSERT #tDiag(DiagnosisCode,MainDS) VALUES('U07.1','U07'),('U07.2','U07')


SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idRecordCasePatient,dd.DS1,c.rf_idV006 AS USL_OK,d.MainDS,a.ReportMonth,f.CodeM
		,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS FIO, rp.BirthDay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DS1=d.DiagnosisCode
					INNER JOIN dbo.t_RegisterPatient rp ON
            r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<3  AND a.ReportMonth=@reportMonth 
	AND f.CodeM='121125'
/*AND c.rf_idV009 IN (105,106,205,206,313,405,406,411) */ 



SELECT c.codeM+' - '+l.NAMES AS LPU,c.MainDS+' - '+m.Diagnosis AS Diagnosis
		,count(DISTINCT CASE WHEN c.USL_OK=1 AND c.ReportMonth=1 THEN c.rf_idRecordCasePatient ELSE NULL END) AS Stac_01
		,count(DISTINCT CASE WHEN c.USL_OK=1 AND c.ReportMonth=2 THEN c.rf_idRecordCasePatient ELSE NULL END) AS Stac_02
		,count(DISTINCT CASE WHEN c.USL_OK=1 AND c.ReportMonth=3 THEN c.rf_idRecordCasePatient ELSE NULL END) AS Stac_03
		,count(DISTINCT CASE WHEN c.USL_OK=1 AND c.ReportMonth=4 THEN c.rf_idRecordCasePatient ELSE NULL END) AS Stac_04
		----------------------DnevnoiStacionar--------------------------------------
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=1 THEN c.rf_idRecordCasePatient ELSE NULL END) AS DnevnoiStac_01
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=2 THEN c.rf_idRecordCasePatient ELSE NULL END) AS DnevnoiStac_02
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=3 THEN c.rf_idRecordCasePatient ELSE NULL END) AS DnevnoiStac_03
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=4 THEN c.rf_idRecordCasePatient ELSE NULL END) AS DnevnoiStac_04
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
				inner JOIN dbo.vw_sprMKB10 m ON
		c.MainDS=m.DiagnosisCode
GROUP BY c.codeM+' - '+l.NAMES, c.MainDS+' - '+m.Diagnosis
ORDER BY lpu,Diagnosis
--------люди
SELECT c.FIO,c.BirthDay,c.MainDS+' - '+m.Diagnosis AS Diagnosis
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
				inner JOIN dbo.vw_sprMKB10 m ON
		c.MainDS=m.DiagnosisCode


GO
DROP TABLE #tDiag
GO
DROP TABLE #tCases