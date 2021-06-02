USE AccountOMS
GO
SET LANGUAGE russian
declare @year SMALLINT=2018,
		@unitCode TINYINT=29,
		@dateBeginReg DATETIME='20180101',
		@dateEndReg DATETIME=GETDATE(),
		@quater TINYINT=1

CREATE TABLE #plan1(
					CodeM varchar(6),
					UnitCode int,
					Vm DECIMAL(11,2) NOT NULL DEFAULT(0.0),
					Spred decimal(11,2) NOT NULL DEFAULT(0.0),
					SumPlan DECIMAL(15,2) NOT NULL DEFAULT(0.0),
					SumSpred DECIMAL(15,2) NOT NULL DEFAULT(0.0)
					)
--план заказов расчитывается по новому с 2012-02-24. В качестве отчетного месяца берем данные за квартал 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin TINYINT
		
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then 'первый квартал'
								when QuarterID=2 then 'второй квартал' 
								when QuarterID=3 then 'третий квартал' else 'четвертый квартал' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)

/*у нас всегда начальный месяц будит 1*/				
select @monthMin=1,@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.QuarterID=@quater	
--------------------------------------------------------------------------------------------------------------------------------
;WITH ctePlan
AS(
select left(mo.tfomsCode,6) AS CodeM ,pu.unitCode
		,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm
		--,sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
		,0 AS V
from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
			py.rf_MOId=mo.MOId and
			py.[year]=@year
				inner join oms_NSI.dbo.tPlan pl on
			py.PlanYearId=pl.rf_PlanYearId and 
			pl.flag='A'
				inner join oms_NSI.dbo.tPlanUnit pu on
			pl.rf_PlanUnitId=pu.PlanUnitId
				left join oms_NSI.dbo.tPlanCorrection pc on
			pl.PlanId=pc.rf_PlanId and pc.flag='A'
			and pc.rf_MonthId>=@monthMin and pc.rf_MonthId<=@monthMax 
WHERE pu.unitCode=@unitCode
group by mo.tfomsCode,pu.unitCode
UNION ALL 
select DISTINCT left(mo.tfomsCode,6) ,pu.unitCode,0,pl.rate as V
from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
			py.rf_MOId=mo.MOId and
			py.[year]=@year
				inner join oms_NSI.dbo.tPlan pl on
			py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
				inner join oms_NSI.dbo.tPlanUnit pu on
			pl.rf_PlanUnitId=pu.PlanUnitId
				inner join @t t on
			pl.rf_QuarterId=t.QuarterID				
where t.QuarterID<=@quater AND pu.unitCode=@unitCode
)
insert #plan1(CodeM,UnitCode,Vm)	   /*Vt=0 и O=0*/
SELECT  CodeM, unitCode, SUM(Vkm)+SUM(V)/*,SUM(Vdm)*/ FROM ctePlan GROUP BY CodeM, UnitCode


--SELECT *
--FROM #plan1 WHERE Vm+Vdm>0 
--ORDER BY CodeM

SELECT c.CodeM,rf_idCase,Quantity,UnitCode,AmountPayment
INTO #tmpCases
FROM dbo.t_CaseFinancePlan c 
WHERE c.DateRegistration>=@dateBeginReg AND c.DateRegistration<=@dateEndReg AND c.reportMonth>=1 AND c.reportMonth<=@monthMax AND c.ReportYear=@year AND UnitCode=@unitCode

UPDATE c SET c.AmountPayment=c.AmountPayment-p.AmountDeduction
from #tmpCases c INNER JOIN ( SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c																						
								WHERE c.DateRegistration>=@dateBeginReg AND c.DateRegistration<=@dateEndReg
								GROUP BY c.rf_idCase
							) p ON
			c.rf_idCase=p.rf_idCase   

INSERT #plan1( CodeM ,UnitCode ,Spred ,SumSpred)
SELECT CodeM,UnitCode,SUM(Quantity)  AS Quantity , SUM(CASE WHEN AmountPayment>0 THEN AmountPayment ELSE 0.0 end) AS AmountPayment FROM #tmpCases GROUP BY CodeM,UnitCode 

INSERT #plan1( CodeM ,UnitCode ,SumPlan)
SELECT CodeM,UnitCode,SUM(SumPlan) FROM oms_nsi.dbo.vw_sprFinanceInfoByQuater WHERE Quater<=@quater AND PlanYear=@year AND UnitCode=@unitCode GROUP BY CodeM,UnitCode

SELECT l.CodeM, NAMES AS LPU,SUM(Vm) AS Vm, SUM(Spred) AS spred, SUM(Vm) -SUM(Spred) AS diffPlan
		,CAST(SUM(Spred) AS DECIMAL(15,2))/CASE WHEN SUM(Vm)=0 THEN 1 ELSE CAST(SUM(Vm) AS DECIMAL(15,2)) END AS PercentPlan,
		SUM(SumPlan) AS sumPlan, SUM(SumSpred) AS sumSpred, SUM(SumPlan)-SUM(SumSpred) AS diffSum
		,CAST(SUM(SumSpred) AS DECIMAL(15,2))/CASE WHEN SUM(SumPlan)=0 THEN 1 ELSE CAST(SUM(SumPlan) AS DECIMAL(15,2)) END AS PercentSumPlan
FROM #plan1 p INNER JOIN dbo.vw_sprT001 l ON
		p.CodeM=l.CodeM
GROUP BY l.CodeM, NAMES 
ORDER BY l.CodeM
go
DROP TABLE #plan1
DROP TABLE #tmpCases
