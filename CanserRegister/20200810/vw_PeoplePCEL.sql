USE CanserRegister
GO
CREATE VIEW vw_PeoplePCEL
as
SELECT rf_idPeopleENP,MAX(DateEnd) AS dateEnd FROM t_PeoplePCEL GROUP BY rf_idPeopleENP
go