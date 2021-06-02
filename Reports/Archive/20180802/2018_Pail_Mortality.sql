USE AccountOMS
GO		
DECLARE @dtBegin DATETIME,	
		@dtEndReg DATETIME=GETDATE(),
		@dtEnd DATE,
		@reportYear SMALLINT=2018

SET @dtBegin=CAST(@reportYear AS CHAR(4))+'0101'
SET @dtEnd=GETDATE()
--SELECT @dtBegin,@dtEnd,@dtEndReg

				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment ,c.AmountPayment AS AmountPaymentAccepted,a.rf_idSMO AS CodeSMO,p.ENP,c.DateBegin, c.DateEnd,p.LPU,p.DS, c.rf_idV006, a.Account
		,a.DateRegister,c.idRecordCase,c.GUID_Case
INTO #tmpCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient                  
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient 					
					INNER JOIN PolicyRegister.dbo.PEOPLE p ON
			ps.ENP=p.ENP
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34' 
		AND c.DateEnd>=@dtBegin AND c.DateEnd<@dtEnd AND p.DS<c.DateEnd

UPDATE c SET c.AmountPaymentAccepted=c.AmountPaymentAccepted-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c																						
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase   

SELECT  CodeSMO,c.CodeM+' - '+l.NAMES, Account,DateRegister AS DateAccount,idRecordCase AS NumberCase,GUID_Case,
		ENP,CAST(DS AS DATE) AS DS,DateBegin,c.DateEnd, v6.name AS USL_OK, c.AmountPaymentAccepted
FROM #tmpCases c INNER JOIN vw_sprt001 l ON
		c.CodeM=l.CodeM			 
				INNER JOIN vw_sprt001 l1 ON
		c.LPU=l1.CodeM		
				INNER JOIN RegisterCases.dbo.vw_sprV006 v6 ON
		c.rf_idV006=v6.id              
WHERE (CASE WHEN AmountPayment>0 AND AmountPaymentAccepted>0 THEN 1 WHEN AmountPayment=0 and AmountPaymentAccepted=0 THEN 1 ELSE 0 END)=1
ORDER BY l.CodeM
GO
DROP TABLE #tmpCases
