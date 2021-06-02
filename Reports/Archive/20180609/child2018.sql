USE AccountOMS
go
DECLARE @dtStart DATETIME ='20180101',		
		@dtEnd DATETIME='20180610',
		@dtEndRak DATETIME='20180611',
		@reportYear smallint=2018,
		@reportMonth tinyint=5,
		@dtStartMM DATE,
		@dtEndMM DATE

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEndMM=CAST(@reportYear AS CHAR(4))+'0531'--dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01');

--SELECT @dtStartMM, @dtEndMM

CREATE TABLE #tDS(DS VARCHAR(8)) 

INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'A%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'


SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type ,
		c.DateBegin,c.DateEnd, ReportMonth
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


drop table t_OrderChild_104_2018

SELECT *, NULL AS PVT
INTO t_OrderChild_104_2018
FROM #tmpPeople
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1

GO
DROP TABLE #tDS
DROP TABLE #tmpPeople