use accountomsreports
go
SET STATISTICS TIME ON
GO
          SELECT c.id, c.[GUID_Case],
          p.Fam, p.Im, isnull(p.Ot,'') as Ot, r.AttachLPU, p.BirthDay,'' as AttachMoName,
          a.[PrefixNumberRegister], a.[Account], c.[idRecordCase], a.[DateRegister], v009.[Name],
          cast (c.[DateBegin] as varchar(10)) as [DateBegin], cast (c.[DateEnd] as varchar(10)) as [DateEnd], 
          c.AmountPayment, f.CodeM, t001.[NameS] AS MOName, cast(0 as bigint) as PeopleID, cast (0 as decimal(6,2)) as AmountPaymentAccept,
          rpa.[Fam] as FamAtt, rpa.[Im] as ImAtt,isnull(rpa.[Ot],'') as OtAtt
          into #tCase          
          FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles                         
                                INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts
                                INNER JOIN [srvsql2-st1].AccountOMS.dbo.t_RegisterPatient p ON f.id=p.rf_idFiles AND r.id=p.rf_idRecordCase
                                INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient
                                INNER JOIN dbo.t_MES mes ON c.id=mes.rf_idCase
                                INNER JOIN dbo.vw_sprMUCompletedCase mu ON mes.MES=mu.MU
                                INNER JOIN [oms_NSI].[dbo].[vw_sprT001] t001 on t001.[CodeM] = f.CodeM
                                INNER JOIN OMS_NSI.dbo.sprV009 v009 on v009.id=c.rf_idv009
                                left JOIN [srvsql2-st1].[AccountOMS].[dbo].[t_RegisterPatientAttendant] rpa on rpa.[rf_idRegisterPatient]=p.id
		  WHERE a.Letter='O' AND mu.MUGroupCode=70 AND MUUnGroupCode=3 and
                    f.DateRegistration >='20140101' and f.DateRegistration<'20140912' and a.ReportYear = 2014 and a.PrefixNumberRegister<>34
CREATE NONCLUSTERED INDEX IX_1
ON [dbo].[#tCase] ([AmountPaymentAccept])                        

UPDATE c SET c.PeopleID=p.IDPeople
FROM #tCase c INNER JOIN dbo.t_People_Case p ON
                    c.id=p.rf_idCase
-----------------------------------RAK-------------------------------------------------------------------
UPDATE c1 SET c1.AmountPaymentAccept=c1.AmountPayment-p.AmountDeduction
FROM #tCase c1 INNER JOIN (
        SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
        FROM dbo.t_PaymentAcceptedCase 
        WHERE DateRegistration>='20140101' AND DateRegistration<='20140912'  AND Letter LIKE '%O'        
        GROUP BY rf_idCase
                                ) p ON
                    c1.id=p.rf_idCase     
                    
DELETE FROM #tCase
WHERE (AmountPaymentAccept is null) or (AmountPaymentAccept<=0)

select PeopleID,c.[Account],c.CodeM          
from #tCase c inner join [oms_NSI].[dbo].[tSMO] tsmo on tsmo.smocod=c.[PrefixNumberRegister]        
where PeopleID in
(
select PeopleID from #tCase
group by PeopleID
having count(PeopleID)>1
)
GROUP BY PeopleID,c.[Account],c.CodeM
HAVING COUNT(*)>1

SELECT * FROM #tCase WHERE PeopleID IN(1225293,537775)
GO
SET STATISTICS TIME OFF
GO
--clear
DROP TABLE #tCase