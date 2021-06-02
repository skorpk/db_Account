USE CanserRegister
GO
CREATE VIEW vw_PeopleDateStart
AS
SELECT t.rf_idPeopleENP,t.DateRegistr AS DateRegistration
FROM (
		SELECT ROW_NUMBER() OVER(PARTITION BY rf_idPeopleENP ORDER BY DateRegistr) AS idRow, rf_idPeopleENP,DateRegistr FROM dbo.t_PeopleCase
		) t
WHERE idRow=1