USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

CREATE TABLE #tLPU(CodeM CHAR(6))

CREATE TABLE #tD(DS1 VARCHAR(10), TypeDiag tinyint)

INSERT #tLPU
(
    CodeM
)
VALUES('114504'),('121018'),('124528'),('124530'),('134505'),('141016'),('141022'),('141023'),('141024'),('154602'),('154620'),('161007'),('161015'),('174601'),('184512'),('184603'),('251001'),
('251002'),('251003'),('254505'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391001'),('391002'),('401001'),('411001'),('421001'),
('431001'),('441001'),('451001'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),('581001'),('591001'),
('601001'),('611001'),('621001'),('711001')

INSERT #tD(DS1,TypeDiag) SELECT DiagnosisCode,1 FROM dbo.vw_sprMKB10 WHERE MainDS IN('С15',' С16',' C18',' C19',' С20',' С22 С25',' С32',' С34',' С43',' С44',' С50',' С53',' С54',' С56',' С61',' С64',' С67',' С73')
INSERT #tD(DS1,TypeDiag) SELECT DiagnosisCode,2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%' and MainDS NOT IN('С15',' С16',' C18',' C19',' С20',' С22 С25',' С32',' С34',' С43',' С44',' С50',' С53',' С54',' С56',' С61',' С64',' С67',' С73')
INSERT #tD(DS1,TypeDiag) SELECT DiagnosisCode,2 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0%'

;WITH cteFirst
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd,f.DateRegistration) AS idRow,c.id AS rf_idCase, c.AmountPayment,r.AttachLPU ,p.ENP, c.rf_idV002,a.Letter,dd.TypeDiag,dd.DS1,n2.KOD_St AS STAD
	,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN #tLPU l ON
            f.CodeM=l.CodeM					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
             r.id=p.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
             c.id=d.rf_idCase
					INNER JOIN #tD dd ON
             dd.DS1 = d.DS1		
					INNER JOIN dbo.t_ONK_SL os ON
			c.id=os.rf_idCase			
					left JOIN oms_nsi.dbo.sprN002 n2 ON
            os.rf_idN002=n2.ID_St
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34' AND c.rf_idV006<4 AND c.rf_idV002<>158 AND f.TypeFile='H'
	AND NOT EXISTS(SELECT 1 FROM dbo.t_CasesOnkologia2018 o2 WHERE p.ENP=o2.ENP)
)
SELECT rf_idCase,AmountPayment,AttachLPU,ENP,rf_idV002,Letter, cteFirst.STAD,1 AS TypeSearch,cteFirst.DateEnd
INTO #tCases
FROM cteFirst WHERE cteFirst.idRow=1

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

CREATE NONCLUSTERED INDEX IX_temp ON #tCases(ENP,AmountPayment)
---------------------------------------Column 32-----------------------------------------------------
;WITH cteFirst
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd,f.DateRegistration) AS idRow,c.id AS rf_idCase, c.AmountPayment,f.CodeM ,p.ENP, c.rf_idV002,a.Letter,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN #tLPU l ON
            f.CodeM=l.CodeM					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
             r.id=p.rf_idRecordCasePatient
					INNER JOIN #tCases ce ON
             p.ENP=ce.ENP
					left JOIN dbo.vw_DS_ONK ds ON
			 c.id=ds.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34' AND ce.AmountPayment>0 AND ( (c.rf_idV006=3 AND c.rf_idV002 NOT IN(12,18,60)) OR (a.Letter IN('O','R') AND ds.DS_ONK=1) )
)
INSERT #tCases(rf_idCase,AmountPayment,AttachLPU,ENP,rf_idV002,Letter,TypeSearch,DateEnd)
SELECT rf_idCase,AmountPayment,CodeM,ENP,rf_idV002,Letter,32 AS TypeSearch,cteFirst.DateEnd
FROM cteFirst WHERE cteFirst.idRow=1
---------------------------------------Column 33-----------------------------------------------------
;WITH cteFirst
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd,f.DateRegistration) AS idRow,c.id AS rf_idCase, c.AmountPayment,r.AttachLPU ,p.ENP, c.rf_idV002,a.Letter,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN #tLPU l ON
            r.AttachLPU=l.CodeM					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
             r.id=p.rf_idRecordCasePatient
					INNER JOIN #tCases ce ON
             p.ENP=ce.ENP
					inner JOIN dbo.vw_DS_ONK ds ON
			 c.id=ds.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.Age>17 AND ce.AmountPayment>0 AND a.rf_idSMO<>'34' AND c.rf_idV006=3 AND c.rf_idV002 IN(12,18,60) AND ds.DS_ONK=1
		AND ce.DateEnd>c.DateEnd
)
INSERT #tCases(rf_idCase,AmountPayment,AttachLPU,ENP,rf_idV002,Letter,TypeSearch,DateEnd)
SELECT c.rf_idCase, c.AmountPayment,c.AttachLPU,c.ENP,c.rf_idV002,c.Letter,33 AS TypeSearch,c.DateEnd
FROM cteFirst c
WHERE c.idRow=1 

