USE AccountOMS
go
SELECT	c.id rf_idCase, c.AmountPayment AmPay,ra.ReportYear , psmo.ENP, rp.[BirthDay],
c.AmountPayment AmPayAcc, ra.Letter, 0 sgn1, 0 sgn2, 0 sgn3, 0 sgn4, 0 sgn5,0 sgnany
		into #t
FROM    [dbo].[t_Case] c
		INNER JOIN [dbo].[t_RecordCasePatient] rcp on rcp.id = c.rf_idRecordCasePatient
		INNER JOIN [dbo].[t_RegistersAccounts] ra on ra.id = rcp.rf_idRegistersAccounts
		INNER JOIN [dbo].[t_File] f on f.id = ra.rf_idFiles 
		INNER JOIN [dbo].[t_PatientSMO] psmo on psmo.rf_idRecordCasePatient=c.rf_idRecordCasePatient
		INNER JOIN [dbo].[t_RegisterPatient] rp ON rp.rf_idRecordCase = rcp.id
WHERE ra.ReportYear = 2020 and ra.ReportMonth BETWEEN 1 AND 12 and f.DateRegistration <= '20210118' AND ra.Letter in ('F','D','U','O','R') and rp.Sex = 'Æ'	AND c.rf_idV006 = 3 
group by c.id,c.AmountPayment,ra.ReportYear,psmo.ENP, rp.[BirthDay],ra.rf_idSMO, ra.Letter

select ReportYear,count(distinct ENP) from #t 
where Letter in ('D','U')
group by ReportYear

update t set sgn1=1
from #t t
inner join [dbo].[t_Meduslugi] m on m.rf_idCase=t.rf_idCase
where mu in ('4.20.1','4.20.2','4.20.701') and isNeedUsl=0

update t set sgn2=1
from #t t
inner join [dbo].[t_Meduslugi] m on m.rf_idCase=t.rf_idCase
where mu in ('2.3.3','2.3.4','2.3.5','2.3.7','2.90.2','2.90.3') and isNeedUsl=0

update t set sgn3=1
from #t t
inner join [dbo].[t_Meduslugi] m on m.rf_idCase=t.rf_idCase
where mu in ('7.57.3','7.57.703') and isNeedUsl=0

update t set sgn4=1
from #t t
inner join [dbo].[t_Meduslugi] m on m.rf_idCase=t.rf_idCase
where mu in ('4.8.4','4.8.704') and isNeedUsl=0

update t set sgn5=1
from #t t
inner join [dbo].[t_Meduslugi] m on m.rf_idCase=t.rf_idCase
where mu ='10.3.13' and isNeedUsl=0

update #t set sgnany=1
where sgn1+sgn2+sgn3+sgn4+sgn5>0
---------------------------------------------------------------------------------------------------------------------
UPDATE c1 SET c1.AmPayAcc=c1.AmPayAcc-isnull(p.AmountDeduction,0)
FROM #t c1 INNER JOIN 
(       SELECT rf_idCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
        FROM dbo.[t_PaymentAcceptedCase2]
        WHERE DateRegistration <= '20200617 23:59:59'
        GROUP BY rf_idCase) p ON c1.rf_idCase=p.rf_idCase
where ReportYear=2020

delete from #t
where (AmPayAcc<=0 and AmPay>0) or (AmPayAcc<0 and AmPay=0)
---------------------------------------------------------------------------------------------------------------------
select case when letter in ('D','U','F') then 'Äåâî÷êè (0-17 ëåò)' when letter in ('O','R') then 'Æåíùèíû (îò 18 ëåò)' end age, 
	COUNT (distinct case when letter='F' then ENP ELSE NULL END) col1,
	sum (case when letter='F' then AmPayAcc ELSE 0.0 end) col2,
	-----------------------------------------------------------------------------------
	COUNT (distinct case when letter in ('D','U') then ENP ELSE NULL END) col3,
	sum (case when letter in ('D','U') then AmPayAcc ELSE 0.0 END) col4,
	-----------------------------------------------------------------------------------
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgnany = 1 and ReportYear=2020 then ENP ELSE null end) col5,
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgn1 = 1 and ReportYear=2020 then ENP ELSE null end) col5_1,
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgn2 = 1 and ReportYear=2020 then ENP ELSE null end) col5_2,
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgn3 = 1 and ReportYear=2020 then ENP ELSE null end) col5_3,
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgn4 = 1 and ReportYear=2020 then ENP ELSE null end) col5_4,
	count (distinct case when letter= 'O' and di.TypeDisp in ('ÄÂ1','ÄÂ3','ÄÂ4') and sgn5 = 1 and ReportYear=2020 then ENP ELSE null end) col5_5
from #t t left join dbo.t_DispInfo di on 
			di.rf_idCase=t.rf_idCase
group by case when letter in ('D','U','F') then 'Äåâî÷êè (0-17 ëåò)' when letter in ('O','R') then 'Æåíùèíû (îò 18 ëåò)' end

go
drop table #t


