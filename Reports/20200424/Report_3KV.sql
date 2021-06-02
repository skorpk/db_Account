USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20200307',
		@dateEndReg DATETIME='20200408',
		@dateStartRegRAK DATETIME='20200311',
		@dateEndRegRAK DATETIME='20200409',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=3


SELECT 1 AS TypeDiag,DiagnosisCode INTO #tDiag FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'J12' AND 'J18'

INSERT #tDiag(TypeDiag,DiagnosisCode) VALUES(1,'Z03.8'),(1,'Z22.8'),(1,'Z20.8'),(1,'Z11.5'),(1,'B34.2'),(1,'B33.8'),(1,'U07.1'),(1,'U07.2')
			,(2,'Z20.8'),(2,'B34.2'),(2,'U07.1'),(2,'U07.2')
		
SELECT distinct l.mcod,l.mcod+' - '+l.LPU_Mcode AS LPU,v.id,v.ColB,v.ColV
INTO #tCol
FROM dbo.vw_sprT001 l CROSS join (VALUES('Всего на медицинскую помощь пациентам с инфекционными заболеваниями органов дыхания, пневмонии, короновирусной инфекции (U07.1, U07.2, Z03.8, Z22.8, Z20.8, Z11.5, B34.2, B33.8, J12 - J18)','х',10),
('Неотложная помощь','посещение',20),
('Медицинская помощь в условиях круглосуточного стационара','случай госпитализации',30),
('справочно: количество случаев эстракорпоральной мембюранной оксигенации (ЭКМО)','случай ЭКМО',31),
('Скорая медицинская помощь','вызов',40)) v(id,ColB,ColV)


SELECT DISTINCT c.id AS rf_idCase, CASE WHEN c.rf_idV006<4 THEN c.AmountPayment ELSE 2314.0 END AS AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM,  a.ReportMonth,NULL Col2_80,NULL AS Col_A16
INTO #tCasesCovid
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20191205' AND f.DateRegistration<'20200120'  AND a.ReportYear=2019  AND a.ReportMonth=12 AND dd.TypeDiagnosis IN(1,3)
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode) AND a.rf_idSMO<>'34'

INSERT #tCasesCovid
SELECT DISTINCT c.id AS rf_idCase, CASE WHEN c.rf_idV006<4 THEN c.AmountPayment ELSE 2426.6 END AS AmountPayment,c.rf_idv008,f.CodeM,c.rf_idV006 AS USL_OK, c.rf_idV002, c.rf_idV014 AS FOR_POM, a.ReportMonth,NULL Col2_80,NULL AS Col_A16
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Diagnosis dd ON
			c.id=dd.rf_idCase						
WHERE f.DateRegistration>='20200118' AND f.DateRegistration<'20200311'  AND a.ReportYear=2020 AND a.ReportMonth<3 AND dd.TypeDiagnosis IN(1,3)
		AND EXISTS(SELECT 1 FROM #tDiag d WHERE d.DiagnosisCode=dd.DiagnosisCode) AND a.rf_idSMO<>'34'

UPDATE c SET c.Col2_80=1
FROM #tCasesCovid c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUGroupCode=2 AND m.MUUnGroupCode IN(80,82)


UPDATE c SET c.Col_A16=1
FROM #tCasesCovid c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='A16.10.021.001'


GO
DROP TABLE #tCasesCovid
GO
DROP TABLE #tCol
GO
DROP TABLE #tDiag

