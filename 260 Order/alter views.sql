USE AccountOMS
go
;WITH cteZSL
AS
(
	SELECT o.id AS idFile,o.rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate AS NPR_DATE,l.mcod AS LPU,DATE_Z_1,Date_Z_2,KD_Z,RSLT
			,ISHOD,cc.VB_P, IDSP,o.AmountPayment AS SUMV, SUM(ISNULL(p.AmountDeduction,0.0)) AS SANK_IT
	from dbo.t_260order_ONK o INNER JOIN vw_sprT001 l ON
				o.LPU=l.CodeM
								INNER JOIN dbo.t_CompletedCase cc ON
				o.rf_idRecordCasePatient=cc.rf_idRecordCasePatient                          
								LEFT JOIN dbo.t_DirectionDate dd ON
				o.rf_idCase = dd.rf_idCase
								LEFT JOIN dbo.t_PaymentAcceptedCase2 p ON
				o.rf_idCase=p.rf_idCase                            
	GROUP BY o.id ,o.rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate ,l.mcod ,DATE_Z_1,Date_Z_2,KD_Z,RSLT,ISHOD,cc.VB_P, IDSP,o.AmountPayment 
)
SELECT  idFile ,rf_idRecordCasePatient ,N_ZAP ,IDCASE ,USL_OK ,VIDPOM ,FOR_POM ,NPR_MO ,NPR_DATE ,LPU ,DATE_Z_1 ,Date_Z_2 ,KD_Z ,RSLT ,ISHOD ,VB_P ,IDSP ,SUMV 
		,CASE WHEN SANK_IT=0.0 THEN NULL ELSE SANK_IT END AS SANK_IT 
FROM cteZSL
----------------------------VMP----------------------------------
;WITH cteVMP
AS
(
	SELECT id AS idFile,rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate AS NPR_DATE,l.mcod AS LPU,DATE_Z_1,Date_Z_2,KD_Z,RSLT
			,ISHOD, IDSP,AmountPayment AS SUMV,SUM(ISNULL(p.AmountDeduction,0.0)) AS SANK_IT
	from dbo.t_260order_VMP o INNER JOIN vw_sprT001 l ON
				o.LPU=l.CodeM
								LEFT JOIN dbo.t_DirectionDate dd ON
				o.rf_idCase = dd.rf_idCase
								LEFT JOIN dbo.t_PaymentAcceptedCase2 p ON
					o.rf_idCase=p.rf_idCase
	GROUP BY o.id ,o.rf_idRecordCasePatient,N_ZAP, IDCASE,USL_OK,VIDPOM,FOR_POM,NPR_MO, dd.DirectionDate ,l.mcod ,DATE_Z_1,Date_Z_2,KD_Z,RSLT,ISHOD,IDSP,o.AmountPayment
)
SELECT  idFile ,rf_idRecordCasePatient ,N_ZAP ,IDCASE ,USL_OK ,VIDPOM ,FOR_POM ,NPR_MO ,NPR_DATE ,LPU ,DATE_Z_1 ,Date_Z_2 ,KD_Z ,RSLT ,ISHOD ,IDSP ,SUMV 
		,CASE WHEN SANK_IT=0.0 THEN NULL ELSE SANK_IT END AS SANK_IT 
FROM cteVMP