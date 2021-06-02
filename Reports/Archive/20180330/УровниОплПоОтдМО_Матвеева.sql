USE AccountOMSReports
declare
@p_StartRegistrationDate nvarchar(8) = '20180101',
@p_EndRegistrationDate nvarchar(8) = '20180404',
@p_StartReportMonth int = 1,
@p_StartReportYear int = 2018,
@p_EndReportMonth int = 3,
@p_EndReportYear int = 2018,
@p_EndRAKDate nvarchar(8) = '20180404',
@p_MOCode int =-1


select c.id,f.CodeM, mo.NAMES,mes.MES,csg.[name],c.AmountPayment AmPay, CAST(0 as decimal(15,2)) AmPayAcc, 0 as quan,mo.[MOId], c.rf_idDepartmentMO, l1.[rf_LevelId] depLvl, l2.[rf_LevelId] moLvl
into #Result
FROM [dbo].[t_Case] c
INNER JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = c.rf_idRecordCasePatient
INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
inner join [dbo].[t_MES] mes on mes.rf_idCase = c.id
inner join [dbo].[vw_CSG] csg on csg.code=mes.mes-- and csg.[dateBeg]<=c.DateEnd and csg.dateEnd>=c.DateEnd
inner join [dbo].[vw_sprT001] mo on mo.[CodeM]=f.codeM
left join [oms_NSI].[dbo].[tMOLevel] l1 on l1.[rf_MODeptId]=c.[rf_idDepartmentMO] and l1.[rf_MSConditionId]=1 and c.DateEnd between l1.[dateBeg] and l1.[dateEnd]
left join [oms_NSI].[dbo].[tMOLevel] l2 on l2.[rf_MOId]=mo.[MOId] and l2.[rf_MSConditionId]=1 and c.DateEnd between l2.[dateBeg] and l2.[dateEnd] and c.[rf_idDepartmentMO] is null
where
ra.ReportYearMonth >= (CONVERT([int],CONVERT([char](4),@p_StartReportYear,0)+right('0'+CONVERT([varchar](2),@p_StartReportMonth,0),(2)),0)) 
and ra.ReportYearMonth <= (CONVERT([int],CONVERT([char](4),@p_EndReportYear,0)+right('0'+CONVERT([varchar](2),@p_EndReportMonth,0),(2)),0)) 
and f.DateRegistration>=@p_StartRegistrationDate and f.DateRegistration<=@p_EndRegistrationDate+ ' 23:59:59'
and ra.rf_idSMO<>34
and f.CodeM = case when @p_MOCode=-1 then f.CodeM else @p_MOCode  end
and c.rf_idV006=1 and c.rf_idV008=31 and c.rf_idV010=33 
--and c.id=82951414


--------------------------------------------------------------------RAK-------------------------------------------------------------------
UPDATE c1 SET c1.AmPayAcc=c1.AmPay-ISNULL(p.AmountDeduction,0)
FROM #Result c1 left JOIN (
       SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
       FROM dbo.t_PaymentAcceptedCase 
       WHERE DateRegistration>=@p_StartRegistrationDate AND DateRegistration<=@p_EndRAKDate+' 23:59:59'     
       GROUP BY rf_idCase
        ) p ON
    c1.id=p.rf_idCase     
    
delete from #Result
where (AmPayAcc<=0 and AmPay>0) or (AmPayAcc<0 and AmPay=0)
------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------лс-------------------------------------------------------------------
update #Result set quan=c.Quan
from #Result r
inner join (select r.id,sum(m.Quantity) Quan
from #Result r
inner join dbo.t_Meduslugi m on r.id=m.rf_idCase and m.MUGroupCode=1 and m.MUUnGroupCode=11 and m.MUCode in (1,2)
group by r.id
) c on c.id=r.id
------------------------------------------------------------------------------------------------------------------------------------------
select r.CodeM,r.NAMES,l.[levelPay],r.MES,r.name,count(r.id) AS CountID,sum(quan) Quantity,CAST(sum(AmPayAcc) AS MONEY) AS 
 from #Result r
inner join [oms_NSI].[dbo].[sprLevel] l on l.[LevelId]=isnull(r.depLvl, r.moLvl)
group by r.CodeM,r.NAMES,l.[levelPay],r.MES,r.name
ORDER BY CodeM, levelPay


--select * from #Result
--where CodeM=101001 and MES='1069.0' and depLvl=10
go
drop table #Result