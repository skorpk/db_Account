USE AccountOMS
GO
alter PROCEDURE usp_CreateData146Order
		@reportMonth TINYINT,
		@reportYear SMALLINT
as        
DECLARE @dateStartMonth DATETIME=CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01',
		@dateEnd DATETIME,
		@dateStart DATETIME,
		@dateStartYear DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

SELECT @dateEnd=DateEnd from dbo.sprDate146Order WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear
SELECT @dateStart=DateEnd from dbo.sprDate146Order WHERE ReportMonth=(CASE WHEN @reportMonth=1 THEN 12 ELSE @reportMonth-1 END)  AND ReportYear=(CASE WHEN @reportMonth=1 THEN @reportYear-1 ELSE @reportYear END)  

--SELECT @dateStart=dateadd(day,10,@dateStartMonth)

SELECT @dateStart,@dateEnd,@dateStartMonth

/*
1-врачебные приемы
2-пациенто-дни
3-УЕТ
4-вызов СМП
5-врачебные приемы
6-койко-день стационара
7-пациенто-дни
8-диагностические услуги
*/
DECLARE @dateRun DATETIME=GETDATE()

INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
		SELECT c.id,f.CodeM,a.rf_idSMO,1 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,0 AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND sMU.MUUnGroupCode NOT IN (4,90) AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,1 ,SUM(m.Quantity) ,p.IDPeople,0,0,null,0
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear 
					AND c.DateEnd<@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND m.MUUnGroupCode NOT IN (4,90) AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPEople
		---------------Payment-----------------------------------------------------
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,1 ,0,null,c.AmountPayment ,0,null,0 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id					               								
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,1 AS UnitAccounting,0,null,c.AmountPayment,0 ,null,0 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear 
					AND c.DateEnd<@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id					               								
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
		UNION ALL
		-------------------Start Year---------------------------------
		SELECT c.id,f.CodeM,a.rf_idSMO,1,0,null,0,SUM(m.Quantity) ,p.IDPeople,0
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear 
					AND c.DateEnd<@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND m.MUUnGroupCode NOT IN (4,90) AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,1 ,0,null,0,0,null,c.AmountPayment 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear 
					AND c.DateEnd<@dateStartMonth
							INNER JOIN (VALUES(1),(11),(12)) v008(id) on
					c.rf_idV008=v008.id					               								
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
) T
group by t.CodeM,t.rf_idSMO,UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

------------------------------- 2-пациенто-дни----------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
		SELECT c.id,f.CodeM,a.rf_idSMO,2 AS UnitAccounting,SUM(ISNULL(m.Quantity,0)) AS MonthQuantity,p.IDPeople AS MonthPeople ,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartMonth					
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase                  
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							left JOIN dbo.t_Meduslugi m ON								
					c.id=m.rf_idCase					
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND MUUnGroupCode=1 AND m.MUCode=3 
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,2 AS UnitAccounting,SUM(ISNULL(m.Quantity,0)) AS MonthQuantity,p.IDPeople,c.AmountPayment,0 ,null ,0 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear
					AND c.DateEnd<@dateStartMonth					
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase                  
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							left JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND MUUnGroupCode=1 AND m.MUCode=3 
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
		-------------------Start Year---------------------------------
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,2 AS UnitAccounting,0,null ,0,SUM(ISNULL(m.Quantity,0)) ,p.IDPeople,c.AmountPayment
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient					
					AND c.DateEnd>=@dateStartYear
					AND c.DateEnd<@dateStartMonth	
							INNER JOIN dbo.t_MES mes ON
					c.id=mes.rf_idCase                  
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							left JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase					
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND MUUnGroupCode=1 AND m.MUCode=3 
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
) t
group by t.CodeM,t.rf_idSMO,UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

