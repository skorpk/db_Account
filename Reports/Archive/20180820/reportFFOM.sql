USE AccountOMS
GO
DECLARE @dtStart DATETIME='20170101',
		@dtEnd DATETIME='20180119',
		@dtEndRAK DATETIME='20180120',
		@reportMM TINYINT=12,
		@reportYear SMALLINT=2017,
		@idV006 TINYINT=1

CREATE TABLE #tDiag(id tinyint,Diag VARCHAR(8), DiaMain VARCHAR(5), DiagName VARCHAR(200),GroupDiag VARCHAR(25) )
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 1, DiagnosisCode,'Стенокардия',MainDS,'I20' FROM dbo.vw_sprMKB10 WHERE MainDS='I20'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 2, DiagnosisCode,'Инфаркт миокарда' ,MainDS,'I21-I22' FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I2[0-2]'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 3, DiagnosisCode,'Цереброваскулярные болезни' ,MainDS,'I60-I69' FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I6[0-9]'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 4, DiagnosisCode,'Ишемический инсульт' ,MainDS,'I63' FROM dbo.vw_sprMKB10 WHERE MainDS ='I63'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 5, DiagnosisCode,'Геморагический инсульт' ,MainDS,'I60-I62' FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I6[0-2]'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 6, DiagnosisCode,'Онкология' ,MainDS,'C00-C97,D00-D048' FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C[0-9][0-9]'
INSERT #tDiag(id, Diag, DiagName, DiaMain, GroupDiag ) SELECT 6, DiagnosisCode,'Онкология' ,MainDS,'C00-C97,D00-D048' FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D[0-4]%'


SELECT c.id,c.AmountPayment, c.AmountPayment AS AmountPaymentAccepted,c.rf_idV002, c.Age, d.DS1
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts				
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient		
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase																							
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM
		AND c.DateEnd>='20170101' AND c.DateEnd<'20180101' AND a.rf_idSMO<>'34' AND c.rf_idV006 =@idV006

UPDATE p SET p.AmountPaymentAccepted=p.AmountPaymentAccepted-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEndRAK
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT 0 AS IdRow,v2.id AS ProfilCode, v2.name AS ProfilName, '',''
		, COUNT(CASE WHEN p.Age>17 THEN p.id ELSE null end) AS CountAdult, Sum(CASE WHEN p.Age>17 THEN p.AmountPaymentAccepted ELSE 0.0 end) AS SumAdult
		, COUNT(CASE WHEN p.Age<18 THEN p.id ELSE null end) AS CountChild, Sum(CASE WHEN p.Age<18 THEN p.AmountPaymentAccepted ELSE 0.0 end) AS SumChild
FROM #tmpPeople p INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
			p.rf_idV002=v2.id		
WHERE p.AmountPaymentAccepted>0 AND p.rf_idV002=29
GROUP BY v2.id , v2.name 
UNION all
SELECT d.id,v2.id AS ProfilCode, v2.name AS ProfilName, d.GroupDiag,d.DiagName
		, COUNT(CASE WHEN p.Age>17 THEN p.id ELSE null end) AS CountAdult, Sum(CASE WHEN p.Age>17 THEN p.AmountPaymentAccepted ELSE 0.0 end) AS SumAdult
		, COUNT(CASE WHEN p.Age<18 THEN p.id ELSE null end) AS CountChild, Sum(CASE WHEN p.Age<18 THEN p.AmountPaymentAccepted ELSE 0.0 end) AS SumChild
FROM #tmpPeople p INNER JOIN RegisterCases.dbo.vw_sprV002 v2 ON
			p.rf_idV002=v2.id
				  INNER JOIN #tDiag d ON
			p.DS1=d.Diag					
WHERE p.AmountPaymentAccepted>0			                  
GROUP BY d.id,v2.id , v2.name,d.GroupDiag,d.DiagName 
UNION ALL
SELECT 99 AS IdRow,0, 'Медицинская помощь, оказанная детскому населению' AS ProfilName, '',''
		, 0 AS CountAdult, 0 AS SumAdult
		, COUNT(p.id ) AS CountChild, Sum(p.AmountPaymentAccepted) AS SumChild
FROM #tmpPeople p 		
WHERE p.AmountPaymentAccepted>0 AND p.Age<18
ORDER BY idRow


GO
DROP TABLE #tDiag
DROP TABLE #tmpPeople