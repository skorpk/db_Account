USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019

CREATE TABLE #tLPU(CodeM CHAR(6))
INSERT #tLPU
(
    CodeM
)
VALUES('114504'),('121018'),('124528'),('124530'),('134505'),('141016'),('141022'),('141023'),('141024'),('154602'),('154620'),('161007'),('161015'),('174601'),('184512'),('184603'),('251001'),
('251002'),('251003'),('254505'),('301001'),('311001'),('321001'),('331001'),('341001'),('351001'),('361001'),('371001'),('381001'),('391001'),('391002'),('401001'),('411001'),('421001'),
('431001'),('441001'),('451001'),('461001'),('471001'),('481001'),('491001'),('501001'),('511001'),('521001'),('531001'),('541001'),('551001'),('561001'),('571001'),('581001'),('591001'),
('601001'),('611001'),('621001'),('711001')

SELECT c.id AS rf_idCase, c.AmountPayment,r.AttachLPU AS CodeM,p.ENP
INTO #tCases
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
					INNER JOIN dbo.t_DS_ONK_REAB d ON
             c.id=d.rf_idCase
WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportYear=@reportYear AND c.rf_idV006=1 AND a.Letter IN('S','H') AND c.Age>17
		AND a.rf_idSMO<>'34' AND d.DS_ONK=1


UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd AND c.TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT l.CodeM,l.NAMES AS LPU, COUNT(DISTINCT c.ENP) AS CountPeople
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE AmountPayment>0.0
GROUP BY l.CodeM,l.NAMES 
UNION ALL
SELECT l.CodeM,l.NAMES AS LPU, 0 AS CountPeople
FROM #tLPU c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE NOT EXISTS(SELECT 1 FROM #tCases WHERE CodeM=c.CodeM)
GROUP BY l.CodeM,l.NAMES 
ORDER BY CodeM
GO
DROP TABLE #tCases
DROP TABLE #tLPU