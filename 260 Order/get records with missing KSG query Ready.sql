USE AccountOMS
go
DECLARE @dateStartReg DATETIME='20190801',
		@dateEndReg datetime=GETDATE()

SELECT c.id,c.rf_idMO,cc.DateEnd,c.rf_idSubMO,c.rf_idDepartmentMO, c.rf_idV006,f.CodeM,a.Account,MES,c.AmountPayment,CAST(0.0 AS decimal(15,2)) AS AmountPay
INTO #tCases
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
				INNER JOIN dbo.t_RecordCasePatient r ON
             r.rf_idRegistersAccounts = a.id
				INNER JOIN t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
WHERE f.DateRegistration>@dateStartReg AND a.ReportYear=2019 AND c.rf_idV006<3 AND m.TypeMES=2 --AND f.CodeM='103001'


UPDATE p SET p.AmountPay=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartReg AND c.DateRegistration<@dateEndReg
								GROUP BY c.rf_idCase
							) r ON
			p.id=r.rf_idCase

SELECT c.CodeM,c.Account, c.id AS rf_idCase,c.DateEnd
from #tCases c INNER JOIN dbo.vw_sprT001 l ON
			c.rf_idMO=l.CodeM					
WHERE c.AmountPay>0 
AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.V_KOEF_U v WHERE l.mcod=v.LPU AND ISNULL(c.rf_idSubMO,'99')=ISNULL(v.LPU_1,'99') AND ISNULL(c.rf_idDepartmentMO,'99')=ISNULL(v.PODR,'99')
		AND c.rf_idV006=v.USL_OK)


GO
DROP TABLE #tCases