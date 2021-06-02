USE AccountOMS
GO

;WITH double_r 
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY rf_idCase,GUID_MU ORDER BY rf_idCase,id ) AS id, rf_idCase ,GUID_MU FROM dbo.t_Meduslugi
)
delete FROM double_r WHERE id>1
--SELECT count(*) FROM double_r WHERE id>1

