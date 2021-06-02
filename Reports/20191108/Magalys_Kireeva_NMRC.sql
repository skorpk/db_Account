USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20191101',
		@dateEndPay DATETIME='20191101',
		@reportYear SMALLINT=2019

SELECT DISTINCT c.id AS rf_idCase,cc.AmountPayment, c.AmountPayment AS AmmPay,f.CodeM,i.idRow,p.ENP,a.Account,c.idRecordCase
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient                  
					inner JOIN dbo.tmp_InformationNMRC i ON
			p.ENP=i.NumberPolicy                  
			AND f.CodeM=i.CodeM
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006<3
	AND i.DateConsultation BETWEEN cc.DateBegin AND cc.DateEnd

SELECT c.CodeM+' - '+l.NAMES AS LPU,c.Account,c.idRecordCase,c.idRow,c.ENP,c.AmountPayment
,SUM(CASE WHEN p.TypeCheckup=1 THEN 1 ELSE 0 END) AS MEK
,cast(sum(CASE WHEN p.TypeCheckup=1 THEN AmountDeduction ELSE 0.0 END) as money) AS AmountMEK
,SUM(CASE WHEN p.TypeCheckup=2 THEN 1 ELSE 0 END) AS MEE
,cast(sum(CASE WHEN p.TypeCheckup=2 THEN AmountDeduction ELSE 0.0 END) as money) AS AmountMEE
,SUM(CASE WHEN p.TypeCheckup=3 THEN 1 ELSE 0 END) AS EKMP
,cast(sum(CASE WHEN p.TypeCheckup=3 THEN AmountDeduction ELSE 0.0 END) as money) AS AmountEKMP
,ISNULL(f14.Reason,'')
FROM #tCases c 	INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
				LEFT JOIN dbo.t_PaymentAcceptedCase2 p ON
		c.rf_idCase=p.rf_idCase
				LEFT JOIN dbo.t_ReasonDenialPayment r ON
		p.rf_idCase=r.rf_idCase
		AND p.idAkt = r.idAkt              
				LEFT JOIN oms_nsi.dbo.sprF014 f14 ON
		r.CodeReason=f14.ID              
GROUP BY c.CodeM+' - '+l.NAMES,c.Account,c.idRecordCase,c.idRow,c.ENP,c.AmountPayment,f14.Reason
ORDER BY  LPU,idrow
--------------отсутствуют в счетах--------------------------
SELECT i.CodeM+' - '+l.NAMES,i.NumberPolicy,i.idRow
FROM dbo.tmp_InformationNMRC i INNER JOIN dbo.vw_sprT001 l ON
		i.CodeM=l.CodeM
WHERE NOT EXISTS(
				SELECT 1
				FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
							f.id=a.rf_idFiles
									INNER JOIN dbo.t_RecordCasePatient r ON
							a.id=r.rf_idRegistersAccounts
									INNER JOIN dbo.t_Case c ON
							r.id=c.rf_idRecordCasePatient						
									INNER JOIN dbo.t_PatientSMO p ON
							r.id=p.rf_idRecordCasePatient
									INNER JOIN dbo.t_CompletedCase cc ON
							r.id=cc.rf_idRecordCasePatient                  			
				WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND i.NumberPolicy=p.ENP
						AND i.CodeM=f.CodeM AND i.DateConsultation BETWEEN cc.DateBegin AND cc.DateEnd
					)






GO
DROP TABLE #tCases