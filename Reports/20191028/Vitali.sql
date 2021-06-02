USE [AccountOMS]
go

select c.id,m.MU,cc.AmountPayment AmPay, CAST(0 as decimal(15,2)) AmPayAcc, cast(sum(m.Quantity) as int) Quan, f.CodeM,psmo.ENP, c.DateBegin,c.DateEnd, psmo.rf_idSMO, ra.Account
, 0 as sgn, cast (null as date) DateBeginSt, cast (null as date) DateEndSt, cast (null as varchar(6)) CodeMSt,cast (null as varchar(15)) AccountSt,c.rf_idDirectMO
into #Result
FROM [dbo].[t_Meduslugi] m
inner JOIN [dbo].[t_Case] c on m.[rf_idCase]=c.[id]
INNER JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = c.rf_idRecordCasePatient
INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
INNER JOIN [dbo].[t_PatientSMO] psmo on psmo.rf_idRecordCasePatient=rcp.id
INNER JOIN dbo.t_CompletedCase cc ON rcp.id=cc.rf_idRecordCasePatient
where
ra.ReportYear=2019 and ra.ReportMonth between 1 and 8
and f.DateRegistration>='20190101' and f.DateRegistration<='20190910 23:59:59'
and ra.rf_idSMO<>34
and c.rf_idV006=3
and f.CodeM in (125901,805965)
and m.Price>0
and m.MUGroupCode = 4 and m.MUUnGroupCode in (12,13,15,16,17)
--and psmo.Enp='3450010877000115'
group by c.id,m.MU,cc.AmountPayment, f.CodeM,psmo.ENP, c.DateBegin,c.DateEnd, psmo.rf_idSMO, ra.Account,c.rf_idDirectMO
----------------------------------------------------------------------------------------------------------------------
--SELECT * FROM #Result WHERE rf_idDirectMO IS NOT null
---------------------------------------------------------RAK----------------------------------------------------------
UPDATE c1 SET c1.AmPayAcc=c1.AmPay-ISNULL(p.AmountDeduction,0)
FROM #Result c1 left JOIN (
       SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
       FROM dbo.t_PaymentAcceptedCase2 
       WHERE DateRegistration>='20190101' AND DateRegistration<='20190910 23:59:59'   
       GROUP BY rf_idCase
        ) p ON
    c1.id=p.rf_idCase     
    
delete from #Result
where (AmPayAcc<=0 and AmPay>0) or (AmPayAcc<0 and AmPay=0)
----------------------------------------------------------------------------------------------------------------------
update r set sgn=1
from #Result r
inner JOIN [dbo].[t_PatientSMO] psmo on psmo.ENP=r.ENP
inner JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = psmo.rf_idRecordCasePatient
INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
inner join [dbo].[t_Case] c on c.rf_idRecordCasePatient=rcp.id and c.rf_idV006=1
INNER JOIN dbo.t_CompletedCase cc ON rcp.id=cc.rf_idRecordCasePatient
INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
where ((r.DateEnd>=cc.DateBegin and r.DateEnd<=cc.DateEnd) or (r.DateBegin>=cc.DateBegin and r.DateBegin<=cc.DateEnd)) and r.ENP=psmo.ENP

delete from #Result where sgn=0
--------------------------------------------------------ÈÒÎÃÈ---------------------------------------------------------
SELECT DISTINCT r.CodeM,r.MU, mu.MUName, r.DateBegin, r.DateEnd, r.Account,r.ENP,c.DateBegin,c.DateEnd,f.CodeM+' — '+mo.NAMES,ra.Account,r.rf_idSMO
		,r.rf_idDirectMO+' - '+l.NAMES AS LPU_Direction
from #Result r
inner JOIN [dbo].[t_PatientSMO] psmo on psmo.ENP=r.ENP
inner JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = psmo.rf_idRecordCasePatient
INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
inner join [dbo].[t_Case] c on c.rf_idRecordCasePatient=rcp.id and c.rf_idV006=1
INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
INNER JOIN dbo.t_CompletedCase cc ON rcp.id=cc.rf_idRecordCasePatient
inner join [dbo].[vw_sprT001] mo on mo.CodeM=f.CodeM
			left JOIN dbo.vw_sprT001 l ON
		r.rf_idDirectMO=l.mcod
left join OMS_NSI.[dbo].[vw_sprMUAllOnce] mu on r.mu=mu.MU
where f.CodeM='102604' AND ((r.DateEnd>=cc.DateBegin and r.DateEnd<=cc.DateEnd) or (r.DateBegin>=cc.DateBegin and r.DateBegin<=cc.DateEnd)) and r.ENP=psmo.ENP
go

drop table #Result