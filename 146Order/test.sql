USE AccountOMS
go
declare	@reportMonth TINYINT=5,
		@reportYear SMALLINT=2016,
		@codeM CHAR(6)='101002',
		@codeSMO CHAR(5)='34002'


DECLARE @dateStartMonth DATETIME=CAST(@reportYear AS CHAR(4))+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'01',
		@dateEnd DATETIME,
		@dateStart DATETIME,
		@dateStartYear DATETIME=CAST(@reportYear AS CHAR(4))+'0101'

SELECT @dateEnd=DateEnd from dbo.sprDate146Order WHERE ReportMonth=@reportMonth AND ReportYear=@reportYear
SELECT @dateStart=DateEnd from dbo.sprDate146Order WHERE ReportMonth=(CASE WHEN @reportMonth=1 THEN 12 ELSE @reportMonth-1 END)  AND ReportYear=(CASE WHEN @reportMonth=1 THEN @reportYear-1 ELSE @reportYear END)  

SELECT @dateStart,@dateEnd,@dateStartMonth


SELECT @reportMonth,@reportYear,t.CodeM,t.rf_idSMO,UnitAccounting,SUM(MonthQuantity),COUNT(DISTINCT MonthPeople) ,SUM(MonthAmount),SUM(YearQuantity),COUNT(DISTINCT YearPeople),SUM(YearAmount)
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
						LEFT JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartMonth AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11 AND f.CodeM=@codeM AND a.rf_idSMO=@codeSMO
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,SUM(m.Quantity),p.IDPeople ,c.AmountPayment ,0 ,null,0 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<=@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient
				AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear							
						left JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11 AND f.CodeM=@codeM AND a.rf_idSMO=@codeSMO
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,0,null ,c.AmountPayment ,0 ,null,0 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<=@reportMonth
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
	WHERE f.DateRegistration>=@dateStart AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND csg.code LIKE '1___9__' AND f.CodeM=@codeM AND a.rf_idSMO=@codeSMO
	GROUP BY c.id,f.CodeM,a.rf_idSMO,c.AmountPayment
	----------------------------------Year------------------------------------------
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,0,null,0,SUM(m.Quantity) ,p.IDPeople ,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<=@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient							
				--AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
						INNER JOIN dbo.t_People_Case p ON
				c.id=p.rf_idCase                  
						INNER JOIN dbo.t_Meduslugi m ON
				c.id=m.rf_idCase 					
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND m.MUGroupCode=1 AND m.MUUnGroupCode=11 AND f.CodeM=@codeM AND a.rf_idSMO=@codeSMO
	GROUP BY c.id,f.CodeM,a.rf_idSMO,p.IDPeople,c.AmountPayment
	UNION ALL
	SELECT c.id,f.CodeM,a.rf_idSMO,6 AS UnitAccounting,0,null,0,0 ,null,c.AmountPayment 
	FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
				f.id=a.rf_idFiles
				AND a.ReportMonth<=@reportMonth
				AND a.ReportYear=@reportYear
						INNER JOIN dbo.t_RecordCasePatient r ON
				a.id=r.rf_idRegistersAccounts
						INNER JOIN dbo.t_Case c ON
				r.id=c.rf_idRecordCasePatient		
				--AND c.DateEnd<@dateStartMonth											
				AND c.DateEnd>=@dateStartYear
						INNER JOIN dbo.t_MES m on
				c.id=m.rf_idCase				
						INNER JOIN RegisterCases.dbo.vw_sprCSG	csg ON
				m.MES=csg.code                      
	WHERE f.DateRegistration>=@dateStartYear AND f.DateRegistration<@dateEnd AND c.rf_idV006=1 AND csg.code LIKE '1___9__' AND f.CodeM=@codeM AND a.rf_idSMO=@codeSMO
	
) t
GROUP BY t.CodeM,t.rf_idSMO,t.UnitAccounting
