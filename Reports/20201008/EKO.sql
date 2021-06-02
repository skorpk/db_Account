USE AccountOMS
GO
DECLARE @p_StartRegistrationDate nvarchar(8)/* = '20190101'*/,
@p_EndRegistrationDate nvarchar(8)/* = '20190216'*/,
@p_StartReportMonth int/* = 1*/,
@p_StartReportYear int/* = 2019*/,
@p_EndReportMonth int/* = 12*/,
@p_EndReportYear int/* = 2019*/,
@p_EndRAKDate nvarchar(8)/* = '20190216'*/,
@p_InsPlace int/* = 0 */,
@p_MOCode int 

select  @p_StartRegistrationDate = N'20200101', -- nvarchar(8)
     @p_EndRegistrationDate = N'20201009',   -- nvarchar(8)
     @p_StartReportMonth = 1,        -- int
     @p_StartReportYear = 2020,         -- int
     @p_EndReportMonth = 9,          -- int
     @p_EndReportYear = 2020,           -- int
     @p_EndRAKDate = N'20201009',            -- nvarchar(8)
     @p_InsPlace = 0,                -- int
     @p_MOCode = -1

DECLARE @dateStart DATETIME,
		@dateEnd DATETIME,
		@dateEndPay DATETIME,
		@startPeriod INT=CONVERT([int],CONVERT([char](4),@p_StartReportYear,0)+right('0'+CONVERT([varchar](2),@p_StartReportMonth,0),(2)),0),
		@endPeriod INT=(CONVERT([int],CONVERT([char](4),@p_EndReportYear,0)+right('0'+CONVERT([varchar](2),@p_EndReportMonth,0),(2)),0)) 
		      

SELECT @dateStart=@p_StartRegistrationDate,@dateEnd=@p_EndRegistrationDate+ ' 23:59:59', @dateEndPay=@p_EndRAKDate+' 23:59:59'            


CREATE TABLE #tCases
(
	rf_idCase INT,
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
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
WHERE a.ReportYearMonth >=@startPeriod and a.ReportYearMonth <= @endPeriod
	and f.DateRegistration>=@dateStart and f.DateRegistration<=@dateEnd
	and ((a.rf_idSMO=@p_InsPlace and @p_InsPlace=34) or (@p_InsPlace<>34 and a.rf_idSMO<>34))
	and f.CodeM = case when @p_MOCode=-1 then f.CodeM else @p_MOCode  end
	and c.rf_idV006=2 and [MES]='ds02.005'
	and c.rf_idV002=137 and c.rf_idV010 in (33,43)
			

UPDATE p SET p.AmountPaymentAcc=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEndPay
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

CREATE NONCLUSTERED INDEX IX_t ON #tCases(rf_idCase) INCLUDE(TypeStep)

UPDATE c SET c.TypeStep=3
FROM #tCases c INNER JOIN dbo.t_Meduslugi  m ON
		c.rf_idCase=m.rf_idCase
WHERE m.MUSurgery='A11.20.017' and NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.rf_idCase=c.rf_idCase AND MUSurgery<>'A11.20.017')

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
------------------------------------------------------------------------------------------------------------------------	
-----------------------------------------------------------хрнцх--------------------------------------------------------



SELECT l.CodeM,l.NAMES
		,COUNT(CASE WHEN TypeStep=3 THEN rf_idCase ELSE NULL END ) AS Col3
		,COUNT(CASE WHEN TypeStep=4 THEN rf_idCase ELSE NULL END ) AS Col4
		,COUNT(CASE WHEN TypeStep=5 THEN rf_idCase ELSE NULL END ) AS Col5
		,COUNT(CASE WHEN TypeStep=6 THEN rf_idCase ELSE NULL END ) AS Col6
		,COUNT(CASE WHEN TypeStep=7 THEN rf_idCase ELSE NULL END ) AS Col7
		,COUNT(CASE WHEN TypeStep=8 THEN rf_idCase ELSE NULL END ) AS Col8
		,COUNT(CASE WHEN TypeStep=9 THEN rf_idCase ELSE NULL END ) AS Col9
		--,COUNT(CASE WHEN TypeStep IS null THEN rf_idCase ELSE NULL END ) AS Col10
		,COUNT(rf_idCase) AS Col11
		------------------------------------------------------------------------
		,SUM(CASE WHEN TypeStep=3 THEN AmountPayment ELSE 0.0 END ) AS Col12
		,SUM(CASE WHEN TypeStep=4 THEN AmountPayment ELSE 0.0 END ) AS Col13
		,SUM(CASE WHEN TypeStep=5 THEN AmountPayment ELSE 0.0 END ) AS Col14
		,SUM(CASE WHEN TypeStep=6 THEN AmountPayment ELSE 0.0 END ) AS Col15
		,SUM(CASE WHEN TypeStep=7 THEN AmountPayment ELSE 0.0 END ) AS Col16
		,SUM(CASE WHEN TypeStep=8 THEN AmountPayment ELSE 0.0 END ) AS Col17
		,SUM(CASE WHEN TypeStep=9 THEN AmountPayment ELSE 0.0 END ) AS Col18
		--,SUM(CASE WHEN TypeStep IS null THEN AmountPayment ELSE 0.0 END ) AS Col19
		,SUM(AmountPayment) AS Col20
FROM #tCases c INNER JOIN dbo.vw_sprT001 l ON
		c.CodeM=l.CodeM
WHERE c.AmountPaymentAcc>0
GROUP BY l.CodeM,l.NAMES
ORDER BY l.CodeM
go
DROP TABLE #tCases
--select * from #Result
--where codem=801934

--drop table #Result
