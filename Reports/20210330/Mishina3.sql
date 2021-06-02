USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200430',
		@dateEndReg DATETIME='20210331',
		@dateStartRegRAK DATETIME='20200430',
		@dateEndRegRAK DATETIME=GETDATE()


SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,f.CodeM,c.rf_idRecordCasePatient,ps.ENP,cc.DateBegin,cc.DateEnd
INTO #tCases1
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
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg   AND a.ReportYearMonth BETWEEN 202004 AND 202103 AND f.CodeM='173801' AND c.rf_idV006=1


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases1 p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DELETE FROM #tCases1 WHERE AmountPayment=0.0


SELECT DISTINCT c.rf_idCase,p.Fam+ ' '+ISNULL(p.im,'')+' '+ISNULL(p.ot,'') AS FIO, p.BirthDay,c.ENP,r.rf_idF008,r.NumberPolis,f.DateRegistration
	,a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment
	,RTRIM(d.DS1)+' - '+mkb.Diagnosis AS Diag,v2.name AS Profil,v14.name AS FOR_POM ,cc.DateBegin,cc.DateEnd,DATEADD(DAY,30,cc.DateEnd) AS DateEnd2
	,v4.name AS PRVS,RTRIM(m.MES)+' - '+csg.name AS CSG
	,v9.name AS RSLT,CASE WHEN cc.TypeTranslation=1 THEN 'Поступил самостоятельно' 
											WHEN cc.TypeTranslation=2 THEN 'Доставлен СМП' 
														WHEN cc.TypeTranslation=3 THEN 'Перевод из другой МО' 
																	WHEN cc.TypeTranslation=4 THEN 'Перевод внутри МО' ELSE NULL END AS P_PER	
INTO #tCases
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
					INNER join #tCases1 c ON
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
-----------------------------------------------------------------------------------------
SELECT code,name AS CSG INTO #tCSG FROM dbo.vw_sprCSG WHERE dateBeg>='20200101'
UNION ALL
SELECT DISTINCT MU,MUName FROM vw_sprMUCompletedCase

SELECT DISTINCT c1.FIO AS FIOCross,c1.BirthDay AS DRCross,c1.ENP , c1.NumberPolis AS NumberPolicyCross,
       CAST(c1.DateRegistration AS DATE) AS DateRegistrationCross,c1.Account AS AcountCross,c1.DateAccount AS DateAccountCross,c1.idRecordCase AS idRecordCaseCross,
       c1.AmountPayment AS AmountPaymentCross,c1.Diag AS DiagCross,c1.Profil AS ProfilCross,c1.FOR_POM AS FOR_POMCross,c1.DateBegin AS DateBeginCross,
       c1.DateEnd AS DateEndCross,c1.PRVS AS PRVSCross,c1.CSG AS CSGCross,c1.RSLT AS RSLTCross,c1.P_PER AS P_PERCross
	   --------------------------------------
	  ,f.CodeM+' - '+l.NAMES AS LPU,CAST(f.DateRegistration AS DATE),a.Account,a.DateRegister AS DateAccount,cc.idRecordCase,CAST(c.AmountPayment AS MONEY) AS AmountPayment
	   ,v6.name AS USL_OK
	   ,RTRIM(d.DS1)+' - '+mkb.Diagnosis AS Diag,v2.name AS Profil,v14.name AS FOR_POM ,cc.DateBegin,cc.DateEnd
	   ,v4.name AS PRVS,RTRIM(m.MES)+' - '+sM.CSG AS CSG
	   ,v9.name AS RSLT,CASE WHEN c.TypeTranslation=1 THEN 'Поступил самостоятельно' 
											WHEN c.TypeTranslation=2 THEN 'Доставлен СМП' 
														WHEN c.TypeTranslation=3 THEN 'Перевод из другой МО' 
																	WHEN c.TypeTranslation=4 THEN 'Перевод внутри МО' ELSE NULL END AS P_PER
		,mm.MU+' - '+mu.MUName	AS MU
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN vw_sprT001 l ON
            f.CodeM=l.CodeM
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_PatientSMO ps ON
            r.id=ps.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					join dbo.vw_Diagnosis d ON
            c.id=d.rf_idCase
					JOIN dbo.vw_sprMKB10 mkb ON
			d.DS1=mkb.DiagnosisCode							
					JOIN dbo.vw_sprV002 v2 ON
			v2.id = c.rf_idV002          
					JOIN oms_nsi.dbo.sprV014 V14 ON
            c.rf_idV014=V14.IDFRMMP
					INNER JOIN dbo.t_RegisterPatient p ON
			r.id=p.rf_idRecordCase
					JOIN dbo.vw_sprV004 v4 ON
            c.rf_idV004=v4.id
			AND cc.DateEnd  BETWEEN v4.DateBeg AND v4.DateEnd
					JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					JOIN dbo.vw_sprV006 v6 ON
            c.rf_idV006=v6.id
					JOIN #tCSG sM ON
            m.MES=sM.code
					JOIN dbo.vw_sprV009 v9 ON
             c.rf_idV009=v9.id						    
					JOIN #tCases c1 ON
            c1.ENP = ps.ENP
					LEFT JOIN dbo.t_Meduslugi mm ON
            c.id=mm.rf_idCase
			AND mm.Price>0
					LEFT JOIN dbo.vw_sprMU  mu ON
            mm.MU=mu.MU
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg   AND a.ReportYearMonth BETWEEN 202004 AND 202103 
	AND cc.DateBegin BETWEEN c1.DateEnd AND c1.DateEnd2 AND c1.rf_idCase<>c.id AND c.rf_idV006=1

ORDER BY FIOCross
GO
DROP TABLE #tCases1
GO
DROP TABLE #tCases
GO
DROP TABLE #tCSG