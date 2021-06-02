					  USE AccountOMS
GO
DECLARE @dateEnd DATETIME='20140301 23:59:59',
		@dateEndPay DATETIME='20150519',
		@reportYear smallint=2013,
		@reportNextYear smallint=2014		
		
declare	@dateStart DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

CREATE TABLE #tPeople(rf_idCase BIGINT,					  
					  DS1 CHAR(6),
					  AmountPayment DECIMAL(11,2),
					  AmountRPD DECIMAL(11,2),
					  ReportYear smallint					 
					  )


INSERT #tPeople( rf_idCase ,DS1 ,AmountPayment,ReportYear)
SELECT c.id,RTRIM(d.DS1),c.AmountPayment,a.ReportYear
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles	
			AND a.rf_idSMO<>'34'															
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient						
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase	
					INNER JOIN (VALUES ('O04.0 '),('O04.1 '),('O04.2 '),('O04.3 '),('O04.4 '),('O04.5 '),('O04.6 '),('O04.7 '),('O04.8 '),('O04.9 '),
									   ('O05.0 '),('O05.1 '),('O05.2 '),('O05.3 '),('O05.4 '),('O05.5 '),('O05.6 '),('O05.7 '),('O05.8 '),('O05.9 '),
										('O06.0 '),('O06.1 '),('O06.2 '),('O06.3 '),('O06.4 '),('O06.5 '),('O06.6 '),('O06.7 '),('O06.8 '),('O06.9 '))v(DS) ON
			d.DS1=v.DS							
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>0 AND a.ReportMonth<=12 AND a.ReportYear>=@reportYear AND a.ReportYear<=@reportNextYear


UPDATE p SET p.AmountRPD=AmountPaymentAccept
FROM #tPeople p INNER JOIN (SELECT rf_idCase,SUM(AmountPaymentAccept) AS AmountPaymentAccept 
							FROM [SRVSQL1-ST2].AccountOMSReports.dbo.t_PaidCase a 
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay
							GROUP BY rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase	

SELECT t.DS, COUNT(CountCase2013) AS Case2013,CAST(SUM(AmountRPDCase2013) AS MONEY) Amount2013, COUNT(CountCase2014) AS Case2014
		, CAST(SUM(AmountRPDCase2014) AS MONEY) AS Amount2014
FROM (
		SELECT LEFT(DS1,4) AS DS,(CASE WHEN ReportYear=@reportYear THEN rf_idCase ELSE null END) AS CountCase2013
				,(CASE WHEN ReportYear=@reportYear THEN AmountRPD ELSE 0 END) AS AmountRPDCase2013
				,(CASE WHEN ReportYear=@reportNextYear THEN rf_idCase ELSE null END) AS CountCase2014
				,(CASE WHEN ReportYear=@reportNextYear THEN AmountRPD ELSE 0 END) AS AmountRPDCase2014
		from #tPeople 	
		WHERE ISNULL(AmountRPD,0)>0		
	) t
GROUP BY t.DS	
go
DROP TABLE #tPeople
	