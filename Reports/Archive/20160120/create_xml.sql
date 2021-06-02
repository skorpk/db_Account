USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetDataFFOMS_SNILS]    Script Date: 26.01.2016 13:23:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetDataFFOMS_SNILS]
				 @mm TINYINT,
				 @codeM CHAR(6),
				 @snils VARCHAR(11),
				 @id int
as
SELECT (SELECT @id AS 'N_ZAP', l.mcod AS 'MO_SV_V',t.SNILS_Doc AS 'SNILS_V'
	------------------------------GOSP------------------------------------------------------
	,count(CASE WHEN t.Sex=2 AND t.rf_idV006=4 and t.rf_idV009=403 AND Age>17 AND Age<55 THEN t.rf_idCase ELSE NULL END) AS 'GOSP/GOSP_Z1'
	,count(CASE WHEN t.Sex=2 AND t.rf_idV006=4 and t.rf_idV009=403 AND Age>54 THEN t.rf_idCase ELSE NULL END) AS 'GOSP/GOSP_Z2'
	,count(CASE WHEN t.Sex=1 AND t.rf_idV006=4 and t.rf_idV009=403 AND Age>17 AND Age<60 THEN t.rf_idCase ELSE NULL END) AS 'GOSP/GOSP_M1'
	,count(CASE WHEN t.Sex=1 AND t.rf_idV006=4 and t.rf_idV009=403 AND Age>59 THEN t.rf_idCase ELSE NULL END) AS 'GOSP/GOSP_M2'
	------------------------------SMP-------------------------------------------------------
	,count(CASE WHEN t.Sex=2 AND t.rf_idV006=4 AND Age>17 AND Age<55 THEN t.rf_idCase ELSE NULL END) AS 'SMP/SMP_Z1'
	,count(CASE WHEN t.Sex=2 AND t.rf_idV006=4 AND Age>54 THEN t.rf_idCase ELSE NULL END) AS 'SMP/SMP_Z2'
	,count(CASE WHEN t.Sex=1 AND t.rf_idV006=4 AND Age>17 AND Age<60 THEN t.rf_idCase ELSE NULL END) AS 'SMP/SMP_M1'
	,count(CASE WHEN t.Sex=1 AND t.rf_idV006=4 AND Age>59 THEN t.rf_idCase ELSE NULL END) AS 'SMP/SMP_M2'
FROM dbo.t_SNILSAmbulanceFFOMS t INNER JOIN dbo.vw_sprT001 l ON
					t.AttachLPU=l.CodeM  
WHERE reportMonth=@mm AND AttachLPU=@codeM AND SNILS_Doc=@snils
GROUP BY l.mcod ,t.SNILS_Doc 
FOR XML PATH(''),TYPE,ROOT('OBSV')),
(
	SELECT  t.id AS 'ZAP/N_ZAP'
			,Sex AS 'ZAP/PACIENT/W'
			,Age AS 'ZAP/PACIENT/VZST'
			,l.mcod AS 'ZAP/PACIENT/MO_SV_V'
			,SNILS_Doc AS 'ZAP/PACIENT/SNILS_V'
			,NumberCase AS 'ZAP/SLUCH/IDCASE'
			,rf_idV006 AS 'ZAP/SLUCH/USL_OK'
			,rf_idV008 AS 'ZAP/SLUCH/VIDPOM'
			,rf_idV009 AS 'ZAP/SLUCH/RSLT'
	FROM dbo.t_SNILSAmbulanceFFOMS t INNER JOIN dbo.vw_sprT001 l ON
					t.AttachLPU=l.CodeM  
	WHERE reportMonth=@mm AND AttachLPU=@codeM AND SNILS_Doc=@snils
	ORDER BY rf_idCase
	FOR XML PATH(''),TYPE,ROOT('PDRSV')
	
)

