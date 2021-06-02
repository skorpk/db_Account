use AccountOMS

declare @repYear int = 2019
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200811'
select	c.id rf_idCase,psmo.ENP, c.AmountPayment AmPay,c.AmountPayment AmPayAcc
into #t1

FROM    [dbo].[t_Case] c
		INNER JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = c.rf_idRecordCasePatient
		INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
		INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
		INNER JOIN [dbo].[t_PatientSMO] psmo on psmo.rf_idRecordCasePatient=c.rf_idRecordCasePatient
		left join dbo.vw_Diagnosis d on d.rf_idCase=c.id
		
WHERE ra.ReportYear=@repYear and c.rf_idV006=1 and d.DS1 like 'I2[1-2]%' --AND ra.ReportMonth<7

select	c.id rf_idCase,psmo.ENP, c.AmountPayment AmPay,c.AmountPayment AmPayAcc
into #t2

FROM    [dbo].[t_Case] c
		INNER JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = c.rf_idRecordCasePatient
		INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
		INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
		INNER JOIN [dbo].[t_PatientSMO] psmo on psmo.rf_idRecordCasePatient=c.rf_idRecordCasePatient
		left join dbo.vw_Diagnosis d on d.rf_idCase=c.id
		
WHERE ra.ReportYear=@repYear and c.rf_idV006=1 and d.DS1 like 'I6[0-4]%' --AND ra.ReportMonth<7

---------------------------------------------------------------------------------------------------------------------
UPDATE c1 SET c1.AmPayAcc=c1.AmPayAcc-isnull(p.AmountDeduction,0)
FROM #t1 c1 INNER JOIN 
(       SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
        FROM dbo.[t_PaymentAcceptedCase2]
		where [TypeCheckup]=1 AND DateRegistration>@dateStartReg AND DateRegistration<@dateEndReg
        GROUP BY rf_idCase) p ON c1.rf_idCase=p.rf_idCase

UPDATE c1 SET c1.AmPayAcc=c1.AmPayAcc-isnull(p.AmountDeduction,0)
FROM #t2 c1 INNER JOIN 
(       SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
        FROM dbo.[t_PaymentAcceptedCase2]
		where [TypeCheckup]=1 AND DateRegistration>@dateStartReg AND DateRegistration<@dateEndReg
        GROUP BY rf_idCase) p ON c1.rf_idCase=p.rf_idCase


delete from #t1
where (AmPayAcc<=0 and AmPay>0) or (AmPayAcc<0 and AmPay=0)

delete from #t2
where (AmPayAcc<=0 and AmPay>0) or (AmPayAcc<0 and AmPay=0)

ALTER TABLE #t1 ADD DN TINYINT 

UPDATE t SET DN=1
FROM #t1 t INNER JOIN dbo.DNPersons_20200827 d ON
		t.enp=d.ENP
WHERE d.[YEAR]=@repYear

ALTER TABLE #t2 ADD DN TINYINT 

UPDATE t SET DN=1
FROM #t2 t INNER JOIN dbo.DNPersons_20200827 d ON
		t.enp=d.ENP
WHERE d.[YEAR]=@repYear
---------------------------------------------------------------------------------------------------------------------
select t.ENP, count(t.rf_idCase),count(t.rf_idCase)-1, CASE WHEN DN=1 THEN 'Да' ELSE 'Нет' end
from #t1 t 
group by t.ENP, CASE WHEN DN=1 THEN 'Да' ELSE 'Нет' end

select t.ENP, count(t.rf_idCase),count(t.rf_idCase)-1, COUNT(DN), CASE WHEN DN=1 THEN 'Да' ELSE 'Нет' end
from #t2 t
group by t.ENP, CASE WHEN DN=1 THEN 'Да' ELSE 'Нет' end
go
drop table #t1 
go
DROP table #t2 

