USE AccountOMS
GO		

DECLARE @dtBegin DATETIME='20160101',	
		@dtEndReg DATETIME='20170626 23:59:59',
		@dtEndRegRAK DATETIME='20170626 23:59:59',
		@reportYear SMALLINT=2016,
		@reportMonth TINYINT=12
				
SELECT f.CodeM,c.id AS rf_idCase,c.AmountPayment,rp.FAM,rp.Im,ISNULL(rp.Ot,'') AS Ot,rp.BirthDay,ISNULL(r.SeriaPolis,'')+r.NumberPolis AS Policy,pc.IDPeople
INTO #tmp
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts		
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_RegisterPatient rp ON
			r.id=rp.rf_idRecordCase
			AND f.id=rp.rf_idFiles	
					INNER JOIN dbo.t_People_Case pc ON
			c.id=pc.rf_idCase				                
WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndReg AND a.ReportYear=@reportYear AND a.ReportMonth<=@reportMonth 
	AND a.rf_idSMO IN('34007','34006','34002','34001') AND a.Letter='O' AND c.IsSpecialCase IN(23,3)


UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmp c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
						 FROM ExchangeFinancing.dbo.t_AFileIn f INNER JOIN  ExchangeFinancing.dbo.t_DocumentOfCheckup d ON
														f.id=d.rf_idAFile
																	INNER JOIN ExchangeFinancing.dbo.t_CheckedAccount a ON
														d.id=a.rf_idDocumentOfCheckup
															INNER JOIN ExchangeFinancing.dbo.t_CheckedCase c ON
														a.id=c.rf_idCheckedAccount
															INNER JOIN #tmp cc ON
														c.rf_idCase=cc.rf_idCase 																							
								WHERE f.DateRegistration>=@dtBegin AND f.DateRegistration<=@dtEndRegRAK
								GROUP BY c.rf_idCase 
							) p ON
			c.rf_idCase=p.rf_idCase 

;WITH cteDouble
AS(
SELECT  ROW_NUMBER() OVER(PARTITION BY IDPeople ORDER BY rf_idCase) AS id,CodeM ,rf_idCase ,AmountPayment ,FAM ,Im ,Ot ,BirthDay ,Policy ,IDPeople
FROM #tmp WHERE AmountPayment>0
) SELECT * FROM cteDouble WHERE id>1

;WITH cteDouble
AS(
SELECT  ROW_NUMBER() OVER(PARTITION BY IDPeople ORDER BY rf_idCase) AS id,CodeM ,rf_idCase ,AmountPayment ,FAM ,Im ,Ot ,BirthDay ,Policy ,IDPeople
FROM #tmp WHERE AmountPayment>0
) delete FROM cteDouble WHERE id>1


--DROP TABLE dbo.tmpFSS

SELECT DISTINCT t.CodeM,l.NAMES AS LPU, t.FAM ,t.Im ,t.Ot ,t.BirthDay ,t.Policy
INTO tmpFSS
FROM #tmp t INNER JOIN dbo.vw_sprT001 l ON
		t.CodeM=l.CodeM
WHERE AmountPayment>0
go
DROP TABLE #tmp
