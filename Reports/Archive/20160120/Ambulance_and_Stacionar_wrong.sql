USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150701',
		@dateEnd DATETIME='20151231 23:59:59',
		@dateEndPay DATETIME='20160119 23:59:59'

DECLARE @t DECIMAL(11,2),
		@t1 DECIMAL(11,2)
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  DateBeg DATE,
					  PID INT,
					  IsMEC tinyint NOT NULL DEFAULT(0),
					  )

CREATE TABLE #tSacionar(rf_idCase BIGINT,
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
						rf_idV009 SMALLINT,
						IsHospitalization bit NOT NULL DEFAULT(0)
					   )

-------------------------взрослые госпитализация-------------------------------
INSERT #tPeople( rf_idCase ,DateBeg, PID)
SELECT c.id,c.DateBegin,p.PID
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>6 AND a.ReportMonth<=11 AND a.ReportYear=2015 AND c.rf_idV006=4 AND p.PID IS NOT NULL
		AND c.Age>17 AND c.rf_idV009=403
-------------------------взрослые стационар-------------------------------
INSERT #tSacionar( rf_idCase ,DateBeg, PID,Sex,Age,rf_idV006,rf_idV008,rf_idV009,AmountPayment, NumberCase)
SELECT c.id,c.DateBegin,p.PID,peo.W,c.Age,c.rf_idV006,c.rf_idV008,c.rf_idV009,c.AmountPayment,c.idRecordCase
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>6 AND a.ReportMonth<=11 AND a.ReportYear=2015 AND c.rf_idV006=1 AND p.PID IS NOT NULL
		AND c.Age>17 
	
------------------------------------Payment----------------------------------------
UPDATE p SET p.IsMEC=1
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 																							
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay
								AND NOT EXISTS(SELECT * 
											   FROM ExchangeFinancing.dbo.vw_CaseInActForAmbulanceReport t 
											   WHERE t.DateRegistration>=@dateStart AND t.DateRegistration<@dateEndPay AND t.id=c.id)
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.AmountAccept=p.AmountPayment-r.AmountDeduction
FROM #tSacionar p INNER JOIN (
							SELECT rf_idCase,SUM(c.AmountMEE+c.AmountEKMP+c.AmountMEK) AS AmountDeduction
							FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
													f.id=d.rf_idAFile
																INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
													d.id=a.rf_idDocumentOfCheckup
														INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
													a.id=c.rf_idCheckedAccount 																							
							WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEndPay
								
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
------------------------------------Payment----------------------------------------

UPDATE s SET s.IsHospitalization=1
FROM #tPeople p INNER JOIN #tSacionar s ON
		p.PID=s.PID
		AND p.DateBeg=s.DateBeg
WHERE p.IsMEC=1	AND s.AmountAccept IS NOT NULL


UPDATE t SET t.SNILS_Doc=p.SS_Doctor,t.AttachLPU=p.lpu
FROM #tSacionar t INNER JOIN ( SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tSacionar t ON
										p.pid=t.PID	
							WHERE t.DateBeg>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY p.PID ORDER BY p.LPUDT desc)
							) p ON
			t.rf_idCase=p.rf_idCase   
WHERE t.IsHospitalization=1

PRINT 'INSERT'
INSERT dbo.t_SNILSAmbulanceStaciona( rf_idCase ,DateBeg ,PID ,SNILS_Doc ,AttachLPU ,Sex ,Age ,NumberCase ,rf_idV006 ,rf_idV008 ,rf_idV009)
SELECT p.rf_idCase ,p.DateBeg ,p.PID ,p.SNILS_Doc ,p.AttachLPU ,p.Sex ,p.Age ,
        p.NumberCase ,p.rf_idV006 ,p.rf_idV008 ,p.rf_idV009
FROM #tSacionar p	
WHERE p.AttachLPU IS NOT NULL AND p.SNILS_Doc IS NOT NULL


GO
DROP TABLE #tPeople
DROP TABLE #tSacionar
