USE [AccountOMSReports]
GO
/****** Object:  StoredProcedure [dbo].[usp_selectReport_Order104_FillTables]    Script Date: 11.02.2019 14:40:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_selectReport_Order104_FillTables]
	@reportYear smallint,
	@reportMonth tinyint,
	@dtStart DATETIME=null,		
	@dtEnd DATETIME=null,
	@dtStartMM DATE=null,
	@dtEndMM DATE=null

AS

SET @dtStart = CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'11'
SET @dtEnd= CAST(case when @reportMonth = 12 then @reportYear+1 else @reportYear end AS CHAR(4))
			+RIGHT('0'+CAST(case when @reportMonth = 12 then 1 else @reportMonth+1 end AS VARCHAR(2)),2)+'11'

SET @dtStartMM=CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01' -- c 23/01/2019 не используется
SET @dtEndMM=dateadd(day,-1, convert(char(6), dateadd(month,1,@dtStartMM),112)+'01'); -- c 23/01/2019 не используется

--SELECT @dtStartMM, @dtEndMM

CREATE TABLE #tDS(DS VARCHAR(8)) 

INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'I%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'G%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDS( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'

CREATE TABLE #tDSChild(DS VARCHAR(8)) 

INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'A%'
INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'J%'
INSERT #tDSChild( DS ) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'K%'



--CREATE TABLE #Kurs(v006 tinyint,rslt TINYINT,MES VARCHAR(20))

--INSERT #Kurs(v006 , rslt, MES )
--VALUES  (1,102,'1316.0'),(1,102,'1086.0'), (1,102,'1314.0'),(1,102,'1031.0'),(1,102,'1032.0'),(1,102,'1033.0'), (1,102,'1044.0'),(1,102,'1045.0'),(1,102,'1046.0'),(1,102,'1047.0'),
--		(1,102,'1048.0'),(1,102,'1049.0'),(1,102,'1050.0'),(1,102,'1051.0'),(1,102,'1052.0'),(1,102,'1053.0'),(1,102,'1054.0'),(1,102,'1055.0'),(1,102,'1056.0'),(1,102,'1057.0'),
--		(1,102,'1058.0'),(1,102,'1059.0'),(1,102,'1060.0'),(1,102,'1061.0'),(1,102,'1062.0'),(1,102,'1063.0'),(1,102,'1064.0'),(1,102,'1065.0'),(1,102,'1066.0'),(2,202,'2121.0'), 
--		(2,202,'2038.0'),(2,202,'2118.0'),(2,202,'2014.0'),(2,202,'2015.0'),(2,202,'2016.0'),(2,202,'2052.0'),(2,202,'2053.0'),(2,202,'2054.0'),(2,202,'2055.0'),(2,202,'2056.0'),
--		(2,202,'2057.0'),(2,202,'2058.0'),(2,202,'2059.0'),(2,202,'2060.0'),(2,202,'2061.0'),(2,202,'2062.0'),(2,202,'2063.0')

SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, CAST(NULL AS CHAR(1)) AS AP_Type
	,c.DateBegin, c.DateEnd, CASE WHEN c.rf_idV014=1 AND c.rf_idV006<3 THEN 1 WHEN c.rf_idV014=2 AND c.rf_idV006<3 THEN 2 WHEN c.rf_idV014=3 AND c.rf_idV006<3 THEN 0 END AS Gosp_type
	, /*ReportMonth*/@reportMonth as ReportMonth/*нужен не отчетный месяц счета, а тот месяц, за который делается отчет. в запросах ниже аналогично*/, ReportYear, f.CodeM
INTO #tmpPeople
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles				
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
INNER JOIN dbo.t_PatientSMO p ON r.id=p.rf_idRecordCasePatient
INNER JOIN dbo.t_RegisterPatient rp ON f.id=rp.rf_idFiles AND r.id=rp.rf_idRecordCase							
INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient					              
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase				
INNER JOIN #tDS dd ON d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<@dtEndMM-- условие убрано из всех отчетов 23.01.2019 и оставлено условие a.ReportYear=@reportYear*/
		 AND c.rf_idV006<>3  /*здесь не нужен отчетный месяц счета*/AND a.ReportMonth=@reportMonth 

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014,rp.BirthDay, 'П',c.DateBegin, c.DateEnd
		, NULL, /*ReportMonth*/@reportMonth as ReportMonth, ReportYear, f.CodeM
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles				
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
INNER JOIN dbo.t_PatientSMO p ON r.id=p.rf_idRecordCasePatient	
INNER JOIN dbo.t_RegisterPatient rp ON f.id=rp.rf_idFiles AND r.id=rp.rf_idRecordCase								
INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient					             
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase				
INNER JOIN #tDS dd ON d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<@dtEndMM and c.rf_idV006=3 AND c.rf_idV009=313	AND a.ReportMonth=@reportMonth 

