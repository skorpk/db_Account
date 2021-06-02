USE AccountOMS
GO
DECLARE  @p_StartDate datetime=N'20141202',
		 @p_EndDate datetime=N'20150601',
		 @p_FilialCode tinyint=4,
		 @p_LPUCode VARCHAR(6)='451001',
		 @p_LPUManualEnteredCode INT = -1

create TABLE #lpu(CodeM CHAR(6),MOName VARCHAR(100), FilialId TINYINT,filialName VARCHAR(50))

SELECT @p_FilialCode =CASE WHEN @p_FilialCode = -1 THEN NULL ELSE (SELECT filialCode FROM dbo.vw_sprFilial WHERE FilialId=@p_FilialCode) end
   ,@p_LPUCode =CASE WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode=-1 THEN NULL 
       WHEN @p_LPUCode=-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode 
       WHEN @p_LPUCode>-1 AND @p_LPUManualEnteredCode>-1 THEN @p_LPUManualEnteredCode
    ELSE @p_LPUCode END
  ,@p_EndDate=@p_EndDate+' 23:59:59'  
    
   
INSERT #LPU
 SELECT CodeM, [NAMES], filialCode,filialName 
 FROM dbo.vw_sprT001 
 WHERE CodeM=ISNULL(@p_LPUCode,codeM) AND filialCode=ISNULL(@p_FilialCode,filialCode)
 ORDER BY CodeM

SET STATISTICS TIME ON 
 SELECT  c.id AS CaseId
     ,c.idRecordCase AS Случай  
     ,c.AmountPayment AS Выставлено 
     ,v6.Name AS УсловияОказания
     ,v8.Name AS ВидПомощи
                    ,dmo.NAM_MOK AS Направление
                    ,CAST(CASE WHEN c.HopitalisationType = 1 THEN 'Плановая' ELSE 'Экстренная' END AS varchar(20)) AS ТипГоспитализации 
                    ,v2.name AS Профиль
                    ,CAST(CASE WHEN c.IsChildTariff = 0 THEN 'Взрослый' ELSE 'Детский' END AS VARCHAR(20)) AS Тариф 
     ,c.NumberHistoryCase AS НомерКарты 
     ,c.DateBegin AS Начат 
     ,c.DateEnd AS Окончен
     ,v9.Name AS Результат
                    ,v12.Name AS Исход
                    ,v4.Name AS СпециальностьМедРаботника
                    ,v10.Name AS СпособОплаты
                    ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as Пациент      
     ,v5.Name AS Пол 
     ,rp.BirthDay AS ДатаРождения
     ,c.age AS Возраст 
     ,rp.BirthPlace AS МестоРождения
     ,rpa.Fam + ' ' + rpa.Im + ' ' + rpa.Ot AS Представитель
     ,dt.Name AS ТипДокумента 
                    ,rpd.SeriaDocument AS Серия 
                    ,RTRIM(rpd.NumberDocument) AS Номер 
                    ,rpd.SNILS AS СНИЛС 
     ,rcp.SeriaPolis AS СерияПолиса 
        ,rcp.NumberPolis AS НомерПолиса 
     ,f.DateRegistration AS ДатаРегистрации 
     ,mo.filialName AS Филиал 
     ,f.CodeM AS CodeMO     
     ,mo.FilialId AS CodeFilial 
     ,mo.MOName AS МО 
                    ,d.DS1 AS КодДиагноза 
                    ,mkb.Diagnosis AS Диагноз 
                    ,okato1.namel AS АдресРегистрации 
                    ,okato2.namel  AS АдресМестаЖительства 
        ,ra.Account AS accountnumber 
        ,ra.[DateRegister] AS accountdate 
        ,rcp.[AttachLPU] AS attachMO
  FROM   dbo.t_File f 
  INNER JOIN #LPU AS mo ON f.CodeM = mo.CodeM 
  INNER JOIN dbo.t_RegistersAccounts ra ON f.id=ra.rf_idFiles AND ra.PrefixNumberRegister<>'34'
  INNER JOIN dbo.t_RecordCasePatient AS rcp ON ra.id=rcp.rf_idRegistersAccounts
  INNER JOIN dbo.t_Case c ON rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20150601 23:59:59'
  INNER JOIN dbo.t_RegisterPatient AS rp ON rp.rf_idRecordCase=rcp.id
        INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON c.rf_idV002 = v2.Id
        INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON c.rf_idV006 = v6.Id
        INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON c.rf_idV008 = v8.Id
        INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON c.rf_idV010 = v10.Id
        INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON rp.rf_idV005 = v5.Id
        INNER JOIN dbo.vw_Diagnosis AS d ON c.id = d.rf_idCase
        INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON mkb.DiagnosisCode = d.DS1
        
        LEFT JOIN OMS_NSI.dbo.sprMO AS dmo ON dmo.mcod = c.rf_idDirectMO
        LEFT JOIN OMS_NSI.dbo.sprV009 AS v9 ON c.rf_idV009 = v9.Id
        LEFT JOIN OMS_NSI.dbo.sprV012 AS v12 ON c.rf_idV012 = v12.Id
        LEFT JOIN dbo.t_RegisterPatientAttendant AS rpa ON rpa.rf_idRegisterPatient = rp.id
        LEFT JOIN dbo.t_RegisterPatientDocument AS rpd ON rpd.rf_idRegisterPatient = rp.id
        LEFT JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato1 on rpd.OKATO=okato1.okato
        LEFT JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato2 on rpd.OKATO_place=okato2.okato
        LEFT JOIN OMS_NSI.dbo.sprDocumentType AS dt ON rpd.rf_idDocumentType = dt.ID
        LEFT JOIN OMS_NSI.dbo.sprMedicalSpeciality AS v4 ON c.rf_idV004 = v4.Id	                      
  WHERE  f.DateRegistration >= '20141202' AND f.DateRegistration <='20150601 23:59:59'  AND v2.Id=97 AND v6.Id=2 AND rp.Fam='косов'

