USE AccountOMS
GO
DECLARE @codeM CHAR(6)='101002',
		@codeSMO CHAR(5)='34002',
		@id TINYINT=6

SELECT  l.filialName,t.CodeM ,l.NAMES, t.CodeSMO,s.sNameS ,'Май '+cast(t.ReportYear AS VARCHAR(4)) AS Report,u.NapeParent,u.NAME,--u.id,
        CAST(t.MonthQuantity AS MONEY) AS Quantity,
        t.MonthPeople AS CountPeople,
        CAST(t.MonthAmount AS MONEY) AS Amount         
FROM t_Data146Order t INNER JOIN dbo.vw_sprT001 l ON
			t.CodeM=l.CodeM
						INNER JOIN dbo.sprUnitCodeFor146 u ON
			t.UnitAccounting=u.id   
						INNER JOIN dbo.vw_sprSMO s ON 
			t.CodeSMO=s.smocod                   
WHERE ReportYear=2016 AND ReportMonth=5	--AND l.CodeM=@codeM AND t.CodeSMO=@codeSMO AND u.id=@id
UNION ALL
SELECT  l.filialName,t.CodeM ,l.NAMES, t.CodeSMO,s.sNameS ,'С начало года 2016',u.NapeParent,u.NAME,--u.id,        
        CAST(t.YearQuantity AS MONEY) AS YearQuantity ,
        t.YearPeople ,
        CAST(t.YearAmount AS MONEY) AS YearAmount
FROM t_Data146Order t INNER JOIN dbo.vw_sprT001 l ON
			t.CodeM=l.CodeM
						INNER JOIN dbo.sprUnitCodeFor146 u ON
			t.UnitAccounting=u.id    
						INNER JOIN dbo.vw_sprSMO s ON 
			t.CodeSMO=s.smocod                    
WHERE ReportYear=2016 AND ReportMonth=5	--AND l.CodeM=@codeM AND t.CodeSMO=@codeSMO AND u.id=@id