INSERT #tmpPeople 
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'О',c.DateBegin, c.DateEnd
		, null, /*ReportMonth*/@reportMonth as ReportMonth, ReportYear,f.CodeM
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles				
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
INNER JOIN dbo.t_PatientSMO p ON r.id=p.rf_idRecordCasePatient	
INNER JOIN dbo.t_RegisterPatient rp ON f.id=rp.rf_idFiles AND r.id=rp.rf_idRecordCase								
INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient	
INNER JOIN dbo.t_MES m ON c.id=m.rf_idCase   
INNER JOIN dbo.vw_sprMU mu ON m.MES=mu.MU           
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase				
INNER JOIN #tDS dd ON d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 --AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<@dtEndMM AND c.rf_idV006=3 AND c.rf_idV009<>313  AND m.MES LIKE '2.78.%' AND a.ReportMonth=@reportMonth AND c.rf_idV009<>313


INSERT #tmpPeople 
SELECT distinct c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, 'П',c.DateBegin, c.DateEnd
		, null, /*ReportMonth*/@reportMonth as ReportMonth, ReportYear,f.CodeM
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles				
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
INNER JOIN dbo.t_PatientSMO p ON r.id=p.rf_idRecordCasePatient
INNER JOIN dbo.t_RegisterPatient rp ON f.id=rp.rf_idFiles AND r.id=rp.rf_idRecordCase									
INNER JOIN dbo.t_Case c  ON r.id=c.rf_idRecordCasePatient	
INNER JOIN dbo.t_Meduslugi m ON c.id=m.rf_idCase              
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase				
INNER JOIN #tDS dd ON d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND c.Age>17 AND a.ReportMonth=@reportMonth
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<@dtEndMM and c.rf_idV006=3 AND c.rf_idV009<>313 AND m.MUGroupCode=2 AND m.MUUnGroupCode=88 

INSERT #tmpPeople
SELECT c.id AS rf_idCase,c.AmountPayment, c.AmountPayment AS AmountDeduction, c.Age,d.DS1,p.ENP, c.rf_idV009, c.rf_idV006, c.rf_idV014, rp.BirthDay, case when rf_idV006=3 then 'П' else null end AS AP_Type ,
		c.DateBegin,c.DateEnd,NULL, /*ReportMonth*/@reportMonth as ReportMonth,ReportYear,f.CodeM
--INTO #tmpPeople
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles				
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
INNER JOIN dbo.t_PatientSMO p ON r.id=p.rf_idRecordCasePatient
INNER JOIN dbo.t_RegisterPatient rp ON f.id=rp.rf_idFiles AND r.id=rp.rf_idRecordCase							
INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient
INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON c.rf_idV009=v.rf_idV009 					              
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase				
INNER JOIN #tDSChild dd ON d.DS1=dd.DS              
WHERE f.DateRegistration>=@dtStart AND f.DateRegistration<@dtEnd AND a.ReportYear=@reportYear AND ReportMonth=@reportMonth AND c.Age>0 AND c.Age<18 --AND a.rf_idSMO<>'34'
		AND c.DateEnd>=@dtStartMM AND c.DateEnd<@dtEndMM 

UPDATE p SET p.AmountDeduction=p.AmountPayment-r.AmountDeduction
FROM #tmpPeople p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dtStart AND c.DateRegistration<@dtEnd AND TypeCheckup=1
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--DROP TABLE t_OrderAdult_104_2018
--BEGIN TRANSACTION
INSERT dbo.t_OrderAdult_104_2018( rf_idCase ,AmountPayment ,AmountDeduction ,Age ,DS1 ,	ENP ,rf_idV009 ,rf_idV006 ,rf_idV014 ,BirthDay ,AP_Type ,DateBegin ,DateEnd ,Gosp_type ,
									ReportMonth ,ReportYear ,PVT ,CodeM, DateStamp)
SELECT rf_idCase ,AmountPayment ,AmountDeduction ,Age ,DS1 ,	ENP ,rf_idV009 ,rf_idV006 ,rf_idV014 ,BirthDay ,AP_Type ,DateBegin ,DateEnd ,Gosp_type
		,ReportMonth ,ReportYear ,0 as PVT ,CodeM,GETDATE() as DateStamp
FROM #tmpPeople
WHERE (CASE WHEN AmountPayment>0 AND AmountDeduction>0 THEN 1 WHEN AmountPayment=0 and AmountDeduction=0 THEN 1 ELSE 0 END)=1
--ROLLBACK
--CREATE NONCLUSTERED INDEX IX_Index_PVT
--ON [dbo].[t_OrderAdult_104_2018] ([DS1],[ENP],[rf_idV006],[DateBegin])
--INCLUDE ([rf_idCase],[DateEnd])
------------------------------------------------------------------------------------------
------------------------------------------EKMP--------------------------------------------
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

DROP TABLE #tDS
DROP TABLE #tDSChild
DROP TABLE #tmpPeople

