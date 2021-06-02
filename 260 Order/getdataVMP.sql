USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=1,
		@fileName VARCHAR(26)='TT34_19013'

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'

DELETE FROM dbo.t_260order_VMP WHERE [YEAR]=@reportYear AND [MONTH]=@reportMonth


INSERT dbo.t_260order_VMP( id ,[VERSION] ,DATA ,[FILENAME] ,CODE ,CODE_MO ,[YEAR] ,[MONTH] ,Account ,DateRegister ,PLAT ,SUMMAV ,rf_idRecordCasePatient ,N_ZAP ,IsNew ,ID_PAC ,VPOLIS ,SPOLIS ,NPOLIS ,
					ST_OKATO ,rf_idSMO ,SMO_OGRN ,SMO_OK ,SMO_NAM ,MSE ,NOVOR ,BirthWeight ,IDCASE ,USL_OK ,VIDPOM ,FOR_POM ,NPR_MO ,LPU ,DATE_Z_1 ,Date_Z_2 ,KD_Z ,RSLT ,ISHOD ,IDSP ,AmountPayment ,
					rf_idCase ,GUID_Case ,VID_HMP ,METOD_HMP ,LPU_1 ,PODR ,rf_idV002 ,PROFIL_K ,DET ,TAL_D ,TAL_NUM ,TAL_P ,NHISTORY ,DATE_1 ,DATE_2 ,DS1 ,C_ZAB ,DS_ONK ,PRVS ,VERS_SPEC ,IDDOKT ,
					Quantity ,Tariff ,SUM_M)
SELECT distinct f.id, '3.1' AS [VERSION],CAST(GETDATE() AS DATE) AS DATA,@fileName AS [FILENAME], a.id AS CODE,a.rf_idMO AS CODE_MO, @reportYear AS [YEAR], @reportMonth AS [MONTH]
		,a.Account,a.DateRegister,a.rf_idSMO AS PLAT,a.AmountPayment AS SUMMAV, 
		--------------ZAP/PACIENT----------------
		r.id AS rf_idRecordCasePatient,r.idRecord AS N_ZAP,r.IsNew, r.ID_Patient AS ID_PAC,r.rf_idF008 AS VPOLIS,
		r.SeriaPolis AS SPOLIS, r.NumberPolis AS NPOLIS,ps.ST_OKATO AS ST_OKATO,ps.rf_idSMO,ps.OGRN AS SMO_OGRN, ps.OKATO AS SMO_OK,ps.Name AS SMO_NAM,r.MSE,r.NewBorn AS NOVOR
		,r.BirthWeight
		--------------Z_SL----------------------
		,cc.idRecordCase AS IDCASE,c.rf_idV006 AS USL_OK,c.rf_idV008 AS VIDPOM,c.rf_idV014 AS FOR_POM,c.rf_idDirectMO AS NPR_MO,c.rf_idMO AS LPU, cc.DateBegin AS DATE_Z_1, cc.DateEnd AS Date_Z_2
		,cc.HospitalizationPeriod AS KD_Z,c.rf_idV009 AS RSLT, c.rf_idV012 AS ISHOD,c.rf_idV010 AS IDSP, cc.AmountPayment
		-------------SL---------------------
		,c.id AS rf_idCase,c.GUID_Case,c.rf_idV018 AS VID_HMP, c.rf_idV019 AS METOD_HMP,c.rf_idSubMO AS LPU_1, c.rf_idDepartmentMO AS PODR,c.rf_idV002, b.rf_idV020 AS PROFIL_K, c.IsChildTariff AS DET,
		s.DateHospitalization AS TAL_D, s.NumberTicket AS TAL_NUM, s.GetDatePaper AS TAL_P, c.NumberHistoryCase AS NHISTORY, c.DateBegin AS DATE_1,c.DateEnd AS DATE_2, d.DS1,c.C_ZAB,dso.DS_ONK
		,c.rf_idV004 AS PRVS, 'V021' AS VERS_SPEC, c.rf_idDoctor AS IDDOKT,m.Quantity,m.Tariff, c.AmountPayment	 AS SUM_M

FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCasePatient
					INNER JOIN dbo.t_Case c  ON
			r.id=c.rf_idRecordCasePatient
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase
					INNER JOIN #tD dd ON
			d.DS1=dd.DiagnosisCode     
					INNER JOIN dbo.t_ProfileOfBed b ON
			c.id=b.rf_idCase       
					INNER JOIN dbo.t_SlipOfPaper s ON
			c.id=s.rf_idCase      
					 INNER JOIN dbo.t_DS_ONK_REAB dso ON
			c.id=dso.rf_idCase                   
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  
					INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase                
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth=@reportMonth AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34' 
		AND c.rf_idV006<4 AND c.rf_idV008=32
GO
DROP TABLE #tD
