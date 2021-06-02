USE AccountOMS
GO
ALTER PROCEDURE usp_GetDataOrder260_ONK
			@reportYear SMALLINT,
			@reportMonth TINYINT
as

SELECT t.colXML from(
SELECT 
	(SELECT RTRIM([VERSION]) [VERSION],DATA,FILENAME,COUNT(DISTINCT rf_idRecordCasePatient) AS SD_Z 
		FROM dbo.t_260order_ONK WHERE [YEAR]=@reportYear AND [Month]=@reportMonth 
		GROUP BY [VERSION],DATA,FILENAME
		FOR XML PATh('ZGLV'),TYPE
	),
	(
		SELECT CODE ,CODE_MO ,YEAR ,MONTH ,NSCHET ,DSCHET ,PLAT ,SUMMAV,SUMMAV AS SUMMAP
		,(SELECT N_ZAP ,
				PR_NOV ,(SELECT  ID_PAC ,VPOLIS ,SPOLIS ,RTRIM(NPOLIS) 'NPOLIS' ,SMO ,RTRIM(NOVOR) 'NOVOR' FROM dbo.vw_Pacient260_ONK WHERE idFile=z.idFile AND rf_idRecordCasePatient=z.rf_idRecordCasePatient  FOR XML PATH ('PACIENT'), TYPE)
				,(SELECT IDCASE ,USL_OK ,VIDPOM ,FOR_POM ,NPR_MO ,NPR_DATE ,LPU ,DATE_Z_1 ,DATE_Z_2 ,KD_Z ,RSLT ,ISHOD ,VB_P
					,(  SELECT  SL_ID ,LPU_1,PODR,PROFIL,PROFIL_K  ,DET,P_CEL,NHISTORY ,P_PER,DATE_1 ,DATE_2 ,KD,
							RTRIM(DS1) 'DS1' ,C_ZAB,DS_ONK,DN 
									,(
										SELECT  NAPR_DATE ,NAPR_MO ,NAPR_V ,MET_ISSL ,NAPR_USL
			  /*NAPR*/				    FROM dbo.vw_NAPR260_ONK n WHERE n.rf_idCase=zz.rf_idCase FOR XML PATH('NAPR'),TYPE 
									  )
							,(
											SELECT  PR_CONS ,DT_CONS FROM dbo.vw_Cons260_ONK c WHERE c.rf_idCase=zz.rf_idCase FOR XML PATH('CONS'),TYPE
							)
							 ,
							 (
								SELECT DS1_T ,STAD ,ONK_T ,ONK_N ,ONK_M ,MTSTZ ,SOD ,K_FR ,WEI ,HEI ,BSA
								,(
									SELECT  DIAG_DATE ,DIAG_TIP ,DIAG_CODE ,DIAG_RSLT ,REC_RSLT 
									FROM dbo.vw_B_DIAG260_ONK WHERE rf_idONK_SL=s1.id FOR XML PATH('B_DIAG'),TYPE
								  )
								  ,
								  (
									SELECT  PROT ,D_PROT FROM dbo.vw_B_PROT260_ONK WHERE rf_idONK_SL=s1.id FOR XML PATH('B_PROT'),TYPE
								  )
								  ,
								  (
									SELECT  USL_TIP ,HIR_TIP ,LEK_TIP_L ,LEK_TIP_V,
									(
										SELECT  REGNUM ,CODE_SH ,DATE_INJ
										FROM dbo.vw_LEK_PR260_ONK WHERE rf_idONK_SL=ou.rf_idONK_SL AND USL_TIP=ou.USL_TIP 
										FOR XML PATH('LEK_PR'),TYPE
									) 
									,LUCH_TIP ,PPTR
									 FROM dbo.vw_ONK_USL260_ONK ou
									 WHERE rf_idONK_SL=s1.id FOR XML PATH('ONK_USL'),TYPE
								  )
								FROM dbo.vw_ONK_SL260_ONK s1 WHERE s1.rf_idCase=zz.rf_idCase FOR XML PATH('ONK_SL'),TYPE
							  )
					-------------------------------------------------------------/*KSG_KPG*/  ---------------------------------
								,(
									SELECT  N_KSG ,VER_KSG ,KSG_PG ,KOEF_Z ,KOEF_UP ,BZTSZ ,KOEF_D ,KOEF_U 
									,(SELECT CRIT FROM dbo.vw_CRIT260_ONK WHERE rf_idCase=kk.rf_idCase FOR XML PATH(''),TYPE )
									,SL_K ,IT_SL,
									(
										SELECT  IDSL ,Z_SL FROM dbo.vw_SL_KOEF260_ONK WHERE rf_idCase=kk.rf_idCase FOR XML PATH('SL_KOEF'),TYPE
									)
									 FROM dbo.vw_KSG_KPG260_ONK kk WHERE kk.rf_idCase= zz.rf_idCase FOR XML PATH('KSG_KPG'),TYPE
								)
								---------------------------------------------
							,REAB,PRVS ,VERS_SPEC ,IDDOKT ,ED_COL ,TARIF ,SUM_M,
							(
								SELECT  IDSERV ,LPU ,PROFIL ,VID_VME ,DET ,DATE_IN ,DATE_OUT ,RTRIM(DS) 'DS' ,CODE_USL ,KOL_USL ,TARIF ,SUMV_USL , PRVS ,RTRIM(CODE_MD) 'CODE_MD' 
								FROM dbo.vw_USL260_ONK u 
								WHERE u.rf_idCase=zz.rf_idCase FOR XML PATH('USL'),TYPE
							)
						FROM dbo.vw_SL260_ONK zz
						WHERE rf_idRecordCasePatient=ss.rf_idRecordCasePatient FOR XML PATH('SL'),TYPE
					) ,IDSP ,SUMV, SUMV AS SUMP
				  FROM dbo.vw_Z_SL260_ONK ss
				  WHERE idFile=z.idFile AND N_ZAP=z.N_ZAP  FOR XML PATH ('Z_SL'), TYPE)
		  FROM dbo.vw_ZAP260_ONK z
		  WHERE idFile=t.id  FOR XML PATH ('ZAP'), TYPE)
		FROM dbo.vw_Account260_ONK t
		WHERE [YEAR]=@reportYear AND [MONTH]=@reportMonth
		FOR XML PATh('SCHET'),TYPE
		)
FOR XML PATH(''),TYPE,ROOT('ZL_LIST')  ) t(colXML)
----------------LTT
SELECT t.colXML from(
SELECT (SELECT distinct RTRIM([VERSION]) AS [VERSION],DATA,'L'+FILENAME 'FILENAME',FILENAME 'FILENAME1'
		FROM dbo.t_260order_ONK WHERE [YEAR]=@reportYear AND [Month]=@reportMonth 		
		FOR XML PATh('ZGLV'),TYPE
		)
	,(
		SELECT o.ID_PAC,p.rf_idV005 AS W, p.BirthDay AS DR
			,CASE WHEN tp.IsAttendant=1 THEN tp.TypeReliability ELSE NULL END AS DOST
			,ta.rf_idV005 AS W_P,ta.BirthDay AS DR_P
			,CASE WHEN tp.IsAttendant=2 THEN tp.TypeReliability ELSE NULL END AS DOST_P
			,p.BirthPlace AS MR
		FROM dbo.t_260order_ONK o INNER JOIN dbo.t_RegisterPatient p ON
				o.id = p.rf_idFiles
				AND o.rf_idRecordCasePatient=p.rf_idRecordCase
								LEFT JOIN dbo.t_ReliabilityPatient tp ON
				p.id=tp.rf_idRegisterPatient   
								LEFT JOIN dbo.t_RegisterPatientAttendant ta ON                   
				p.id=ta.rf_idRegisterPatient
		WHERE [YEAR]=@reportYear AND [MONTH]=@reportMonth
		FOR XML PATH('PERS'),TYPE
	  )
FOR XML PATH (''),TYPE,ROOT('PERS_LIST')) t(colXML)


SELECT DISTINCT [FILENAME],'L'+[FILENAME]	FROM dbo.t_260order_ONK WHERE [YEAR]=@reportYear AND [Month]=@reportMonth
go