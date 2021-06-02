USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190120',
		@dateStartReg2 DATETIME='20180101',
		@dateEndReg2 DATETIME='20191110',
		@reportYear SMALLINT=2018,
		@reportYear2 SMALLINT=2019

SELECT DISTINCT v.MU,CAST(t.PRICE AS DECIMAL(15,2)) AS Price,2018 AS ReportYear
INTO #tMU_SMP
FROM 
(values('71.1.1','71.2.1'),('71.1.2','71.2.2'),('71.1.3','71.2.3'),('71.1.4','71.2.4'),('71.1.5','71.2.5'),('71.1.6','71.2.6')) v(MU,MUTarif) 
					INNER JOIN oms_nsi.dbo.PriceMU t ON
					v.MUTarif=t.CODE_PRICE
					AND t.DATE_B>='20180101'
					AND t.DATE_E<'20190101'
UNION ALL
SELECT DISTINCT v.MU,CAST(t.PRICE AS DECIMAL(15,2)) AS Price,2019
FROM 
(values('71.1.1','71.2.1'),('71.1.2','71.2.2'),('71.1.3','71.2.3'),('71.1.4','71.2.4'),('71.1.5','71.2.5'),('71.1.6','71.2.6')) v(MU,MUTarif) 
					INNER JOIN oms_nsi.dbo.PriceMU t ON
					v.MUTarif=t.CODE_PRICE
					AND t.DATE_B>='20190101'
					AND t.DATE_E<'20200101'


SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.rf_idSMO, a.ReportYear,c.rf_idV006
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN PeopleAttach.dbo.ZL z ON
			p.ENP=z.enp																			                 
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006<4
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, smp.PRICE,p.ENP, a.rf_idSMO, a.ReportYear,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN PeopleAttach.dbo.ZL z ON
			p.ENP=z.enp
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN #tMU_SMP smp ON
			m.MU=smp.MU			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND c.rf_idV006=4 AND smp.ReportYear=@reportYear


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

INSERT #tCases
SELECT c.id AS rf_idCase, c.AmountPayment,p.ENP, a.rf_idSMO,  a.ReportYear,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient	
					INNER JOIN PeopleAttach.dbo.ZL z ON
			p.ENP=z.enp																		                 
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND a.ReportMonth<11 AND c.rf_idV006<4
UNION ALL
SELECT DISTINCT c.id AS rf_idCase, smp.PRICE,p.ENP, a.rf_idSMO, a.ReportYear,c.rf_idV006
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient
					INNER JOIN PeopleAttach.dbo.ZL z ON
			p.ENP=z.enp
					INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
					INNER JOIN #tMU_SMP smp ON
			m.MU=smp.MU			
WHERE f.DateRegistration>=@dateStartReg2 AND f.DateRegistration<@dateEndReg2  AND a.ReportYear=@reportYear2 AND a.ReportMonth<11 AND c.rf_idV006=4 AND smp.ReportYear=@reportYear2


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg2
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
WHERE p.ReportYear=@reportYear2

SELECT c.rf_idV006,v6.name
		,COUNT(DISTINCT CASE WHEN c.ReportYear=2018  THEN c.ENP ELSE NULL END) AS ENP_2018
		,CAST(SUM(CASE WHEN c.ReportYear=2018  THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS Sum_2018
		,COUNT(DISTINCT CASE WHEN c.ReportYear=2019 THEN c.ENP ELSE NULL END) AS ENP_2019
		,CAST(SUM(CASE WHEN c.ReportYear=2019 THEN c.AmountPayment ELSE 0.0 END) AS MONEY) AS Sum_2019
FROM #tCases c INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id
WHERE c.AmountPayment>0
GROUP BY c.rf_idV006,v6.name
ORDER BY c.rf_idV006

SELECT COUNT(DISTINCT enp) FROM #tCases WHERE AmountPayment>0
GO

DROP TABLE #tCases
DROP TABLE #tMU_SMP
