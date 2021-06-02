USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200801',
		@dateEndReg DATETIME=GETDATE(),
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=9


SELECT DiagnosisCode,MainDS  INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(DiagnosisCode,MainDS) VALUES('U07.1','U07'),('U07.2','U07')


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,c.rf_idRecordCasePatient,dd.DS1,c.rf_idV006 AS USL_OK,d.DiagnosisCode, 1 AS TypeDS,a.ReportMonth,f.CodeM
		,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS FIO, rp.BirthDay, ps.ENP, c.DateEnd,c.DateBegin,a.Account,a.DateRegister, c.idRecordCase,c.rf_idV009,c.NumberHistoryCase,c.KD
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
             ps.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DS1=d.DiagnosisCode
					INNER JOIN dbo.vw_RegisterPatient rp ON
            r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4  AND a.ReportMonth=@reportMonth 

CREATE UNIQUE NONCLUSTERED INDEX QU_index1 ON #tCases(rf_idCase) WITH IGNORE_DUP_KEY

insert #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,c.rf_idRecordCasePatient,dd.DS1,c.rf_idV006 AS USL_OK,d.DiagnosisCode, 2 AS TypeDS,a.ReportMonth,f.CodeM
		,rp.Fam+' '+rp.Im+' '+ISNULL(rp.Ot,'') AS FIO, rp.BirthDay, ps.ENP,c.DateEnd,c.DateBegin,a.Account,a.DateRegister, c.idRecordCase,c.rf_idV009,c.NumberHistoryCase,kd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
             ps.rf_idRecordCasePatient = r.id
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis dd ON
			c.id=dd.rf_idCase	
					INNER JOIN #tDiag d ON
            dd.DS2=d.DiagnosisCode
			AND d.MainDS='U07'
					INNER JOIN dbo.t_RegisterPatient rp ON
            r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4  AND a.ReportMonth=@reportMonth 



UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

;WITH cteDOuble
AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY DateEnd desc) AS idRow,*
	FROM #tCases WHERE AmountPayment>0 
)
SELECT *
INTO #tCases1 
FROM cteDOuble c WHERE c.idRow=1 

SELECT c.codeM+' - '+l.NAMES AS LPU
		,count(DISTINCT CASE WHEN c.USL_OK=1 AND c.ReportMonth=@reportMonth THEN c.ENP ELSE NULL END) AS Stac_04
		----------------------DnevnoiStacionar--------------------------------------
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=@reportMonth THEN c.Enp ELSE NULL END) AS DnevnoiStac_04
		----------------------Ambulatorka--------------------------------------------
		,count(DISTINCT CASE WHEN c.USL_OK=2 AND c.ReportMonth=@reportMonth THEN c.Enp ELSE NULL END) AS DnevnoiStac_04
FROM #tCases1 c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
GROUP BY c.codeM+' - '+l.NAMES
ORDER BY LPU
--------------------люди-------------------------
SELECT ROW_NUMBER() OVER(PARTITION BY enp ORDER BY c.DateEnd desc) AS id, c.codeM+' - '+l.NAMES AS LPU ,c.Account,c.DateRegister,c.idRecordCase,c.FIO,c.BirthDay,c.ENP,c.NumberHistoryCase
		,c.DS1
		,CASE WHEN c.TypeDS=2 THEN c.DiagnosisCode WHEN c.TypeDS=1 AND d.DS2 LIKE 'U07%' THEN d.DS2 ELSE NULL END AS DS2
		,c.DateBegin,c.DateEnd,v9.Name,kd,c.USL_OK
FROM #tCases1 c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
				INNER JOIN vw_sprV009 v9 ON
        c.rf_idV009=v9.id
				INNER JOIN dbo.vw_Diagnosis d ON
         c.rf_idCase=d.rf_idCase
WHERE c.USL_OK IN(1,3)
ORDER BY LPU
GO
DROP TABLE #tDiag
GO
DROP TABLE #tCases
GO
DROP TABLE #tCases1