USE AccountOMSReports
GO
SELECT COUNT(DISTINCT t.rf_idCase),COUNT(*) FROM dbo.tmp_Send2020 t

SELECT COUNT(DISTINCT t.rf_idCase),COUNT(*) FROM dbo.tmp_Send2020_1 t

SELECT DISTINCT mes,t.MUSurgery,TypeCases,typeQ,t.rf_idCase, t.DateEnd
FROM dbo.tmp_Send2020 t INNER JOIN oms_NSI.dbo.sprNomenclMUCSGview  v ON
	t.mes=v.[ Ó‰  —√]
WHERE mes IS NOT NULL AND t.MUSurgery IS NOT null and NOT EXISTS(SELECT 1 FROM oms_NSI.dbo.sprNomenclMUCSGview c where	t.MES=c.[ Ó‰  —√] AND t.MUSurgery=c.codeNomenclMU)

--SELECT * FROM dbo.t_Case WHERE id=115159457
SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=117166410

SELECT * FROM oms_NSI.dbo.sprNomenclMUCSGview WHERE [ Ó‰  —√]='st30.011'

--SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB IN (
--'A16.30.001',
--'A16.30.042',
--'A16.30.007',
--'A16.01.012',
--'A16.30.007',
--'A16.26.062')

--SELECT * FROM dbo.vw_sprCSG WHERE code='st21.004'