USE AccountOMS
GO
DROP TABLE t_OrderAdult_104_2018_EKMP_2
SELECT c.*, p.Reason, 0 AS TypeExp, 1 AS IsEKMP
INTO t_OrderAdult_104_2018_EKMP_2
FROM dbo.t_OrderAdult_104_2018 c INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 	        
						left JOIN dbo.vw_PaymnetEKMP_Reason p ON
			c.rf_idCase=p.rf_idCase
WHERE p.rf_idCase IS NOT NULL  AND EXISTS(SELECT * FROM dbo.t_OrderAdult_104_2018_EKMP e WHERE c.rf_idCase=e.rf_idCase AND IsEKMP=0)