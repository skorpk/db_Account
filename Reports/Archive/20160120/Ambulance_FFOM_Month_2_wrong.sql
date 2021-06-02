USE AccountOMS
GO
DECLARE @dateStart DATETIME='20150701',
		@dateEnd DATETIME='20151231 23:59:59',
		@dateEndPay DATETIME='20160119 23:59:59'

DECLARE @t DECIMAL(11,2),
		@t1 DECIMAL(11,2)
CREATE TABLE #tPeople(rf_idCase BIGINT,
					  CodeM CHAR(6),
					  CodeSMO CHAR(5),
					  AmountPayment DECIMAL(11,2),
					  DateBeg DATE,
					  DateEnd DATE,
					  PID INT,
					  SNILS_Doc VARCHAR(11),
					  IsMEC tinyint NOT NULL DEFAULT(0),
					  AttachLPU CHAR(6),
					  Sex TINYINT,
					  Age TINYINT,
					  NumberCase INT,
					  rf_idV006 TINYINT,
					  rf_idV008 SMALLINT,
					  rf_idV009 smallint ,
					  ReportMonth TINYINT,
					  ReportYear SMALLINT
					  )

-------------------------взрослые причисл€ютс€ к одной группе 5
INSERT #tPeople( rf_idCase ,CodeM ,CodeSMO ,AmountPayment,DateBeg, DateEnd,PID,Sex,Age,rf_idV006,rf_idV008,rf_idV009,NumberCase,ReportMonth,ReportYear)
SELECT c.id,f.CodeM,a.rf_idSMO,c.AmountPayment,c.DateBegin,c.DateEnd,p.PID,peo.W,c.Age
		,c.rf_idV006,c.rf_idV008,c.rf_idV009,c.idRecordCase, a.ReportMonth,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient							
					INNER JOIN (VALUES(401),(402),(403),(404),(405),(406),(411),(415),(417)) v009(id) ON
			c.rf_idV009=v009.id                  
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase		
					INNER JOIN PolicyRegister.dbo.PEOPLE peo ON
			p.PID=peo.id								
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>6 AND a.ReportMonth<=11 AND a.ReportYear=2015 AND c.rf_idV006=4 AND p.PID IS NOT NULL
		AND c.Age>17
	

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



UPDATE t SET t.SNILS_Doc=p.SS_Doctor,t.AttachLPU=p.lpu
FROM #tPeople t INNER JOIN ( SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBeg>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY p.PID ORDER BY p.LPUDT desc)
							) p ON
			t.rf_idCase=p.rf_idCase   
WHERE t.IsMEC=1			                          

INSERT dbo.t_SNILSAmbulanceFFOMS( rf_idCase ,DateBeg ,PID ,SNILS_Doc ,AttachLPU ,Sex ,Age ,NumberCase ,rf_idV006 ,rf_idV008 ,rf_idV009,ReportMonth,ReportYear,TypeData)
SELECT p.rf_idCase ,p.DateBeg ,p.PID ,p.SNILS_Doc ,p.AttachLPU ,p.Sex ,p.Age ,
        p.NumberCase ,p.rf_idV006 ,p.rf_idV008 ,p.rf_idV009,ReportMonth,ReportYear,'S'
FROM #tPeople p	
WHERE p.AttachLPU IS NOT NULL AND p.SNILS_Doc IS NOT NULL


GO
DROP TABLE #tPeople
--truncate TABLE t_SNILSAmbulanceStaciona
