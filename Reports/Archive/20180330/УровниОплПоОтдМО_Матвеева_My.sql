USE AccountOMS
declare
@p_StartRegistrationDate DATETIME= '20180101',
@p_EndRegistrationDate DATETIME= '20180405',
@p_StartReportMonth int = 1,
@p_StartReportYear int = 2018,
@p_EndReportMonth int = 3,
@p_EndReportYear int = 2018,
@p_EndRAKDate nvarchar(8) = '20180404',
@p_MOCode int =-1

SELECT * INTO #tLevel FROM RegisterCases.dbo.vw_sprPriceLevelMO

select c.id,f.CodeM, mes.MES,csg.name,c.AmountPayment AmPay, CAST(0 as decimal(15,2)) AmPayAcc, 0 as quan,c.rf_idDepartmentMO, t1.LevelPayType
into #Result
FROM dbo.t_Case c INNER JOIN dbo.t_RecordCasePatient rcp on 
			rcp.id = c.rf_idRecordCasePatient
				INNER JOIN dbo.t_RegistersAccounts ra on 
			ra.id = rcp.rf_idRegistersAccounts
				INNER JOIN dbo.t_File f on 
			f.id = ra.rf_idFiles 
				inner join dbo.t_MES mes on 
			mes.rf_idCase = c.id
				inner join dbo.vw_sprCSG csg on 
			csg.code=mes.mes				
				inner join #tLevel t1 on ---םו מעבטנאוע
			c.rf_idMO =t1.CodeM
			AND ISNULL(c.rf_idDepartmentMO,0)=ISNULL(t1.DeptCode,0)
			and c.rf_idV006=t1.rf_idV006
			and c.DateEnd>=t1.DateBegin
			and c.DateEnd<=t1.DateEnd
where  ra.ReportMonth<4 AND ra.ReportYear=2018 and f.DateRegistration>=@p_StartRegistrationDate and f.DateRegistration<@p_EndRegistrationDate
		and ra.rf_idSMO<>34 and c.rf_idV006=1 and c.rf_idV008=31 and c.rf_idV010=33 
--and c.id=82951414


--------------------------------------------------------------------RAK-------------------------------------------------------------------
UPDATE c1 SET c1.AmPay=c1.AmPay-p.AmountDeduction
FROM #Result c1 INNER JOIN (
							   SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction
							   FROM dbo.t_PaymentAcceptedCase2
							   WHERE DateRegistration>=@p_StartRegistrationDate AND DateRegistration<=@p_EndRAKDate+' 23:59:59'     
							   GROUP BY rf_idCase
        ) p ON
    c1.id=p.rf_idCase
------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------ÌÓ-------------------------------------------------------------------
update #Result set quan=c.Quan
from #Result r inner join (select r.id,sum(m.Quantity) Quan
						   from #Result r inner join dbo.t_Meduslugi m on 
								r.id=m.rf_idCase and m.MUGroupCode=1 and m.MUUnGroupCode=11 and m.MUCode in (1,2)
							WHERE AmPay>0
							group by r.id ) c 
				on c.id=r.id
------------------------------------------------------------------------------------------------------------------------------------------
select r.CodeM,l1.NAMES,r.LevelPayType,RTRIM(r.MES) AS MES,r.name,count(r.id) AS CountId,sum(quan) Quantity,CAST(sum(AmPay) AS MONEY) AS SumAmPayAcc 
 from #Result r INNER JOIN dbo.vw_sprT001 l1 ON
			r.CodeM=l1.CodeM
WHERE AmPay>0			 
group by r.CodeM,l1.NAMES,r.LevelPayType,r.MES,r.name
ORDER BY CodeM,r.LevelPayType
go
DROP TABLE #tLevel
DROP TABLE #Result


--DROP TABLE tmpVit