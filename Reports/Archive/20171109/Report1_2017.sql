USE AccountOMS
GO
DECLARE @dateStart DATETIME='20170101',
		@dateEnd DATETIME='20171105',
		@dateEndPay DATETIME='20171114 23:59:59',
		@reportMM TINYINT=9,
		@reportYear SMALLINT=2017

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
					  PID INT,
					  DISP VARCHAR(5),
					  GUIdCase UNIQUEIDENTIFIER
					  )
INSERT #tPeople(rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,P_OTK,AmountPayment,ENP,PID,DISP,AttachLPU,GUIdCase)
SELECT c.id,a.ReportMonth, a.ReportYear, 4, @reportYear-YEAR(rp.BirthDay), rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,0,c.AmountPayment,p.ENP,p.PID,ds.TypeDisp
		,r.AttachLPU, c.GUID_Case
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
					INNER JOIN dbo.t_DispInfo ds ON
			c.id=ds.rf_idCase           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMM AND a.Letter='O' 
	AND ds.TypeDisp IN('ÄÂ1')

INSERT #tPeople(rf_idCase ,ReportMonth ,ReportYear ,C_POKL ,Agge ,Sex ,DR ,NumberCase ,DateBegin ,DateEnd ,P_OTK,AmountPayment,ENP,PID,DISP,AttachLPU,GUIdCase)
SELECT c.id,a.ReportMonth, a.ReportYear, 5, @reportYear-YEAR(rp.BirthDay), rp.rf_idV005,rp.BirthDay,c.idRecordCase,c.DateBegin,c.DateEnd,0,c.AmountPayment,p.ENP,p.PID,ds.TypeDisp
	,r.AttachLPU, c.GUID_Case
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
					INNER JOIN dbo.t_DispInfo ds ON
			c.id=ds.rf_idCase           
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear AND a.ReportMonth<@reportMM AND a.Letter='R'


UPDATE #tPeople SET AmountDeduction=AmountPayment
---------------------------------------------------------------------------------------------------------------------------
--UPDATE c SET c.ENP=p.ENP
--FROM #tPeople c INNER JOIN PolicyRegister.dbo.PEOPLE p ON
--			c.PID=p.ID
/*
 UPDATE t SET t.SNILS_Doc=p.SNILS
FROM #tPeople t INNER JOIN (SELECT c.GUID_Case,cd.SNILS
							FROM RegisterCases.dbo.t_CaseSNILSDefine cd INNER JOIN RegisterCases.dbo.t_RefCasePatientDefine r ON
										cd.rf_idRefCaseIteration=r.id
													INNER JOIN RegisterCases.dbo.t_Case c ON
										r.rf_idCase=c.id
							WHERE c.DateEnd>'20161231'			                        
							) p ON
			t.GUIdCase=p.GUID_Case
PRINT 'from RC'
UPDATE t SET t.SNILS_Doc=p.SS_Doctor
FROM #tPeople t INNER JOIN (SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBegin>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idCase,p.PID ORDER BY p.LPUDT DESC, p.id desc)
							) p ON
			t.rf_idCase=p.rf_idCase   
WHERE t.SNILS_Doc IS NULL
*/
UPDATE t SET t.SNILS_Doc=p.SS_Doctor
FROM #tPeople t INNER JOIN (SELECT TOP 1 WITH TIES t.rf_idCase,p.SS_DOCTOR,p.lpu
							from PolicyRegister.dbo.HISTLPU p INNER JOIN #tPeople t ON
										p.pid=t.PID	
							WHERE t.DateBegin>=CAST(p.LPUDT AS DATE) AND p.KATEG=1 
							ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idCase,p.PID ORDER BY p.LPUDT DESC, p.id desc)
							) p ON
			t.rf_idCase=p.rf_idCase   
--WHERE t.SNILS_Doc LIKE '0000%'
PRINT 'from PR'
---------------------------------------------------------------------------------------------------------------------------

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tPeople p INNER JOIN (
							SELECT t.rf_idCase,SUM(p.AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAcceptedCase2 p INNER  JOIN #tPeople t ON			
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
		Disp AS DISPName,
		0 AS N_ZAP2
INTO t_Report1FFOMS
FROM #tPeople p	        
WHERE p.AmountDeduction>0 and p.AttachLPU IS NOT NULL AND p.SNILS_Doc IS NOT NULL	
GO

;WITH cte
AS(
SELECT rank() OVER(PARTITION BY AttachLPU,SNILS_Doc ORDER BY ReportMonth) AS ID,
		 AttachLPU,rf_idCase
FROM dbo.t_Report1FFOMS 
)
UPDATE r SET r.N_Zap2=c.ID
from dbo.t_Report1FFOMS r INNER JOIN cte c ON
			r.rf_idCase=c.rf_idCase

CREATE NONCLUSTERED INDEX IX_1
ON [dbo].[t_Report1FFOMS] ([ReportMonth],[ReportYear],[AttachLPU],[SNILS_Doc])
INCLUDE ([Id],[rf_idCase],[Age],[NumberCase],[P_OTK],[Sex],[DISPName])
--SELECT l.CodeM, l.NAMES, 
--	COUNT(DISTINCT CASE WHEN C_POKL=4 THEN rf_idCase ELSE NULL END) AS Disp, 
--	COUNT(DISTINCT CASE WHEN C_POKL=5 THEN rf_idCase ELSE NULL END) AS Prof
--FROM #tPeople r INNER JOIN dbo.vw_sprT001 l ON
--			r.AttachLPU=l.CodeM
--WHERE r.AmountDeduction>0 and r.AttachLPU IS NOT NULL AND r.SNILS_Doc IS NOT NULL AND r.SNILS_Doc<>'0'	
--GROUP BY l.CodeM, l.NAMES
--ORDER BY l.CodeM       


GO
DROP TABLE #tPeople