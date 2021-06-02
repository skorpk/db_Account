USE AccountOMS
GO
DECLARE @dateStart DATETIME='20190101',
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=1,
		@fileName VARCHAR(26)='CT34_19012' --им€ файла мен€ем руками

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'
   
--DELETE FROM dbo.t_260order_ONK WHERE [YEAR]=@reportYear AND [MONTH]=@reportMonth
--‘ормируем »м€ файла
IF NOT exists(SELECT NumberPackage FROM dbo.t_260order_ONK WHERE [Year]=@reportYear AND [MONTH]=@reportMonth)
BEGIN
	SELECT @fileName=@fileName+RIGHT(CAST(@reportYear AS CHAR(4)),2)+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'1'
END 
ELSE
BEGIN
	SELECT DISTINCT @fileName=@fileName+RIGHT(CAST(@reportYear AS CHAR(4)),2)+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+ CAST(NumberPackage+1 AS VARCHAR(2)) FROM dbo.t_260order_ONK 
	WHERE [Year]=@reportYear AND [MONTH]=@reportMonth
end


INSERT dbo.t_260order_ONK( id ,[VERSION] ,DATA ,[FILENAME] ,CODE ,CODE_MO ,[YEAR] ,[MONTH] ,Account ,DateRegister ,PLAT ,SUMMAV ,rf_idRecordCasePatient ,N_ZAP ,IsNew ,ID_PAC ,VPOLIS ,SPOLIS ,NPOLIS ,
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
					 INNER JOIN dbo.t_DS_ONK_REAB dso ON
			c.id=dso.rf_idCase                   
					INNER JOIN dbo.t_PatientSMO ps ON
			r.id=ps.rf_idRecordCasePatient  
					left JOIN dbo.t_MES m ON
			c.id=m.rf_idCase     
					left JOIN dbo.t_SlipOfPaper s ON
			c.id=s.rf_idCase           
					left JOIN dbo.t_ProfileOfBed b ON
			c.id=b.rf_idCase     					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportMonth=@reportMonth AND a.ReportYear=@reportYear AND a.rf_idSMO<>'34' 
		AND c.rf_idV006<4 AND c.rf_idV008<>32

-----------------ћен€ем способ оплаты-------------
--UPDATE dbo.t_260order_ONK SET IDSP=33 WHERE IDSP=43
--UPDATE dbo.t_260order_ONK SET IDSP=29 WHERE IDSP=41
--UPDATE dbo.t_260order_ONK SET IDSP=28 WHERE IDSP=4
UPDATE o SET IDSP=p.Code_new
FROM dbo.t_260order_ONK o INNER JOIN dbo.V_PaymentMethodRelation p ON
		o.IDSP=p.Code_old 

---удал€ю плохие случай т.е. в которых даты сто€т меньше 01.01.1850
DELETE FROM dbo.t_260order_ONK WHERE rf_idCase IN(90656454,91053522,91421686,95520266,95534666,95808460,95810959,95993430,96055185,96029612,96336813)
----удал€ю случай  у которых нету CONS
DELETE FROM dbo.t_260order_ONK WHERE rf_idCase IN (95421890,95421891,95421892,95421895,95421898,95421899,95421902,95421907,95488792,95488802,95488817,95488846,95488860,
	95488861,95488865,95488872,95488875,95488886,95488888,95571205,95907718,95908015,95908026,95908054,95908145,95908186,
	95908207,95908225,95908244,95908267,95908317,95908333,95908335,95908367,95908404,95908415,95908581,95908643,95926121,
	95473249,95473250,95473251,95473252,95473253,95473254,95473255,95473256,95473257,95473258,95473259,95473260,95473261,
	95473262,95473263,95473264,95473265,95473266,95927438)

DELETE FROM dbo.t_260order_ONK WHERE rf_idCase IN (95562823,95562825,95562823,95562824,95562825,95606184,95663715,95663793,95713644,95713644,95719676,95785441,95785441,95785441,95785441,96047579,96047579,96057226)
DELETE FROM dbo.t_260order_ONK WHERE rf_idCase IN (96331354,96331355,96331356,96331357)

SELECT @@ROWCOUNT
GO
DROP TABLE #tD
