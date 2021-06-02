USE AccountOMS
GO		
DECLARE @dtBegin DATETIME='20170101',	
		@dtEndReg DATETIME=GETDATE(),
		@dtEndRegAkt DATETIME=GETDATE(),
		@v6 TINYINT=1,
		@reportYear SMALLINT =2017,
		@reportMM TINYINT=11
  

CREATE TABLE #tmpCases(CodeM varchar(6),rf_idCase bigint,AmountPayment decimal(15, 2),AmountPaymentAccepted decimal(15, 2)
						,AmountMEK DECIMAL(15,2) ,AmountMEE DECIMAL(15,2),AmountEKMP DECIMAL(15,2)
						,ReasonMEK VARCHAR(600) NOT NULL DEFAULT(''),ReasonMEE VARCHAR(600) NOT NULL DEFAULT(''),ReasonEKMP VARCHAR(600) NOT NULL DEFAULT(''),
						MU VARCHAR(9), MUName VARCHAR(250), MEK TINYINT,MEE TINYINT, EKMP TINYINT,DS DATETIME,enp VARCHAR(16) )

SELECT MU,MUName INTO #tMU FROM dbo.vw_sprMUCompletedCase WHERE MUGroupCode=1 AND MUUnGroupCode IN(12,16,17,18) AND MUCode IN(498,499)

INSERT #tmpCases( CodeM ,rf_idCase ,AmountPayment ,AmountPaymentAccepted, MU,MUName,DS,enp )	
SELECT distinct f.CodeM,c.id AS rf_idCase,c.AmountPayment,c.AmountPayment ,mm.MU,mm.MUName,pp.DS,s.ENP
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				    INNER JOIN (VALUES('104401'),('121125'),('101001'),('185905')) v(CodeM) ON
			f.CodeM=v.CodeM                  
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts						
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_PatientSMO s ON
			r.id=s.rf_idRecordCasePatient					
					INNER JOIN t_mes m ON
			c.id=m.rf_idCase                      
					INNER JOIN #tMU mm ON
			m.MEs=mm.MU                  					
					left JOIN PolicyRegister.dbo.PEOPLE pp ON
			s.ENP=pp.ENP
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND c.rf_idV006=@v6 AND a.rf_idSMO IN('34001','34002','34006','34007') AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMM
		AND ISNULL(pp.DS,'19990101')<'20171202'

---------------------------------------------------------------------------------------------------------------------------------------
UPDATE c SET c.AmountPaymentAccepted=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c INNER JOIN #tmpCases t ON
												c.rf_idCase=t.rf_idCase																							
								WHERE c.DateRegistration>=@dtBegin AND c.DateRegistration<=@dtEndRegAkt
								GROUP BY c.rf_idCase, TypeCheckup
							) p ON
			c.rf_idCase=p.rf_idCase    
----------------------------------------------------------------------------------------------
SELECT c.CodeM,l.NAMES,c.MUName,c.enp, CAST(c.ds AS DATE)
from #tmpCases c INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM					
--GROUP BY c.CodeM,l.NAMES,c.MUName
ORDER BY c.CodeM
go
drop TABLE #tmpCases
drop TABLE #tMU