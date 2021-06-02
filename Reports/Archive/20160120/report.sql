USE AccountOMS
GO
SELECT l.CodeM ,t.SNILS_Doc 
	----------------------------July-------------------------------------------------------------------------------
	------------------------------GOSP------------------------------------------------------
	,count(CASE WHEN t.rf_idV006=4 and t.ReportMonth=1 and t.rf_idV009=403 THEN t.rf_idCase ELSE NULL END) AS H_7_Y	
	------------------------------SMP-------------------------------------------------------
	,count(CASE WHEN t.rf_idV006=4 and t.ReportMonth=1 THEN t.rf_idCase ELSE NULL END) AS S_7_Y	
	----------------------------August-------------------------------------------------------------------------------
	------------------------------GOSP------------------------------------------------------
	,count(CASE WHEN  t.rf_idV006=4 and t.ReportMonth=2 and t.rf_idV009=403 THEN t.rf_idCase ELSE NULL END) AS H_8_Y
	------------------------------SMP-------------------------------------------------------
	,count(CASE WHEN  t.rf_idV006=4 and t.ReportMonth=2 THEN t.rf_idCase ELSE NULL END) AS S_8_Y
	----------------------------September-------------------------------------------------------------------------------
	------------------------------GOSP------------------------------------------------------
	,count(CASE WHEN  t.rf_idV006=4 and t.ReportMonth=3 and t.rf_idV009=403 THEN t.rf_idCase ELSE NULL END) AS H_9_Y
	------------------------------SMP-------------------------------------------------------
	,count(CASE WHEN  t.rf_idV006=4 and t.ReportMonth=3 THEN t.rf_idCase ELSE NULL END) AS S_9_Y
	----------------------------October-------------------------------------------------------------------------------	
FROM dbo.t_SNILSAmbulanceFFOMS t INNER JOIN dbo.vw_sprT001 l ON
					t.AttachLPU=l.CodeM  
WHERE ReportYear=2016
GROUP BY l.CodeM ,t.SNILS_Doc 
