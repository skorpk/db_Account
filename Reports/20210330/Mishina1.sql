USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200430',
		@dateEndReg DATETIME='20210331',
		@dateStartRegRAK DATETIME='20200430',
		@dateEndRegRAK DATETIME=GETDATE()

;WITH cteD
AS
(
SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,c.rf_idRecordCasePatient,p.DS,cc.DateEnd,c.rf_idV010,p.ENP
,CASE WHEN c.rf_idV009 IN(105,106) AND p.DS =cc.DateEnd THEN 1 ELSE 0 END AS IsDelCase 
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts			
					JOIN dbo.t_PatientSMO ps ON
			ps.rf_idRecordCasePatient = r.id									
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient			
				    JOIN PolicyRegister.dbo.PEOPLE p ON
            ps.ENP=p.ENP
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg   AND a.ReportYearMonth BETWEEN 202004 AND 202103 AND f.CodeM='173801' AND c.rf_idV006=1
AND a.rf_idSMO<>'34' AND p.ds IS NOT NULL AND p.DS BETWEEN cc.DateBegin AND cc.DateEnd 
)
SELECT d.rf_idCase,d.AmountPayment,d.CodeM,d.rf_idRecordCasePatient,d.DS,d.DateEnd,d.rf_idV010,d.ENP
INTO #tCases
FROM cteD d WHERE d.IsDelCase=0

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases WHERE AmountPayment=0.0

SELECT p.Fam+ ' '+ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,c.ENP,r.rf_idF008,r.NumberPolis,f.DateRegistration
	,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment
	,RTRIM(d.DS1)+' - '+mkb.Diagnosis AS Diag,v2.name AS Profil,v14.name AS FOR_POM ,cc.DateBegin,cc.DateEnd
	,v4.name AS PRVS,m.MES+' - '+csg.name
	,v9.name AS RSLT,CASE WHEN cc.TypeTranslation=1 THEN 'Поступил самостоятельно' 
											WHEN cc.TypeTranslation=2 THEN 'Доставлен СМП' 
														WHEN cc.TypeTranslation=3 THEN 'Перевод из другой МО' 
																	WHEN cc.TypeTranslation=4 THEN 'Перевод внутри МО' ELSE NULL END AS P_PER
	,c.DS
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case cc ON
			r.id=cc.rf_idRecordCasePatient
					join dbo.vw_Diagnosis d ON
            cc.id=d.rf_idCase
					JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode		
					INNER join #tCases c ON
			cc.id=c.rf_idCase
					JOIN dbo.vw_sprV002 v2 ON
			v2.id = cc.rf_idV002          
					JOIN oms_nsi.dbo.sprV014 V14 ON
            cc.rf_idV014=V14.IDFRMMP
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					JOIN dbo.vw_sprV004 v4 ON
            cc.rf_idV004=v4.id
			AND cc.DateEnd  BETWEEN v4.DateBeg AND v4.DateEnd
					JOIN dbo.t_MES m ON
            cc.id=m.rf_idCase
					JOIN dbo.vw_sprCSG csg ON
             m.MES=csg.code
					JOIN dbo.vw_sprV009 v9 ON
             cc.rf_idV009=v9.id
ORDER BY FIO
GO
DROP TABLE #tCases					