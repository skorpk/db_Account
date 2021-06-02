USE AccountOMS
go
DECLARE @dtStart DATETIME ='20170101',		
		@dtEnd DATETIME='20180120',
		@dtEndRak DATETIME='20180120',
		@reportYear smallint=2017,
		@reportMonth tinyint=2,
		@dtStartMM DATE,
		@dtEndMM DATE

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+RTRIM('0'+CAST(@reportMonth AS CHAR(2)))+'01'
SET @dtEndMM=dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01');

CREATE TABLE #tDS(DS VARCHAR(8)) 

INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'G%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'


SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 3 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND m.MES LIKE '2.78.%' AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM


INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 4 AS TypeCol,c.AmountPayment AS AmountDeduction,c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_Meduslugi m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND c.Age>17  AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 5 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=1 AND c.rf_idV014=3 AND c.Age>17 AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 6 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=1 AND c.rf_idV014<3  AND c.Age>17	AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 7 AS TypeCol,c.AmountPayment AS AmountDeduction, c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=2 AND c.Age>17 AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

INSERT #tmpPeople (rf_idCase,AmountPayment,id,TypeCol, AmountDeduction, Age) 
SELECT c.id AS rf_idCase,c.AmountPayment, dd.id, 8 AS TypeCol,c.AmountPayment AS AmountDeduction,c.Age
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts								         
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient			
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
				INNER JOIN vw_sprMKB10 mkb ON
		d.DS1=mkb.DiagnosisCode
				INNER JOIN #tDS dd ON
		mkb.MainDS=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=4 AND c.Age>17	AND a.rf_idSMO<>'34'
AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT p.id
	, count(CASE WHEN TypeCol=3 THEN p.rf_idCase ELSE NULL END ) AS Col3
	, count(CASE WHEN TypeCol=4 THEN p.rf_idCase ELSE NULL END ) AS Col4
	, count(CASE WHEN TypeCol=5 THEN p.rf_idCase ELSE NULL END ) AS Col5
	, count(CASE WHEN TypeCol=6 THEN p.rf_idCase ELSE NULL END ) AS Col6
	, count(CASE WHEN TypeCol=7 THEN p.rf_idCase ELSE NULL END ) AS Col7
	, count(CASE WHEN TypeCol=8 THEN p.rf_idCase ELSE NULL END ) AS Col8
FROM #tmpPeople p
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1 AND p.Age<61
GROUP BY p.id
ORDER BY id


SELECT p.id
	, count(CASE WHEN TypeCol=3 THEN p.rf_idCase ELSE NULL END ) AS Col3
	, count(CASE WHEN TypeCol=4 THEN p.rf_idCase ELSE NULL END ) AS Col4
	, count(CASE WHEN TypeCol=5 THEN p.rf_idCase ELSE NULL END ) AS Col5
	, count(CASE WHEN TypeCol=6 THEN p.rf_idCase ELSE NULL END ) AS Col6
	, count(CASE WHEN TypeCol=7 THEN p.rf_idCase ELSE NULL END ) AS Col7
	, count(CASE WHEN TypeCol=8 THEN p.rf_idCase ELSE NULL END ) AS Col8
FROM #tmpPeople p
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1 AND p.Age>60
GROUP BY p.id
ORDER BY id

GO
DROP TABLE #tDS
DROP TABLE #tmpPeople