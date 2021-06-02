USE AccountOMS
GO
DECLARE @dateStart DATETIME='20180101',
		@dateEnd DATETIME='20190126',
		@dateEndPay DATETIME='20190226',
		@reportYear SMALLINT=2018,
		@reportMonth TINYINT=12

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	rf_idV006 TINYINT,
	ENP VARCHAR(16),
	MES VARCHAR(15),
	DateBegin DATE,
	DateEnd DATE
)		

INSERT #tCases( rf_idCase ,rf_idCompletedCase ,CodeM ,AmountPayment ,AmountPaymentAcc ,rf_idV006 ,ENP,MES, DateBegin,DateEnd)
SELECT distinct c.id, r.id,f.CodeM,c.AmountPayment,c.AmountPayment,c.rf_idV006,p.ENP,m.MES, c.DateBegin,c.DateEnd
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient	
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
					INNER JOIN dbo.vw_sprCSG cc ON
			m.MES=cc.code                  
					INNER JOIN dbo.t_PatientSMO p ON
			r.id=p.rf_idRecordCasePatient											                 
					INNER JOIN PeopleAttach.dbo.fss_v fss ON
			p.ENP=fss.enp                  
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth <=@reportMonth AND a.ReportYear=@reportYear
		AND c.rf_idV006<3 AND c.rf_idV002=158

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay	 AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase
/*
SELECT ENP FROM #tCases WHERE AmountPaymentAcc>0 GROUP BY ENP HAVING COUNT(*)>1

SELECT * FROM #tCases WHERE ENP IN('3451840891000280','3452140834000300','3454130823000278','3455040837000330','3457630882000348','3458240890000212','3472450886000173','3488589724000374',
'3489489787000032','3490489774000562','3490489775000041','3490689785000093','3491489746000152','3492489774000016','3492489780000026','3495389724000099',
'3495599791000182','3496989730000576','3497889775000292','3498489738000106')
ORDER BY ENP,DateBegin
*/

DROP TABLE PeopleAttach.dbo.fss_MedPomosh
/*	 сложение полей
;WITH cte
AS(
SELECT ENP,rf_idV006,MES=REPLACE((SELECT RTRIM(mes) AS 'data()' FROM #tCases WHERE enp=c.ENP AND rf_idV006=c.rf_idV006 for xml path('')),' ',','),
		2 AS Col12,SUM(AmountPaymentAcc) AS AmmountPaymentAcc
FROM #tCases c
GROUP BY ENP, rf_idV006
)
SELECT ENP,CASE WHEN rf_idV006=1 THEN MES ELSE NULL END AS Stacinar,CASE WHEN rf_idV006=2 THEN MES ELSE NULL END AS DnStacinar,
		2 AS Col12,SUM(AmmountPaymentAcc) AS AmmountPayment
FROM cte
GROUP BY ENP,CASE WHEN rf_idV006=1 THEN MES ELSE NULL END ,CASE WHEN rf_idV006=2 THEN MES ELSE NULL END
ORDER BY ENP
*/
SELECT ENP,CASE WHEN rf_idV006=1 THEN MES ELSE NULL END AS Stacinar,CASE WHEN rf_idV006=2 THEN MES ELSE NULL END AS DnStacinar,
		2 AS Col12,SUM(AmountPaymentAcc) AS AmmountPayment
INTO PeopleAttach.dbo.fss_MedPomosh
FROM #tCases
GROUP BY ENP,CASE WHEN rf_idV006=1 THEN MES ELSE NULL END ,CASE WHEN rf_idV006=2 THEN MES ELSE NULL END

go
DROP TABLE #tCases