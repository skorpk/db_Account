USE AccountOMS
go
DECLARE @dtStart DATETIME ='20180101',		
		@dtEnd DATETIME='20180611',
		@dtEndRak DATETIME='20180611',
		@reportYear smallint=2018,
		@reportMonth tinyint=5,
		@dtStartMM DATE,
		@dtEndMM DATE
/*
DROP TABLE t_OrderAdult_104_2018_EKMP
SELECT c.*, p.Reason, 0 AS TypeExp, CASE WHEN p.rf_idCase IS NOT NULL THEN 1 ELSE 0 END IsEKMP
INTO t_OrderAdult_104_2018_EKMP
FROM dbo.t_OrderAdult_104_2018 c INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 	        
						left JOIN dbo.vw_PaymnetEKMP_Reason p ON
			c.rf_idCase=p.rf_idCase
--WHERE p.DateRegistration<@dtEnd
*/
DROP TABLE t_OrderAdult_104_2017_EKMP

SELECT c.*, p.Reason, 0 AS TypeExp, CASE WHEN p.rf_idCase IS NOT NULL THEN 1 ELSE 0 END IsEKMP
INTO t_OrderAdult_104_2017_EKMP
FROM dbo.t_OrderAdult_104_2017 c INNER JOIN (VALUES(105),(106),(205),(206),(313),(405),(406),(411)) v(rf_idV009) ON
			c.rf_idV009=v.rf_idV009 	        
						left JOIN dbo.vw_PaymnetEKMP_Reason p ON
			c.rf_idCase=p.rf_idCase
go 			                        