------------------------------- 3-УЕТ---------------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
		SELECT c.id,f.CodeM,a.rf_idSMO,3 AS UnitAccounting,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*sm.ChildUET ELSE m.Quantity*sm.AdultUET END) AS MonthQuantity,p.IDPeople AS MonthPeople
				,SUM(m.Price*m.Quantity) AS MonthAmount,0 AS YearQuantity ,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartMonth												
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase	
							INNER JOIN dbo.vw_sprMU sm ON
					m.MUGroupCode=sm.MUGroupCode
					AND m.MUUnGroupCode=sm.MUUnGroupCode
					AND m.MUCode=sm.MUCode				
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND a.Letter='T' AND sm.MUGroupCode=57
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,3 AS UnitAccounting,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*sm.ChildUET ELSE m.Quantity*sm.AdultUET END) ,p.IDPeople ,SUM(m.Price*m.Quantity),0 ,null ,0 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear
					AND c.DateEnd<@dateStartMonth												
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase	
							INNER JOIN dbo.vw_sprMU sm ON
					m.MUGroupCode=sm.MUGroupCode
					AND m.MUUnGroupCode=sm.MUUnGroupCode
					AND m.MUCode=sm.MUCode				
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND a.Letter='T' AND sm.MUGroupCode=57
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople
		-------------------------------------Year----------------------------
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,3 AS UnitAccounting,0 ,null ,0,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*sm.ChildUET ELSE m.Quantity*sm.AdultUET END),p.IDPeople,SUM(m.Price*m.Quantity) 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartYear
					AND c.DateEnd<@dateStartMonth												
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase	
							INNER JOIN dbo.vw_sprMU sm ON
					m.MUGroupCode=sm.MUGroupCode
					AND m.MUUnGroupCode=sm.MUUnGroupCode
					AND m.MUCode=sm.MUCode				
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND a.Letter='T' AND sm.MUGroupCode=57
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople
) t
group by t.CodeM,t.rf_idSMO,UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

----------------------------- 4-вызов СМП--------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
		SELECT c.id,f.CodeM,a.rf_idSMO,4 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity ,p.IDPeople as MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient										
					AND c.DateEnd>=@dateStartMonth		
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase																			  					
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=4
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment 
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,4 AS UnitAccounting,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment,0 ,null ,0 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient	
					AND c.DateEnd<@dateStartMonth											
					AND c.DateEnd>=@dateStartYear
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase											
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=4
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment 
		UNION ALL
		-------------------------------------Year----------------------------
		SELECT c.id,f.CodeM,a.rf_idSMO,4 AS UnitAccounting,0 ,null ,0,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient									                  
					AND c.DateEnd<@dateStartMonth											
					AND c.DateEnd>=@dateStartYear
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							inner JOIN dbo.t_Meduslugi m on
					c.id=m.rf_idCase						
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=4
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment 
	) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

----------------------------- 5-врачебные приемы------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
from (
		SELECT c.id,f.CodeM,a.rf_idSMO,5 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth=@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd>=@dateStartMonth																
							INNER JOIN (VALUES(13),(31)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN [SRVSQL1-ST2].AccountOMSReports.dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,5 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd<@dateStartMonth											
					AND c.DateEnd>=@dateStartYear
							INNER JOIN (VALUES(13),(31)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
		--------------------------Year--------------------------------------------------------------
		UNION ALL
		SELECT c.id,f.CodeM,a.rf_idSMO,5 AS UnitAccounting,0 ,null ,0 ,SUM(m.Quantity),p.IDPeople,c.AmountPayment 
		FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
					f.id=a.rf_idFiles
					AND a.ReportMonth<@reportMonth
					AND a.ReportYear=@reportYear
							INNER JOIN dbo.t_RecordCasePatient r ON
					a.id=r.rf_idRegistersAccounts
							INNER JOIN dbo.t_Case c ON
					r.id=c.rf_idRecordCasePatient
					AND c.DateEnd<@dateStartMonth											
					AND c.DateEnd>=@dateStartYear
							INNER JOIN (VALUES(13),(31)) v008(id) on
					c.rf_idV008=v008.id
							INNER JOIN dbo.t_People_Case p ON
					c.id=p.rf_idCase                  
							INNER JOIN dbo.t_Meduslugi m ON
					c.id=m.rf_idCase
							INNER JOIN dbo.vw_sprMU_2 sMU ON
					m.MUGroupCode=sMU.MUGroupCode
					AND m.MUUnGroupCode=sMU.MUUnGroupCode
					AND m.MUCode=sMU.MUCode
		WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=3 AND a.Letter NOT IN ('K','T')
		GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
 ) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

--------------------------------------- 6-койко-день стационара-------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth=@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient	
				AND c.DateEnd>=@dateStartMonth																						
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,SUM(m.Quantity),p.IDPeople ,c.AmountPayment ,0 ,null,0 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear							
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	----------------------------------Year------------------------------------------
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,0,null,0,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient							
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,0,null,0,0 ,0,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient		
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
						INNER JOIN dbo.t_MES m on
				c.id=m.rf_idCase				
						INNER JOIN RegisterCases.dbo.vw_sprCSG	csg ON
				m.MES=csg.code                      
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND csg.code LIKE '1___9__'
	
) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

---------------------------------7-пациенто-дни----------------------------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
	SELECT c.id,f.CodeM,a.rf_idSMO,7 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth=@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient							
				AND c.DateEnd>=@dateStartMonth															
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND m.MUUnGroupCode=1 AND m.MUCode IN(1,2,4)
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,7 AS UnitAccounting,SUM(m.Quantity) ,p.IDPeople,c.AmountPayment,0,null,0 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient							
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND m.MUUnGroupCode=1 AND m.MUCode IN(1,2,4)
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	-------------------------------------Year------------------------------------------
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,7 AS UnitAccounting,0,null,0,SUM(m.Quantity) ,p.IDPeople,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient				
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear			
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND m.MUGroupCode=55 AND m.MUUnGroupCode=1 AND m.MUCode IN(1,2,4)
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment   
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,7 AS UnitAccounting,0,null,0,0 ,null,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear		
						INNER JOIN dbo.t_MES m on
				c.id=m.rf_idCase				
						INNER JOIN RegisterCases.dbo.vw_sprCSG	csg ON
				m.MES=csg.code                      
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=2 AND csg.code LIKE '2___9__'
	
) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()

