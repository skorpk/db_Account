use	AccountOMS
GO
--сначало создаем таблицы т.к выгрузка происходит быстрее
SELECT * INTO tmp_MagalazKireeva_34002 FROM dbo.vw_MagalazKireeva_34002
GO
SELECT * INTO tmp_MagalazKireeva_34001 FROM dbo.vw_MagalazKireeva_34001
go
----удаляем таблицы
DROP TABLE tmp_MagalazKireeva_34001
DROP TABLE tmp_MagalazKireeva_34002