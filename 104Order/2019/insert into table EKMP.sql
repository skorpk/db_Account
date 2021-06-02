USE AccountOMSReports
GO
DECLARE @reportYear SMALLINT=2018,
	@reportMonth TINYINT=12,
	@dtStart DATETIME='20190123',		
	@dtEnd DATETIME='20190211'
    
insert t_OrderAdult_104_2018_EKMP (rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT     ,[Reason],[TypeExp],[IsEKMP],[DateStamp])
SELECT c.rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,c.rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT, p.Reason, 0 AS TypeExp, case when p.rf_idcase is not null then 1 else 0 end AS IsEKMP, GETDATE() as DateStamp
FROM dbo.t_OrderAdult_104_2018 c 
INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON c.rf_idV009=v.rf_idV009           
LEFT JOIN dbo.vw_PaymnetEKMP_Reason p ON c.rf_idCase=p.rf_idCase
WHERE ReportYear = @reportYear and ReportMonth = @reportMonth AND NOT EXISTS(SELECT 1 FROM t_OrderAdult_104_2018_EKMP WHERE rf_idCase=c.rf_idCase)
and isnull(p.DateRegistration,@dtStart)<@dtEnd /*условие изменено 13.09.2018, т.к. left join*/

insert t_OrderAdult_104_2018_EKMP (rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT     ,[Reason],[TypeExp],[IsEKMP],[DateStamp])
SELECT c.rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,c.rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT, p.Reason, 0 AS TypeExp, 1 AS IsEKMP, GETDATE() as DateStamp
FROM dbo.t_OrderAdult_104_2018 c 
INNER JOIN dbo.vw_PaymnetEKMP_Reason p ON 
			c.rf_idCase=p.rf_idCase
WHERE ReportYear = @reportYear and ReportMonth = @reportMonth AND NOT EXISTS(SELECT 1 FROM t_OrderAdult_104_2018_EKMP WHERE rf_idCase=c.rf_idCase)
and p.DateRegistration<@dtEnd /*условие добавлено 13.09.2018*/

-------------------------------------------Kraynov--------------------------------------------
---удаляем все данные
DELETE FROM dbo.t_OrderAdult_104_2018_EKMP_2 WHERE ReportYear = @reportYear and ReportMonth < @reportMonth

--первый пункт для всех периодов одинаковый
insert t_OrderAdult_104_2018_EKMP_2 (rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT     ,[Reason],[TypeExp],[IsEKMP],[needCreateERD],[DateStamp])
SELECT c.rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,c.rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT, p.Reason, 0 AS TypeExp, case when p.rf_idcase is not null then 1 else 0 end AS IsEKMP, 1 as [needCreateERD], GETDATE() as DateStamp
FROM dbo.t_OrderAdult_104_2018 c 
INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON c.rf_idV009=v.rf_idV009           
left JOIN dbo.vw_PaymnetEKMP_Reason p ON c.rf_idCase=p.rf_idCase
WHERE EXISTS(SELECT * FROM dbo.t_OrderAdult_104_2018_EKMP e WHERE c.rf_idCase=e.rf_idCase /*AND IsEKMP=0*/) and ReportYear = @reportYear and ReportMonth < @reportMonth
and isnull(p.DateRegistration,@dtStart)<@dtEnd /*условие добавлено 13.09.2018, до этого не было даже без isnull*/

--второй пункт выполняется только для случаев начиная с отчетного периода июнь
insert t_OrderAdult_104_2018_EKMP_2 (rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT     ,[Reason],[TypeExp],[IsEKMP],[needCreateERD],[DateStamp])
SELECT c.rf_idCase,AmountPayment,AmountDeduction,Age,DS1,ENP,c.rf_idV009,rf_idV006,rf_idV014,BirthDay,AP_Type,
								   DateBegin,DateEnd,Gosp_type,ReportMonth,ReportYear,PVT, p.Reason, 0 AS TypeExp, 1 AS IsEKMP, 1 as [needCreateERD], GETDATE() as DateStamp
FROM dbo.t_OrderAdult_104_2018 c 
inner JOIN dbo.vw_PaymnetEKMP_Reason p ON c.rf_idCase=p.rf_idCase
WHERE not EXISTS(SELECT * FROM dbo.t_OrderAdult_104_2018_EKMP e WHERE c.rf_idCase=e.rf_idCase) -- 28.08.2018
and ReportYear = @reportYear and ReportMonth < @reportMonth and ((ReportMonth >= 6 and ReportYear=2018) or ReportYear>2018)
and c.rf_idV009 not in (105,106,205,206,313,405,406,411) -- условие добавлено 15.08.2018 чтобы не попадали случаи, попавшие на 1 этапе
and p.DateRegistration<@dtEnd /*условие добавлено 13.09.2018*/