---------------------------------------Column 34-----------------------------------------------------
;WITH cteFirst
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd,f.DateRegistration) AS idRow,c.id AS rf_idCase, c.AmountPayment,r.AttachLPU ,p.ENP, c.rf_idV002,a.Letter,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN #tLPU l ON
            r.AttachLPU=l.CodeM					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
             r.id=p.rf_idRecordCasePatient
					INNER JOIN #tCases ce ON
             p.ENP=ce.ENP		
					left JOIN dbo.vw_DS_ONK ds ON
			 c.id=ds.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.Age>17 AND ce.AmountPayment>0 AND a.rf_idSMO<>'34' AND ISNULL(ds.DS_ONK,9)<>1 AND f.CodeM=r.AttachLPU
)
INSERT #tCases(rf_idCase,AmountPayment,AttachLPU,ENP,rf_idV002,Letter,TypeSearch,DateEnd)
SELECT c.rf_idCase, c.AmountPayment,c.AttachLPU,c.ENP,c.rf_idV002,c.Letter,34 AS TypeSearch,c.DateEnd
FROM cteFirst c 
WHERE c.idRow=1 

---------------------------------------Column 35-----------------------------------------------------
;WITH cteFirst
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY p.ENP ORDER BY c.DateEnd,f.DateRegistration) AS idRow,c.id AS rf_idCase, c.AmountPayment,r.AttachLPU ,p.ENP, c.rf_idV002,a.Letter,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN #tLPU l ON
            r.AttachLPU=l.CodeM					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_PatientSMO p ON
             r.id=p.rf_idRecordCasePatient
					INNER JOIN #tCases ce ON
             p.ENP=ce.ENP
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.Age>17 AND ce.AmountPayment>0 AND a.rf_idSMO<>'34' AND f.CodeM<>r.AttachLPU AND ce.DateEnd>c.DateEnd
)
INSERT #tCases(rf_idCase,AmountPayment,AttachLPU,ENP,rf_idV002,Letter,TypeSearch,DateEnd)
SELECT c.rf_idCase, c.AmountPayment,c.AttachLPU,c.ENP,c.rf_idV002,c.Letter,35 AS TypeSearch,c.DateEnd
FROM cteFirst c WHERE c.idRow=1 

-------------------------------------------------------------------------------------------------------

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT DISTINCT ENP FROM #tCases WHERE TypeSearch=1 AND AttachLPU='114504'

