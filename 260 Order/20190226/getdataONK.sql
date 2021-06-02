USE AccountOMS
GO
/*Учитывать РАК */
/*Учитывать РАК */
DECLARE @dateStart DATETIME='20190101',	--всегда с начало года
		@dateEnd DATETIME=GETDATE(),
		@reportYear SMALLINT=2019,
		@reportMonth TINYINT=2,--отчетный месяц ставим сами т.к. случаи отбираем с начало года
		@fileName VARCHAR(26)='CT34_' --имя файла меняем руками

SELECT DiagnosisCode INTO #tD FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0_' OR MainDS LIKE 'C__'

   
DELETE FROM dbo.t_260order_ONK WHERE [YEAR]=@reportYear AND [MONTH]=@reportMonth

--Формируем Имя файла
IF NOT exists(SELECT NumberPackage FROM dbo.t_260order_ONK WHERE [Year]=@reportYear AND [MONTH]=@reportMonth)
BEGIN
	SELECT @fileName=@fileName+RIGHT(CAST(@reportYear AS CHAR(4)),2)+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+'1'
END 
ELSE
BEGIN
	SELECT DISTINCT @fileName=@fileName+RIGHT(CAST(@reportYear AS CHAR(4)),2)+RIGHT('0'+CAST(@reportMonth AS VARCHAR(2)),2)+ CAST(NumberPackage+1 AS VARCHAR(2)) FROM dbo.t_260order_ONK 
	WHERE [Year]=@reportYear AND [MONTH]=@reportMonth
end
-------------------------------------------------------------------------------------------------------------
SELECT f.id, r.id AS rf_idRecordCasePatient, cc.AmountPayment,c.id AS rf_idCase, c.AmountPayment AS SUM_M 
INTO #tCases
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
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear 
		AND c.rf_idV006<4 AND c.rf_idV008<>32 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_260order_ONK WHERE rf_idCase=c.id)

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #tCases p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStart AND c.DateRegistration<@dateEnd	
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

-------------------------------------------------------------------------------------------------------------

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
					INNER JOIN #tCases t ON
			r.id=t.rf_idRecordCasePatient   
					left JOIN dbo.t_MES m ON
			c.id=m.rf_idCase     
					left JOIN dbo.t_SlipOfPaper s ON
			c.id=s.rf_idCase           
					left JOIN dbo.t_ProfileOfBed b ON
			c.id=b.rf_idCase     					      
WHERE f.DateRegistration>@dateStart AND f.DateRegistration<@dateEnd AND a.ReportYear=@reportYear 
		AND c.rf_idV006<4 AND c.rf_idV008<>32 		
		AND NOT EXISTS(SELECT 1 FROM dbo.t_260order_ONK WHERE rf_idCase=c.id) 
		AND t.AmountPayment>0.0

-----------------Меняем способ оплаты-------------
--UPDATE dbo.t_260order_ONK SET IDSP=33 WHERE IDSP=43
--UPDATE dbo.t_260order_ONK SET IDSP=29 WHERE IDSP=41
--UPDATE dbo.t_260order_ONK SET IDSP=28 WHERE IDSP=4

UPDATE o SET IDSP=p.Code_new
FROM dbo.t_260order_ONK o INNER JOIN dbo.V_PaymentMethodRelation p ON
		o.IDSP=p.Code_old 
---по иногородним добавляю код СМО
UPDATE v SET v.CodeSMO34= m.SMOKOD
FROM RegisterCases.dbo.t_RecordCase r INNER JOIN RegisterCases.dbo.t_Case c ON
			r.id=c.rf_idRecordCase
						INNER JOIN RegisterCases.dbo.t_RefCasePatientDefine rr ON
			c.id = rr.rf_idCase							
						INNER JOIN RegisterCases.dbo.t_CaseDefineZP1Found z ON
			rr.id=z.rf_idRefCaseIteration
						INNER JOIN oms_nsi.dbo.sprSMO m ON
			z.OGRN_SMO=m.OGRN                      
			AND z.OKATO=m.TF_OKATO
						INNER JOIN dbo.t_260order_ONK v ON
			r.ID_Patient=v.ID_PAC 
WHERE c.DateEnd>='20190101' AND v.rf_idSMO='34' AND v.CodeSMO34 IS null

--SELECT @@ROWCOUNT
GO
DROP TABLE #tD
DROP TABLE #tCases

