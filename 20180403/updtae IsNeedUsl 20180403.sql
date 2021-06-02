USE AccountOMS
GO
UPDATE m SET m.ISNeedUSL=n.IsNeedUsl
FROM t_Meduslugi m INNER JOIN tmpNeedUSL n ON
		m.rf_idCase=n.id
		AND m.GUID_MU=n.GUID_MU
WHERE m.IsNeedUsl IS NULL