SELECT l.CodeM,l.NAMES AS LPU,
		COUNT(DISTINCT CASE WHEN c.TypeSearch=1  THEN c.ENP ELSE NULL END) AS Col3,
		COUNT(DISTINCT CASE WHEN c.STAD='0'  THEN c.ENP ELSE NULL END) AS Col4,
		COUNT(DISTINCT CASE WHEN c.STAD='0a'  THEN c.ENP ELSE NULL END) AS Col5,
		COUNT(DISTINCT CASE WHEN c.STAD='0is'  THEN c.ENP ELSE NULL END) AS Col6,
		------------------------------------------------------------------------
		COUNT(DISTINCT CASE WHEN c.STAD='I'  THEN c.ENP ELSE NULL END) AS Col7,		
		COUNT(DISTINCT CASE WHEN c.STAD='IA'  THEN c.ENP ELSE NULL END) AS Col8,
		COUNT(DISTINCT CASE WHEN c.STAD='IA1'  THEN c.ENP ELSE NULL END) AS Col9,
		COUNT(DISTINCT CASE WHEN c.STAD='IA2'  THEN c.ENP ELSE NULL END) AS Col10,		
		COUNT(DISTINCT CASE WHEN c.STAD='IB'  THEN c.ENP ELSE NULL END) AS Col11,
		COUNT(DISTINCT CASE WHEN c.STAD='IB1'  THEN c.ENP ELSE NULL END) AS Col12,
		COUNT(DISTINCT CASE WHEN c.STAD='IB2'  THEN c.ENP ELSE NULL END) AS Col13,
		COUNT(DISTINCT CASE WHEN c.STAD='IC'  THEN c.ENP ELSE NULL END) AS Col14,
		------------------------------------------------------------------------
		COUNT(DISTINCT CASE WHEN c.STAD='II'  THEN c.ENP ELSE NULL END) AS Col15,		
		COUNT(DISTINCT CASE WHEN c.STAD='IIA'  THEN c.ENP ELSE NULL END) AS Col16,
		COUNT(DISTINCT CASE WHEN c.STAD='IIA1'  THEN c.ENP ELSE NULL END) AS Col17,
		COUNT(DISTINCT CASE WHEN c.STAD='IIA2'  THEN c.ENP ELSE NULL END) AS Col18,		
		COUNT(DISTINCT CASE WHEN c.STAD='IIB'  THEN c.ENP ELSE NULL END) AS Col19,
		COUNT(DISTINCT CASE WHEN c.STAD='IIC'  THEN c.ENP ELSE NULL END) AS Col20,
		------------------------------------------------------------------------
		COUNT(DISTINCT CASE WHEN c.STAD='III'  THEN c.ENP ELSE NULL END) AS Col21,		
		COUNT(DISTINCT CASE WHEN c.STAD='IIIA'  THEN c.ENP ELSE NULL END) AS Col22,
		COUNT(DISTINCT CASE WHEN c.STAD='IIIA1'  THEN c.ENP ELSE NULL END) AS Col23,
		COUNT(DISTINCT CASE WHEN c.STAD='IIIA2'  THEN c.ENP ELSE NULL END) AS Col24,		
		COUNT(DISTINCT CASE WHEN c.STAD='IIIB'  THEN c.ENP ELSE NULL END) AS Col25,
		COUNT(DISTINCT CASE WHEN c.STAD='IIIC'  THEN c.ENP ELSE NULL END) AS Col26,
		------------------------------------------------------------------------
		COUNT(DISTINCT CASE WHEN c.STAD='IV'  THEN c.ENP ELSE NULL END) AS Col27,		
		COUNT(DISTINCT CASE WHEN c.STAD='IVA'  THEN c.ENP ELSE NULL END) AS Col28,		
		COUNT(DISTINCT CASE WHEN c.STAD='IVB'  THEN c.ENP ELSE NULL END) AS Col29,
		COUNT(DISTINCT CASE WHEN c.STAD='IVC'  THEN c.ENP ELSE NULL END) AS Col30,
		COUNT(DISTINCT CASE WHEN ISNULL(c.STAD,'нет') ='нет' AND c.TypeSearch=1 THEN c.ENP ELSE NULL END) AS Col31,
		COUNT(DISTINCT CASE WHEN c.TypeSearch=32 THEN c.ENP ELSE NULL END ) AS Col32,
		COUNT(DISTINCT CASE WHEN c.TypeSearch=33 THEN c.ENP ELSE NULL END ) AS Col33,
		COUNT(DISTINCT CASE WHEN c.TypeSearch=34 THEN c.ENP ELSE NULL END ) AS Col34,
		COUNT(DISTINCT CASE WHEN c.TypeSearch=35 THEN c.ENP ELSE NULL END ) AS Col35
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.AttachLPU=l.CodeM
WHERE AmountPayment>0.0
GROUP BY l.CodeM,l.NAMES 
ORDER BY CodeM
GO

DROP TABLE #tD
DROP TABLE #tCases
DROP TABLE #tLPU