PRINT 'End 1'
PRINT 'Start 2'

SELECT  c.id AS CaseId
     ,c.idRecordCase AS Случай  
     ,c.AmountPayment AS Выставлено 
     ,c.rf_idV006
     ,c.rf_idV008
     ,c.rf_idDirectMO
     ,CAST(CASE WHEN c.HopitalisationType = 1 THEN 'Плановая' ELSE 'Экстренная' END AS varchar(20)) AS [ТипГоспитализации]
     ,c.rf_idV002
     ,CAST(CASE WHEN c.IsChildTariff = 0 THEN 'Взрослый' ELSE 'Детский' END AS VARCHAR(20)) AS [Тариф]
     ,c.NumberHistoryCase 
     ,c.DateBegin 
     ,c.DateEnd 
     ,c.rf_idV009
     ,c.rf_idV012 
     ,c.rf_idV004
     ,c.rf_idV010
     ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as Пациент      
     ,rp.rf_idV005
     ,rp.BirthDay
     ,c.age 
     ,rp.BirthPlace 
     ,rpa.Fam + ' ' + rpa.Im + ' ' + rpa.Ot AS Представитель
     ,rpd.rf_idDocumentType
     ,rpd.SeriaDocument 
     ,RTRIM(rpd.NumberDocument) AS NumberDocument
     ,rpd.SNILS 
     ,rcp.SeriaPolis 
     ,rcp.NumberPolis
     ,f.DateRegistration 
     ,mo.filialName 
     ,f.CodeM 
     ,mo.FilialId 
     ,mo.MOName 
	 ,d.DS1 
     ,rpd.OKATO
     ,rpd.OKATO_Place
     ,ra.Account 
     ,ra.[DateRegister]
     ,rcp.[AttachLPU] 
