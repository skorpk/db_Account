USE [AccountOMS]
GO
--DBCC SHRINKFILE (N'account_log' , 0, TRUNCATEONLY)
--GO
/*
drop table t_Data146Order
CREATE TABLE t_Data146Order
(
	CodeM CHAR(6) NOT null,
	CodeSMO CHAR(5) NOT null,
	ReportMonth tinyint,
	ReportYear smallint,
	UnitAccounting TINYINT NOT null,
	MonthQuantity DECIMAL(11,2) NOT null,
	MonthPeople INT NOT null,
	MonthAmount DECIMAL(11,2) NOT null,
	YearQuantity DECIMAL(11,2) NOT null,
	YearPeople INT NOT null,
	YearAmount DECIMAL(11,2) NOT null
)
drop table sprUnitCodeFor146
CREATE TABLE sprUnitCodeFor146 
(
	id TINYINT, 
	NapeParent VARCHAR(100),
	NAME VARCHAR(30)
)

INSERT dbo.sprUnitCodeFor146( id, NapeParent, NAME )
VALUES(1,'Первичная медико-санитарная помощь','врачебные приемы'),(2,'Первичная медико-санитарная помощь','пациенто-дни'),(3,'Первичная медико-санитарная помощь','УЕТ')
		,(4,'Скорая, в том числе специализированная (санитарно-авиационная), медицинская помощь','вызов СМП')
		,(5,'Специализированная, в том числе высокотехнологичная','врачебные приемы'),(6,'Специализированная, в том числе высокотехнологичная','койко-день стационара')
		,(7,'Специализированная, в том числе высокотехнологичная','пациенто-дни'),(8,'Специализированная, в том числе высокотехнологичная','диагностические услуги')
*/
DECLARE @reportMonth TINYINT=1,
		@reportYear SMALLINT=2016
SELECT CodeM, CodeSMO,UnitAccounting,v.NapeParent,v.Name,MonthQuantity,MonthPeople,MonthAmount,YearQuantity,YearPeople,YearAmount 
FROM t_Data146Order t inner JOIN sprUnitCodeFor146 v ON
		t.UnitAccounting=v.id
WHERE t.ReportYear=@reportYear AND t.ReportMonth=@reportMonth
ORDER BY t.CodeM, t.CodeSMO,UnitAccounting