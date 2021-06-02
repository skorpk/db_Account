USE AccountOMS
GO
DECLARE @dateStart DATETIME='20170101',
		@dateEnd DATETIME='20170905',
		@dateEndPay DATETIME='20170922 23:59:59',
		@reportMM TINYINT=9,
		@reportYear SMALLINT=2017


CREATE TABLE #tPeople(rf_idCase BIGINT,
					    AmountPayment DECIMAL(11,2),
					    DateBeg DATE,						
					    PID INT,
					    AmountAccept decimal(11,2),
						AttachLPU CHAR(6),
						SNILS_Doc VARCHAR(11),
						Sex TINYINT,
						Age TINYINT,
						NumberCase INT,
						rf_idV006 TINYINT,
						rf_idV008 SMALLINT,
						ReportMonth TINYINT,
						ReportYear SMALLINT,
						IsMec BIT NOT NULL DEFAULT(0),
						C_POKL TINYINT,
						DR DATE,
						DS1 VARCHAR(10),
						GUIDCase UNIQUEIDENTIFIER
					   )

-------------------------взрослые госпитализаци€ рассматриваетс€-------------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1,GUIDCase)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,2,peo.DR,d.DiagnosisCode,
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
					INNER JOIN (VALUES(401),(402),(403),(404),(405),(406),(408),(411),(412),(413),(415),(417)) v009(id) ON
			c.rf_idV009=v009.id                  
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase	
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase	
			AND d.TypeDiagnosis=1
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id								
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<@reportMM AND a.ReportYear=@reportYear AND c.rf_idV006=4 AND p.PID IS NOT NULL
		AND c.Age>17

--------------------------------------------6---------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,6,peo.DR,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id					
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<@reportMM AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I1[0-5]%'  AND c.Age>17
--------------------------------------------7---------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,7,peo.DR,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<@reportMM AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I6[0-4]%' AND c.Age>17
--------------------------------------------8---------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,8,peo.DR,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMM AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode ='I20.0' AND c.Age>17
--------------------------------------------9---------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,9,peo.DR,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<@reportMM AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I21.%' AND c.Age>17
--------------------------------------------10---------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,AmountPayment, NumberCase,ReportMonth, ReportYear,C_POKL,DR,DS1)
SELECT DISTINCT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.AmountPayment,c.idRecordCase,a.ReportMonth, a.ReportYear,10,peo.DR,d.DiagnosisCode
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id 
					INNER JOIN dbo.t_Diagnosis d ON
			c.id=d.rf_idCase
			AND d.TypeDiagnosis=1				           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth>0 AND a.ReportMonth<@reportMM AND c.rf_idV006 IN(1,2) 
		AND d.DiagnosisCode LIKE 'I22.%' AND c.Age>17 
------------------------------------Payment----------------------------------------
UPDATE p SET p.IsMEC=1
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(f.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 f																		
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay
								AND NOT EXISTS(SELECT * 
											   FROM dbo.vw_CaseInActForAmbulanceReport t 
											   WHERE t.DateRegistration>=@dateStart AND t.DateRegistration<@dateEndPay AND t.rf_idCase=f.rf_idCase AND t.idAct=f.idAkt)
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

------------------------------------Payment----------------------------------------
 UPDATE t SET t.SNILS_Doc=p.SS_Doctor,t.AttachLPU=p.lpu
FROM #tPeople t INNER JOIN (SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBeg>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idCase,p.PID ORDER BY p.LPUDT DESC, p.id desc)
							) p ON
			t.rf_idCase=p.rf_idCase   
WHERE t.ISMEC=1
----------------------------------------Ќовое-----------------------------------------------------


--Ёто делать в последнию очередь т.к объеденили два формата

PRINT 'INSERT'
INSERT dbo.t_SNILSAmbulanceFFOMS( rf_idCase ,DateBeg ,PID ,SNILS_Doc ,AttachLPU ,Sex ,Age ,NumberCase ,rf_idV006 ,rf_idV008 ,DS,ReportMonth,ReportYear,C_POKL)
SELECT p.rf_idCase ,p.DateBeg ,p.PID ,p.SNILS_Doc ,p.AttachLPU ,p.Sex ,p.Age ,
        p.NumberCase ,p.rf_idV006 ,p.rf_idV008 ,p.DS1,ReportMonth,ReportYear,C_POKL
FROM #tPeople p	
WHERE p.AttachLPU IS NOT NULL AND p.SNILS_Doc IS NOT NULL
---формируем N_ZAP
UPDATE t SET t.id=f.id
from t_SNILSAmbulanceFFOMS T INNER JOIN (
											SELECT ROW_NUMBER() OVER(PARTITION BY ReportMonth ORDER BY AttachLPU,rf_idCase) AS id,rf_idCase
											FROM dbo.t_SNILSAmbulanceFFOMS
											WHERE ReportMonth>0 AND ReportYear=@reportYear
										) f ON
				T.rf_idCase=f.rf_idCase    

UPDATE s SET age=(DATEDIFF(YEAR,p.DR,s.DateBeg)-CASE WHEN 100*MONTH(p.DR)+DAY(p.DR)>100*MONTH(s.DateBeg)+DAY(s.DateBeg) THEN 1 ELSE 0 END)
FROM dbo.t_SNILSAmbulanceFFOMS s INNER JOIN PolicyRegister.dbo.PEOPLE p ON
				s.PID=p.ID
--TRUNCATE TABLE t_SNILSAmbulanceFFOMS
---удал€ем записи которые не были отданы в 23 приказе.
DELETE FROM dbo.t_SNILSAmbulanceFFOMS
FROM dbo.t_SNILSAmbulanceFFOMS s 
WHERE s.ReportYear=@reportYear AND rf_idV006 <3 AND EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS WHERE ReportYear=@reportYear AND IsFullDoubleDate=1  AND rf_idCase=s.rf_idCase)

update dbo.t_SNILSAmbulanceFFOMS SET DS=LEFT(DS,3) WHERE DS IN('J40.0','J47.0','M45.0','M45.9')
GO
DROP TABLE #tPeople