INTO #cte_cases
 FROM   dbo.t_File f INNER JOIN #LPU AS mo ON 
			f.CodeM = mo.CodeM 
					INNER JOIN dbo.t_RegistersAccounts ra ON 
			f.id=ra.rf_idFiles 
			AND ra.PrefixNumberRegister<>'34'
					INNER JOIN dbo.t_RecordCasePatient AS rcp ON 
			ra.id=rcp.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON 
			rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20150601 23:59:59'
					INNER JOIN dbo.t_RegisterPatient AS rp ON 
			rp.rf_idRecordCase=rcp.id
					INNER JOIN dbo.vw_Diagnosis d ON
			c.id=d.rf_idCase                  
					LEFT JOIN dbo.t_RegisterPatientAttendant rpa ON
			rp.id=rpa.rf_idRegisterPatient 
					LEFT JOIN dbo.t_RegisterPatientDocument AS rpd ON 
			rpd.rf_idRegisterPatient = rp.id                 
WHERE  f.DateRegistration >= '20141202' AND f.DateRegistration <='20150601 23:59:59'  AND c.rf_idV002=97 AND c.rf_idV006=2 AND rp.Fam='косов'

SELECT  c.CaseId ,
        c.Случай ,
        c.Выставлено,
		v6.Name AS УсловияОказания,
		v8.Name AS ВидМП,
		dmo.NAM_MOK AS Направление
        ,c.ТипГоспитализации 
        ,v2.name AS Профиль
        ,c.Тариф 
		,c.NumberHistoryCase AS НомерКарты 
		,c.DateBegin AS Начат 
		,c.DateEnd AS Окончен
		,v9.Name AS Результат
        ,v12.Name AS Исход
        ,v4.Name AS СпециальностьМедРаботника
        ,v10.Name AS СпособОплаты
        ,c.Пациент      
		,v5.Name AS Пол 
		,c.BirthDay AS ДатаРождения
        ,c.age AS Возраст 
		,c.BirthPlace AS МестоРождения
		,c.Представитель
		,dt.Name AS ТипДокумента 
        ,c.SeriaDocument AS Серия 
        ,c.NumberDocument AS Номер 
        ,c.SNILS AS СНИЛС 
		,c.SeriaPolis AS СерияПолиса 
        ,c.NumberPolis AS НомерПолиса 
		,c.DateRegistration AS ДатаРегистрации 
		,c.filialName AS Филиал 
		,c.CodeM AS CodeMO     
		,c.FilialId AS CodeFilial 
		,c.MOName AS МО 
        ,c.DS1 AS КодДиагноза 
        ,mkb.Diagnosis AS Диагноз 
        ,okato1.namel AS АдресРегистрации 
        ,okato2.namel  AS АдресМестаЖительства 
        ,c.Account AS accountnumber 
        ,c.[DateRegister] AS accountdate 
        ,c.[AttachLPU] AS attachMO
FROM #cte_cases c  INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON 
			c.rf_idV002 = v2.Id
				  INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON 
		    c.rf_idV006 = v6.Id
				  INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON 
			c.rf_idV008 = v8.Id
				  INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON 
		    c.rf_idV010 = v10.Id
				  INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON 
			c.rf_idV005 = v5.Id
				  INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON 
			mkb.DiagnosisCode = c.DS1
				  LEFT JOIN OMS_NSI.dbo.sprMO AS dmo ON 
		    c.rf_idDirectMO=dmo.mcod 
				  LEFT JOIN OMS_NSI.dbo.sprV009 AS v9 ON 
		   c.rf_idV009 = v9.Id
				LEFT JOIN OMS_NSI.dbo.sprV012 AS v12 ON 
		   c.rf_idV012 = v12.Id
				LEFT JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato1 on 
		   c.OKATO=okato1.okato
				LEFT JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato2 on 
		   c.OKATO_place=okato2.okato
				LEFT JOIN OMS_NSI.dbo.sprDocumentType AS dt ON 
		   c.rf_idDocumentType = dt.ID
				LEFT JOIN OMS_NSI.dbo.sprMedicalSpeciality AS v4 ON 
		   c.rf_idV004 = v4.Id	        
PRINT 'End'
go
DROP TABLE #lpu
DROP TABLE #cte_cases