-------------------------------8-диагностические услуги------------------------------
INSERT dbo.t_Data146Order(ReportMonth,ReportYear, CodeM ,CodeSMO ,UnitAccounting ,MonthQuantity ,MonthPeople ,MonthAmount ,YearQuantity ,YearPeople ,YearAmount)						 
SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(YearPeople),SUM(YearAmount)
FROM (
	 SELECT c.id,f.CodeM,a.rf_idSMO,8 AS UnitAccounting,SUM(m.Quantity) AS MonthQuantity,p.IDPeople AS MonthPeople,c.AmountPayment AS MonthAmount,0 AS YearQuantity,null AS YearPeople,0 AS YearAmount
	 FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
 				f.id=a.rf_idFiles
 				AND a.ReportMonth=@reportMonth
 				AND a.ReportYear=@reportYear
 						INNER JOIN dbo.t_RecordCasePatient r ON
 				a.id=r.rf_idRegistersAccounts
 						INNER JOIN dbo.t_Case c ON
 				r.id=c.rf_idRecordCasePatient	
				AND c.DateEnd>=@dateStartMonth																					
 						INNER JOIN dbo.t_People_Case p ON
 				c.id=p.rf_idCase                  
 						INNER JOIN dbo.t_Meduslugi m ON
 				c.id=m.rf_idCase 					
	 WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND a.Letter='K'
	 GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	 UNION ALL
	 SELECT c.id,f.CodeM,a.rf_idSMO,8 ,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment ,0 ,null ,0 
	 FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
 				f.id=a.rf_idFiles
 				AND a.ReportMonth<@reportMonth
 				AND a.ReportYear=@reportYear
 						INNER JOIN dbo.t_RecordCasePatient r ON
 				a.id=r.rf_idRegistersAccounts
 						INNER JOIN dbo.t_Case c ON
 				r.id=c.rf_idRecordCasePatient
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
 						INNER JOIN dbo.t_People_Case p ON
 				c.id=p.rf_idCase                  
 						INNER JOIN dbo.t_Meduslugi m ON
 				c.id=m.rf_idCase 					
	 WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND a.Letter='K'
	 GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	 ----------------------------------Year---------------------------------------------
	 UNION ALL
	 SELECT c.id,f.CodeM,a.rf_idSMO,8 ,0 ,null ,0,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment  
	 FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
 				f.id=a.rf_idFiles
 				AND a.ReportMonth<@reportMonth
 				AND a.ReportYear=@reportYear
 						INNER JOIN dbo.t_RecordCasePatient r ON
 				a.id=r.rf_idRegistersAccounts
 						INNER JOIN dbo.t_Case c ON
 				r.id=c.rf_idRecordCasePatient
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear							
 						INNER JOIN dbo.t_People_Case p ON
 				c.id=p.rf_idCase                  
 						INNER JOIN dbo.t_Meduslugi m ON
 				c.id=m.rf_idCase 					
	 WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND a.Letter='K'
	 GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
PRINT(DATediff(SECOND,@dateRun,GETDATE()))
SELECT @dateRun=GETDATE()


/*
SELECT CodeM, CodeSMO,UnitAccounting,v.Name,MonthQuantity,MonthPeople,MonthAmount,YearQuantity,YearPeople,YearAmount 
FROM t_ inner JOIN @type v ON
		T.UnitAccounting=v.id
ORDER BY t.CodeM, t.CodeSMO,UnitAccounting
*/

