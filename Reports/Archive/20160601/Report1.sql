USE AccountOMS
GO
DECLARE @dateStart DATETIME='20160101',
		@dateEnd DATETIME='20160701',
		@dateEndPay DATETIME='20160922 23:59:59',
		@reportMM TINYINT=7

CREATE TABLE #tPeople(
					  rf_idCase BIGINT,					 
					  ReportMonth TINYINT,
					  ReportYear SMALLINT,
					  C_POKL TINYINT,
					  Agge TINYINT,
					  Sex TINYINT,
					  ENP VARCHAR(20),
					  DR DATE,
					  AttachLPU CHAR(6),
					  SNILS_Doc VARCHAR(11),
					  NumberCase INT,
					  DateBegin DATE,
					  DateEnd DATE,
					  P_OTK TINYINT,
					  AmountPayment decimal(11,2),
					  AmountDeduction DECIMAL(11,2) NOT NULL DEFAULT(0), 
					  PID int
					  )
INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,P_OTK,AmountPayment,ENP,PID)
SELECT c.id,a.ReportMonth, a.ReportYear, 4, 2016-YEAR(rp.BirthDay), rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,0,c.AmountPayment,p.ENP,p.PID
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles            
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2016 AND a.ReportMonth<@reportMM AND a.Letter='O' AND c.IsSpecialCase IN(3,23)

INSERT #tPeople( rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,P_OTK,AmountPayment,ENP,PID)
SELECT c.id,a.ReportMonth, a.ReportYear, 5, 2016-YEAR(rp.BirthDay), rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,0,c.AmountPayment,p.ENP,p.PID
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case_PID_ENP p ON
			c.id=p.rf_idCase      
					INNER JOIN dbo.t_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles            
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=2016 AND a.ReportMonth<@reportMM AND a.Letter='R'

---------------------------------------------------------------------------------------------------------------------------
--UPDATE c SET c.ENP=p.ENP
--FROM #tPeople c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
--			c.PID=p.ID

 UPDATE t SET t.SNILS_Doc=p.SS_Doctor,t.AttachLPU=p.lpu
FROM #tPeople t INNER JOIN (SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBegin>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idCase,p.PID ORDER BY p.LPUDT DESC, p.id desc)
							) p ON
			t.rf_idCase=p.rf_idCase   

---------------------------------------------------------------------------------------------------------------------------

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaymentAcceptedCase p INNER  JOIN #tPeople t ON			
												p.rf_idCase=t.rf_idCase
							WHERE p.DateRegistration>=@dateStart AND p.DateRegistration<@dateEndPay	 
							GROUP BY t.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

DROP TABLE dbo.t_Report1FFOMS

SELECT DISTINCT ROW_NUMBER() OVER(PARTITION BY ReportMonth ORDER BY AttachLPU,rf_idCase) AS Id, p.rf_idCase ,
        p.ReportMonth ,
        p.ReportYear ,
        p.C_POKL ,
        p.Agge AS Age,
        p.NumberCase ,
        p.DateBegin ,        
        p.P_OTK ,
        --p.AmountPayment ,
        --p.AmountDeduction ,
        p.PID,
		p.AttachLPU,
		p.SNILS_Doc,
		p.Sex,
		C_POKL-3 AS DISP
INTO t_Report1FFOMS
FROM #tPeople p	        
WHERE p.AmountDeduction>0 and p.AttachLPU IS NOT NULL AND p.SNILS_Doc IS NOT NULL	

GO
DROP TABLE #tPeople