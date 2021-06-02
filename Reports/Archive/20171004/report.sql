USE AccountOMS
GO
DECLARE @reportYear SMALLINT=2016,
		@dateStart DATETIME,
		@dateEnd DATETIME='20170123 23:59:59',
		@mmBegin TINYINT=1,
		@mmEnd TINYINT=12,
		@dateEndPay DATETIME='20170301'

--DECLARE @reportYear SMALLINT=2017,
--		@dateStart DATETIME,
--		@dateEnd DATETIME='20170710 23:59:59',
--		@mmBegin TINYINT=1,
--		@mmEnd TINYINT=6,
--		@dateEndPay DATETIME='20170901'

SET @dateStart=CAST(@reportYear AS VARCHAR(4))+'0101'


CREATE TABLE #tPeople(
					  CodeM VARCHAR(6),
					  LPU VARCHAR(250),
					  rf_idCase BIGINT,					  					  
					  AmountPayment DECIMAL(11,2), 
					  rf_idSMO CHAR(5),					  
					  MEK1 DECIMAL(11,2) NOT NULL DEFAULT 0.0,
					  MEK2 DECIMAL(11,2) NOT NULL DEFAULT 0.0,
					  OrderCheckUP1 TINYINT, 
					  OrderCheckUP2 TINYINT null                    
					  )

CREATE UNIQUE NONCLUSTERED INDEX UQ_IdCase ON #tPeople(rf_idCase) WITH IGNORE_DUP_KEY

INSERT #tPeople( rf_idCase ,AmountPayment ,rf_idSMO,CodeM,LPU)
SELECT DISTINCT c.id,c.AmountPayment,a.rf_idSMO,f.CodeM,l.NAMES
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles			
			AND a.rf_idSMO<>'34'
				INNER JOIN dbo.vw_sprT001 l ON
			f.CodeM=l.CodeM
			AND l.pfa=1              
					INNER JOIN (VALUES('A')) v(letter) ON
			a.Letter=v.letter
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient					
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth>=@mmBegin AND a.ReportMonth<=@mmEnd AND a.ReportYear=@reportYear AND c.rf_idV006=3
--------------------------------------Update information about RAK---------------------------
UPDATE p SET p.MEK1=r.AmountDeduction,OrderCheckUP1=r.OrderCheckUP
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,OrderCheckUP, SUM(AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAccepted_MEK												
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	 AND OrderCheckUP=1
							GROUP BY rf_idCase,OrderCheckUP
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE p SET p.MEK2=r.AmountDeduction,OrderCheckUP2=r.OrderCheckUP
FROM #tPeople p INNER JOIN (
							SELECT rf_idCase,OrderCheckUP, SUM(AmountDeduction) AS AmountDeduction
							FROM dbo.t_PaymentAccepted_MEK												
							WHERE DateRegistration>=@dateStart AND DateRegistration<@dateEndPay	 AND OrderCheckUP=2
							GROUP BY rf_idCase,OrderCheckUP
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT * FROM #tPeople WHERE CodeM='165531' AND OrderCheckUP1=1 AND MEK1>0

SELECT CodeM,LPU,COUNT(rf_idCase) AS AllCount, CAST(SUM(AmountPayment) AS MONEY) AS AllAmount
		,COUNT(CASE WHEN OrderCheckUP1=1 THEN rf_idCase ELSE NULL END) AS CountCaseFirst
		,CAST(SUM(CASE WHEN OrderCheckUP1=1 THEN MEK1 ELSE 0.0 END) AS MONEY) AS AmountCaseFirst
		,COUNT(CASE WHEN OrderCheckUP1=1 AND MEK1>0 THEN rf_idCase ELSE NULL END) AS CountSnatoCaseFirst
		--------------------------------------------------------------
		,COUNT(CASE WHEN OrderCheckUP2=2 THEN rf_idCase ELSE NULL END) AS CountCaseSecond
		,CAST(SUM(CASE WHEN OrderCheckUP2=2 THEN MEK2 ELSE 0.0 END) AS MONEY) AS AmountCaseSecond
		,COUNT(CASE WHEN OrderCheckUP2=2 AND MEK2>0 THEN rf_idCase ELSE NULL END) AS CountSnatoCaseSecond
FROM #tPeople
GROUP BY CodeM,LPU
ORDER BY CodeM
go

DROP TABLE #tPeople

