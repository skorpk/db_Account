USE AccountOMS
GO
DECLARE @p_StartRegistrationDate nvarchar(8)='20200101',	
		@p_EndRegistrationDate nvarchar(8)='20201009',
		@p_StartReportMonth TINYINT=1,
		@p_EndReportMonth TINYINT=9,
		@p_StartReportYear SMALLINT=2020,
		@p_EndReportYear SMALLINT=2020,
		@p_EndRAKDate nvarchar(8)='20201009',
		@p_PrNumReg TINYINT=34 --0 - Волг. обл., 34 - иногородние

SELECT distinct f.CodeM,cc.id AS rf_idCompletedCase,cc.AmountPayment,cast(0 as decimal(15,2)) as AmPayAcc,c.rf_idV006,mkb10.[MainDS],psmo.ENP/*pc.[IDPeople]*/ ENP
INTO #tmpCases
FROM dbo.t_File f 
INNER JOIN dbo.t_RegistersAccounts a ON f.id=a.rf_idFiles
INNER JOIN dbo.t_RecordCasePatient r ON a.id=r.rf_idRegistersAccounts	
inner join dbo.t_CompletedCase cc on cc.rf_idRecordCasePatient=r.id				
INNER JOIN dbo.t_Case c ON r.id=c.rf_idRecordCasePatient					
INNER JOIN dbo.vw_Diagnosis d ON c.id=d.rf_idCase   
inner join [dbo].[vw_sprMKB10] mkb10 on mkb10.[DiagnosisCode]=d.DS1   
--INNER JOIN dbo.t_People_Case pc on pc.rf_idCase=c.id       
INNER JOIN dbo.t_PatientSMO psmo on psmo.rf_idRecordCasePatient=r.id
WHERE f.DateRegistration>=@p_StartRegistrationDate AND (f.DateRegistration-1)<=@p_EndRegistrationDate 
AND a.ReportYearMonth >= (CONVERT([int],CONVERT([char](4),@p_StartReportYear,0)+right('0'+CONVERT([varchar](2),@p_StartReportMonth,0),(2)),0)) and a.ReportYearMonth <= (CONVERT([int],CONVERT([char](4),@p_EndReportYear,0)+right('0'+CONVERT([varchar](2),@p_EndReportMonth,0),(2)),0)) 
AND d.DS1 like 'O0%'
AND ((a.rf_idSMO=@p_PrNumReg and @p_PrNumReg=34) or (@p_PrNumReg<>34 and a.rf_idSMO<>34))
and rf_idV006 in (1,2)


UPDATE c1 SET c1.AmPayAcc=c1.AmountPayment-isnull(p.AmountDeduction,0)
FROM #tmpCases c1 left JOIN (
        SELECT rf_idCompletedCase,SUM(ISNULL(AmountDeduction,0)) AS AmountDeduction
        FROM dbo.t_PaymentAcceptedCaseZSL 
        WHERE DateRegistration>=@p_StartRegistrationDate AND (DateRegistration-1)<@p_EndRAKDate   
        GROUP BY rf_idCompletedCase
						  ) p ON
				c1.rf_idCompletedCase=p.rf_idCompletedCase    

delete from #tmpCases
where (AmPayAcc<0 and AmountPayment=0)
	  or
	  (AmPayAcc<=0 and AmountPayment>0)


SELECT t.CodeM,mo.NAMES,t.MainDS,mkb10.Diagnosis
,count(CASE WHEN rf_idV006=1 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesStac
,count(CASE WHEN rf_idV006=2 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesDS
--,count(CASE WHEN rf_idV006=3 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesAmb
--,count(CASE WHEN rf_idV006=4 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesSMP
,count(rf_idCompletedCase) AS CountCasesTot
,count(distinct CASE WHEN rf_idV006=1 THEN ENP ELSE NULL end) AS CountPeopleStac
,count(distinct CASE WHEN rf_idV006=2 THEN ENP ELSE NULL end) AS CountPeopleDS
--,count(distinct CASE WHEN rf_idV006=3 THEN ENP ELSE NULL end) AS CountPeopleAmb
--,count(distinct CASE WHEN rf_idV006=4 THEN ENP ELSE NULL end) AS CountPeopleSMP
,count(distinct ENP) AS CountPeopleTot
FROM #tmpCases t
inner join [dbo].[vw_sprT001] mo on t.CodeM=mo.CodeM
inner join [dbo].[vw_sprMKB10] mkb10 on mkb10.[DiagnosisCode]=t.MainDS 
group by t.CodeM,mo.NAMES,t.MainDS,mkb10.Diagnosis

union all

select null,null,null,'ИТОГО:'
,count(CASE WHEN rf_idV006=1 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesStac
,count(CASE WHEN rf_idV006=2 THEN rf_idCompletedCase ELSE NULL end) AS CountCasesDS
--,count(CASE WHEN rf_idV006=3 THEN rf_idCase ELSE NULL end) AS CountCasesAmb
,count(rf_idCompletedCase) AS CountCasesTot
,null,/*null,null,*/null,COUNT (distinct ENP)
from #tmpCases t
go
DROP TABLE #tmpCases
