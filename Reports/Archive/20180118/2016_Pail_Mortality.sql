USE AccountOMS
GO		
DECLARE @dtBegin DATETIME,	
		@dtEndReg DATETIME=GETDATE(),
		@dtEnd DATE,
		@reportYear SMALLINT=2016

SET @dtBegin=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEnd=DATEADD(YEAR,1,@dtBegin)
--SELECT @dtBegin,@dtEnd,@dtEndReg

SELECT MU,MUName INTO #tMU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=1 AND MUUnGroupCode IN(12,16,17,18) AND MUCode IN(498,499)
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,m.mes,p.FAM,p.IM,p.Ot,p.DR,p.ENP,c.DateBegin, c.DateEnd,p.LPU,
		DATEDIFF(DAY,c.DateEnd,p.DS) AS DifDate, p.DS,MUName
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
					INNER JOIN #tMU mm ON
			m.MEs=mm.MU  			
					INNER JOIN dbo.t_Case_PID_ENP ps ON
			c.id=ps.rf_idCase	
					INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			ps.PID=p.id				
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear --	AND m.MES IN('1.12.498','1.12.499','1.16.498','1.16.499','1.17.498','1.17.499','1.18.498','1.18.499')
	AND a.rf_idSMO<>'34' AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEnd AND p.DS IS NOT NULL

UPDATE c SET c.AmountPaymentAccepted=c.AmountPaymentAccepted-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase   
SELECT  l.NAMES,MUName ,ENP, CAST(DS AS DATE) AS DS, FAM ,IM ,ISNULL(OT,'') ,CAST(DR AS DATE) as DR ,l1.NAMES AS AttachLPU, c.DateBegin ,c.DateEnd ,DifDate
FROM #tmpCases c INNER JOIN vw_sprt001 l ON
		c.CodeM=l.CodeM			 
				INNER JOIN vw_sprt001 l1 ON
		c.LPU=l1.CodeM			 
WHERE AmountPaymentAccepted>0
ORDER BY l.CodeM
GO
DROP TABLE #tmpCases
DROP TABLE #tMU