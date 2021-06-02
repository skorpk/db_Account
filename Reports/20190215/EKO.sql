USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME='20190215',
		@dateEndPay DATETIME='20190215',
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=1

CREATE TABLE #tCases
(
	rf_idCase BIGINT,
	rf_idCompletedCase INT,
	CodeM CHAR(6),
	AmountPayment DECIMAL(15,2),
	AmountPaymentAcc DECIMAL(15,2),
	TypeStep tinyint
)		

INSERT #tCases( rf_idCase, CodeM,AmountPayment,rf_idCompletedCase,AmountPaymentAcc )
SELECT c.id, f.CodeM, c.AmountPayment,rf_idRecordCasePatient,c.AmountPayment
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO<>'34'
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase		
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd  AND a.ReportMonth =@reportMonth AND a.ReportYear=@reportYear
		AND m.MES='ds02.005'


UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

UPDATE c SET c.TypeStep=3
FROM #tCases c INNER JOIN dbo.t_Meduslugi m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='A11.20.017' and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery<>'A11.20.017')

;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN('A11.20.017','A11.20.028','A11.20.031') 
			and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN('A11.20.017','A11.20.028','A11.20.031'))
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=3
	)
UPDATE c set c.TypeStep=4
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase

;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN ('A11.20.017','A11.20.025.001') 
			--and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN ('A11.20.017','A11.20.025.001'))
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=2
	)
UPDATE c set c.TypeStep=5
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase

;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN ('A11.20.017','A11.20.025.001','A11.20.036') 
			--and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.036'))
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=3
	)
UPDATE c set c.TypeStep=6
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase

;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN ('A11.20.017','A11.20.025.001','A11.20.028') 
			--and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.036'))
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=3
	)
UPDATE c set c.TypeStep=7
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase

;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN ('A11.20.017','A11.20.031') 
			and NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiSurgery WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN ('A11.20.017','A11.20.031') )
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=2
	)
UPDATE c set c.TypeStep=8
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase


;WITH cte 
AS(
	SELECT m.rf_idCase
	FROM #tCases c INNER JOIN dbo.vw_MeduslugiSurgery m ON
			c.rf_idCase=m.rf_idCase
	WHERE m.MUSurgery IN ('A11.20.017','A11.20.030.001') 
			--and NOT EXISTS(SELECT 1 FROM dbo.vw_MeduslugiSurgery WHERE rf_idCase=c.rf_idCase AND MUSurgery NOT IN ('A11.20.017','A11.20.031') )
	GROUP BY m.rf_idCase
	HAVING COUNT(*)=2
	)
UPDATE c set c.TypeStep=9
from cte cc INNER JOIN #tCases c ON
		cc.rf_idCase=c.rf_idCase

SELECT l.CodeM,l.NAMES
		,COUNT(CASE WHEN TypeStep=3 THEN rf_idCase ELSE NULL END ) AS Col3
		,COUNT(CASE WHEN TypeStep=4 THEN rf_idCase ELSE NULL END ) AS Col4
		,COUNT(CASE WHEN TypeStep=5 THEN rf_idCase ELSE NULL END ) AS Col5
		,COUNT(CASE WHEN TypeStep=6 THEN rf_idCase ELSE NULL END ) AS Col6
		,COUNT(CASE WHEN TypeStep=7 THEN rf_idCase ELSE NULL END ) AS Col7
		,COUNT(CASE WHEN TypeStep=8 THEN rf_idCase ELSE NULL END ) AS Col8
		,COUNT(CASE WHEN TypeStep=9 THEN rf_idCase ELSE NULL END ) AS Col9
		,COUNT(CASE WHEN TypeStep IS null THEN rf_idCase ELSE NULL END ) AS Col10
		,COUNT(rf_idCase) AS Col11
		------------------------------------------------------------------------
		,SUM(CASE WHEN TypeStep=3 THEN AmountPayment ELSE 0.0 END ) AS Col12
		,SUM(CASE WHEN TypeStep=4 THEN AmountPayment ELSE 0.0 END ) AS Col13
		,SUM(CASE WHEN TypeStep=5 THEN AmountPayment ELSE 0.0 END ) AS Col14
		,SUM(CASE WHEN TypeStep=6 THEN AmountPayment ELSE 0.0 END ) AS Col15
		,SUM(CASE WHEN TypeStep=7 THEN AmountPayment ELSE 0.0 END ) AS Col16
		,SUM(CASE WHEN TypeStep=8 THEN AmountPayment ELSE 0.0 END ) AS Col17
		,SUM(CASE WHEN TypeStep=9 THEN AmountPayment ELSE 0.0 END ) AS Col18
		,SUM(CASE WHEN TypeStep IS null THEN AmountPayment ELSE 0.0 END ) AS Col19
		,SUM(AmountPayment) AS Col20
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAcc>0
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM

GO
DROP TABLE #tCases