USE AccountOMS
GO
DECLARE @dateStart DATETIME='20200101',
		@dateEnd DATETIME='20210116',
		@dateEndPay DATETIME='20210119'
CREATE TABLE #LPU(CodeM CHAR(6))
INSERT #LPU VALUES ('101001'),('101002'),('101003'),('101004'),('101201'),('101302'),('101309'),('101321'),('102604'),('103001'),('104001'),('104401'),('105301'),('106001'),('106002'),
('111008'),('114504'),('115309'),('115506'),('121018'),('121125'),('121501'),('124528'),('124530'),('125308'),('125901'),('126501'),('131001'),('131020'),('134505'),('135311'),('141016'),
('141022'),('141023'),('141024'),('145312'),('145516'),('146004'),('151005'),('151012'),('154602'),('155307'),('155601'),('158202'),('161007'),('161015'),('165310'),('165531'),('171004'),
('173801'),('174601'),('175303'),('175603'),('175954'),('175955'),('176001'),('182001'),('184512'),('184603'),('185402'),('185515'),('186002'),('251001'),('251002'),('251003'),('251008'),
('254505'),('255315'),('255627'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('355301'),('361001'),('365301'),('371001'),('381001'),('391001'),('391002'),('391003'),
('395301'),('401001'),('411001'),('421001'),('431001'),('435301'),('441001'),('451001'),('451002'),('455301'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),
('531001'),('541001'),('551001'),('561001'),('571001'),('581001'),('591001'),('601001'),('611001'),('615301'),('621001')


-----стационар, дневной стационар и скорая.
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, CASE WHEN cc.AmountPayment=0.0 THEN 2428.6 ELSE cc.AmountPayment END AS AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006
INTO #tCases
FROM dbo.t_File f JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN #LPU l ON
			F.CodeM=l.CodeM				
					JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient											
					JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis IN(1,3)
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006 IN(1,2,4) AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34'
CREATE UNIQUE NONCLUSTERED INDEX QU_IX ON #tCases(rf_idRecordCasePatient,rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006
FROM dbo.t_File f JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN #LPU l ON
			F.CodeM=l.CodeM				
					JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient											
					JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006=3 AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34'
 AND EXISTS(		
            select 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND m.MUCode BETWEEN 111 AND 119
			UNION ALL
            select 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=2 AND m.MUUnGroupCode=80 AND m.MUCode BETWEEN 58 AND 66
			UNION ALL
            select 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MUGroupCode=4 AND m.MUUnGroupCode=17 AND m.MUCode IN(785,786)
			UNION ALL
            select 1 FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND m.MU IN('4.27.1', '4.15.747')
		) 	
INSERT #tCases
SELECT DISTINCT c.id AS rf_idCase, f.CodeM, cc.AmountPayment,c.rf_idRecordCasePatient,c.rf_idV006
FROM dbo.t_File f JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					JOIN #LPU l ON
			F.CodeM=l.CodeM				
					JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient											
					JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient																
					JOIN dbo.t_MES m ON
            c.id=m.rf_idCase
					JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2020 AND c.rf_idV006=3 AND d.DiagnosisCode IN('U07.1','U07.2') AND a.rf_idSMO<>'34'
	AND MES IN ('2.78.94','2.78.95','2.78.96','2.78.97','2.78.98','2.78.99','2.78.100','2.78.101','2.78.102')

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase



SELECT l.CodeM,ll.Names, CAST(SUM(ISNULL(cc.AmountPayment,0.0)) AS MONEY) AS AmountPayment,ISNULL(cc.name,'') AS nameV6
FROM #LPU l JOIN dbo.vw_sprT001 ll ON
		l.CodeM=ll.CodeM
			LEFT JOIN (SELECT DISTINCT c.rf_idRecordCasePatient,c.AmountPayment,c.CodeM ,v6.name FROM #tCases c INNER JOIN vw_sprV006 v6 ON c.rf_idV006=v6.id) cc ON
		l.CodeM=cc.CodeM
			
GROUP BY l.CodeM,ll.NAMES,ISNULL(cc.name,'') 
ORDER BY l.CodeM,nameV6
GO
DROP TABLE #tCases
GO
DROP TABLE #LPU