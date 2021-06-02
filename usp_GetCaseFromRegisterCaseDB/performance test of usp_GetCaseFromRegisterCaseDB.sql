use AccountOMS
go
--dbcc freeproccache

SET STATISTICS TIME ON

declare @account varchar(15)='34001-10-1'
		,@codeMO char(6)='251001'
		,@month tinyint=3
		,@year smallint=2012
		
create table #case
(
	ID_Patient varchar(36) NOT NULL,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idDirectMO char(6) NULL,
	HopitalisationType tinyint NULL,
	rf_idMO char(6) NOT NULL,
	rf_idV002 smallint NOT NULL,
	IsChildTariff bit NOT NULL,
	NumberHistoryCase nvarchar(50) NOT NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	DS0 char(10) NULL,
	DS1 char(10) NULL,
	DS2 char(10) NULL,
	MES char(16) NULL,
	rf_idV009 smallint NOT NULL,
	rf_idV012 smallint NOT NULL,
	rf_idV004 int NOT NULL,
	IsSpecialCase tinyint NULL,
	rf_idV010 tinyint NOT NULL,
	Quantity decimal(5, 2) NULL,
	Tariff decimal(15, 2) NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	SANK_MEK decimal(15, 2) NULL,
	SANK_MEE decimal(15, 2) NULL,
	SANK_EKMP decimal(15, 2) NULL
)
if OBJECT_ID('tempDB..#case',N'U') is not null
begin
	exec usp_GetCaseFromRegisterCaseDB @account,@codeMO,@month,@year
end
--select * from #case
go

drop table #case
