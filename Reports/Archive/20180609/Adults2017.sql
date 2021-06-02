USE AccountOMS
go
DECLARE @dtStart DATETIME ='20170101',		
		@dtEnd DATETIME='20180120',
		@dtEndRak DATETIME='20180120',
		@reportYear smallint=2017,
		@reportMonth tinyint=12,
		@dtStartMM DATE,
		@dtEndMM DATE

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEndMM=CAST(@reportYear AS CHAR(4))+'1231'--dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01');

SELECT @dtStartMM, @dtEndMM

CREATE TABLE #tDS(DS VARCHAR(8)) 

INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'G%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'

CREATE TABLE #Kurs(v006 tinyint,rslt TINYINT,MES VARCHAR(20))

INSERT #Kurs(v006 , rslt, MES )
VALUES  (1,102,'10000302'), (1,102,'10000084'),(1,102,'10000300'), (1,102,'10100031'),(1,102,'10100032'),(1,102,'10100033'),(1,102,'10200031'),(1,102,'10200032'),(1,102,'10200033'),(1,102,'10100144'),
		(1,102,'10100145'),(1,102,'10100147'),(1,102,'10100148'),(1,102,'10100149'),(1,102,'10200142'),(1,102,'10200143'),(1,102,'10200144'),(1,102,'10200145'),(1,102,'10200147'),(1,102,'10200148'),
		(1,102,'10200149'),
		(2,202,'20000111'),(2,202,'20000036'),(2,202,'20000108'),(2,202,'20100012'),(2,202,'20100013'),(2,202,'20100014'),(2,202,'20100015'),(2,202,'20100044'),(2,202,'20100045'),
		(2,202,'20100046'),(2,202,'20100050'),(2,202,'20100051'),(2,202,'20100052'),(2,202,'20100053'),(2,202,'20100054'),(2,202,'20200013'),(2,202,'20200014'),(2,202,'20200015'),
		(2,202,'20200044'),(2,202,'20200045'),(2,202,'20200046'),(2,202,'20200050'),(2,202,'20200051'),(2,202,'20200052'),(2,202,'20200053'),(2,202,'20200054')


SELECT c.id AS rf_idCase
INTO #tmpWrong
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts					
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase							
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase				              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
				INNER JOIN #Kurs k ON
		c.rf_idv006=k.v006
		AND c.rf_idV009=k.rslt
		AND m.MES=k.MES              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006<3  AND a.ReportMonth<=@reportMonth
		

SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type
	,c.DateBegin, c.DateEnd, CASE WHEN c.rf_idV014=1 AND c.rf_idV006<3 THEN 1 WHEN c.rf_idV014=2 AND c.rf_idV006<3 THEN 2 WHEN c.rf_idV014=3 AND c.rf_idV006<3 THEN 0 END AS Gosp_type, ReportMonth, ReportYear
INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase							
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient					              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006<>3  AND a.ReportMonth<=@reportMonth 
		AND NOT EXISTS(SELECT * FROM #tmpWrong WHERE rf_idCase=c.id)

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014,rp.BirthDay, 'П',c.DateBegin, c.DateEnd
		, NULL, ReportMonth, ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient	
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient					             
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009=313	 AND a.ReportMonth<=@reportMonth 

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'О',c.DateBegin, c.DateEnd
		, null, ReportMonth, ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient	
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase								
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_MES m ON                
		c.id=m.rf_idCase   
				INNER JOIN dbo.vw_sprMU mu ON
		m.MES=mu.MU           
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009<>313  AND m.MES LIKE '2.78.%' AND a.ReportMonth<=@reportMonth AND c.rf_idV002 NOT IN(79,109,41)
		AND mu.MUGroupCode=2 AND mu.MUUnGroupCode=78 AND (mu.MUCode<61 or mu.MUCode>74)

INSERT #tmpPeople 
SELECT distinct c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'П',c.DateBegin, c.DateEnd
		, null, ReportMonth, ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase									
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient	
				INNER JOIN dbo.t_Meduslugi m ON                
		c.id=m.rf_idCase              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009<>313 AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 AND (m.MUCode<52 or m.MUCode>65 )
		AND a.ReportMonth<=@reportMonth AND c.rf_idV002 NOT IN(79,109,41) 

INSERT #tmpPeople
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type ,
		c.DateBegin,c.DateEnd,NULL, ReportMonth,ReportYear
--INTO #tmpPeople
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles				
				INNER JOIN dbo.t_RecordCasePatient r ON
		a.id=r.rf_idRegistersAccounts	
				INNER JOIN dbo.t_PatientSMO p ON
		r.id=p.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegisterPatient rp ON
		f.id=rp.rf_idFiles
		AND r.id=rp.rf_idRecordCase							
				INNER JOIN dbo.t_Case c  ON
		r.id=c.rf_idRecordCasePatient
				INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 					              
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase				
				INNER JOIN #tDS dd ON
		d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND ReportMonth<=@reportMonth AND c.Age>0 AND c.Age<18 AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<=@dtEndMM 

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DROP TABLE t_OrderAdult_104_2017

SELECT *, 0 AS PVT 
INTO t_OrderAdult_104_2017
FROM #tmpPeople
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1

CREATE NONCLUSTERED INDEX IX_Index_PVT
ON [dbo].[t_OrderAdult_104_2017] ([DS1],[ENP],[rf_idV006],[DateBegin])
INCLUDE ([rf_idCase],[DateEnd])
-------------------------------------Расчет PVT-------------------------------------------
;WITH doubleCase
AS(
	SELECT rf_idCase,ENP,DS1,rf_idV006 
	FROM t_OrderAdult_104_2017 
	WHERE PVT=0  
	GROUP BY rf_idCase,ENP,DS1,rf_idV006
),doubleDS as(SELECT ENP,DS1,rf_idV006 FROM doubleCase GROUP BY ENP,DS1,rf_idV006 HAVING COUNT(*)>1), 
cteMin AS (SELECT TOP 1 WITH TIES d.ENP,d.DS1,DateBegin AS MinDateBegin,s.rf_idV006
			FROM doubleDS d INNER JOIN dbo.t_OrderAdult_104_2017 s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.rf_idV006=s.rf_idV006
			ORDER BY ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,s.rf_idV006 ORDER BY DateBegin,DateEnd)
			
			)
SELECT  d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006
INTO #tmpDateBeg
FROM cteMin d INNER JOIN dbo.t_OrderAdult_104_2017 s ON	
					d.ENP=s.ENP
					AND d.DS1=s.DS1
					AND d.MinDateBegin=s.DateBegin
					AND d.rf_idV006=s.rf_idV006
GROUP BY d.ENP, d.DS1,s.DateEnd,rf_idCase,s.rf_idV006

;WITH cteRepeat
AS(
	SELECT distinct ROW_NUMBER() OVER(PARTITION BY d.ENP,d.DS1,d.rf_idV006 ORDER BY s.DateBegin,s.DateEnd) AS id,
			 s.rf_idCase, s.ENP,s.DS1,s.DateBegin,s.DateEnd,s.rf_idV006			 	
	FROM #tmpDateBeg d inner JOIN (SELECT DISTINCT ENP,DS1,DateBegin,DateEnd,rf_idCase,s.rf_idV006
								   from dbo.t_OrderAdult_104_2017 s ) s ON	
			d.ENP=s.ENP
			AND d.DS1=s.DS1	
			AND d.rf_idV006=s.rf_idV006
)
SELECT s.rf_idCase,(CASE WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>0 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=28 THEN 1 
						WHEN DATEDIFF(d,c1.DateEnd,c2.DateBegin)>29 AND DATEDIFF(d,c1.DateEnd,c2.DateBegin)+1<=90 THEN 2
					ELSE 0 END ) AS PVT
INTO #tt
from cteRepeat c1 inner JOIN cteRepeat c2 ON
		c1.ENP=c2.ENP
		AND c1.DS1=c2.DS1
		AND c1.id+1=c2.id
		AND c1.rf_idV006=c2.rf_idV006
				INNER JOIN dbo.t_OrderAdult_104_2017 s ON
		c2.rf_idCase=s.rf_idCase 
		AND c2.rf_idV006=s.rf_idV006

UPDATE s SET s.PVT=T.PVT
FROM dbo.t_OrderAdult_104_2017 s INNER JOIN #tt t ON	
			s.rf_idCase=t.rf_idCase 
------------------------------------------------------------------------------------------
GO
DROP TABLE #tDS
DROP TABLE #tmpPeople
DROP TABLE #tmpWrong
DROP TABLE #kurs
DROP TABLE #tmpDateBeg
DROP TABLE #tt