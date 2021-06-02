USE AccountOMS
GO
create TABLE #lpu(CodeM CHAR(6))
 
INSERT #LPU	SELECT CodeM FROM dbo.vw_sprT001 ORDER BY CodeM

SELECT  c.id AS rf_idCase,c.idRecordCase,c.AmountPayment,c.rf_idV006,c.rf_idV008,c.rf_idDirectMO
		,c.HopitalisationType ,c.rf_idV002,c.IsChildTariff ,c.NumberHistoryCase ,c.DateBegin ,c.DateEnd
		,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as Fio      
		,rp.Sex,rp.rf_idV005,rp.BirthDay ,c.age
		,rp.BirthPlace 
		,ISNULL(rpa.Fam,'') + ' ' + ISNULL(rpa.Im,'') + ' ' + ISNULL(rpa.Ot,'') AS PatientAttendant
		,rpd.rf_idDocumentType,rpd.SeriaDocument ,RTRIM(rpd.NumberDocument) AS NumDoc,rpd.SNILS 
		,rcp.SeriaPolis,rcp.NumberPolis ,f.DateRegistration,f.CodeM ,d.DS1 
        ,rpd.OKATO ,rpd.OKATO_Place,ra.Account ,ra.[DateRegister] ,rcp.[AttachLPU] ,c.rf_idDoctor, RTRIM(rcp.[NewBorn]) as NewBorn
INTO #tmp
FROM   dbo.t_File f INNER JOIN #LPU AS mo ON 
		f.CodeM = mo.CodeM	
					INNER JOIN dbo.t_RegistersAccounts ra ON 
		f.id=ra.rf_idFiles 
		AND ra.PrefixNumberRegister<>'34'
					INNER JOIN dbo.t_RecordCasePatient AS rcp ON 
		ra.id=rcp.rf_idRegistersAccounts
					INNER JOIN dbo.t_Case c ON 
		rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20161103 23:59:59'
					INNER JOIN dbo.t_RegisterPatient AS rp ON 
		rp.rf_idRecordCase=rcp.id        
		AND f.id=rp.rf_idFiles
					INNER JOIN dbo.vw_Diagnosis AS d ON 
		c.id = d.rf_idCase        
					left JOIN dbo.t_RegisterPatientDocument AS rpd ON 
		rpd.rf_idRegisterPatient = rp.id
					LEFT JOIN dbo.t_RegisterPatientAttendant AS rpa ON 
		rpa.rf_idRegisterPatient = rp.id              
WHERE  f.DateRegistration >= '20161101' AND f.DateRegistration <='20161103 23:59:59'  AND c.rf_idV006=3

--CREATE NONCLUSTERED INDEX ix_okato ON #tmp(okato)

ALTER TABLE #tmp ADD AddressReg VARCHAR(100)
ALTER TABLE #tmp ADD AddressPlace VARCHAR(100)

UPDATE t SET t.AddressReg=okato1.namel
from #tmp T INNER JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato1 on 
		t.OKATO=okato1.okato
			
UPDATE t SET t.AddressPlace=okato1.namel
from #tmp T INNER JOIN OMS_NSI.dbo.vw_Accounts_OKATO okato1 on 
		t.OKATO_Place=okato1.okato


SELECT c.rf_idCase AS CaseId
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
        ,c.Fio as Пациент      
		,v5.Name AS Пол 
		,c.BirthDay AS ДатаРождения
		,c.age AS Возраст 
		,c.BirthPlace AS МестоРождения
		,c.PatientAttendant AS Представитель
		,dt.Name AS ТипДокумента 
        ,c.SeriaDocument AS Серия 
        ,c.NumDoc AS Номер 
        ,c.SNILS AS СНИЛС 
		,c.SeriaPolis AS СерияПолиса 
		,c.NumberPolis AS НомерПолиса 
		,c.DateRegistration AS ДатаРегистрации 
		,l.filialName AS Филиал 
		,c.CodeM AS CodeMO 				
		,l.FilialId AS CodeFilial 
		,l.NAMES AS МО 
        ,c.DS1 AS КодДиагноза 
        ,mkb.Diagnosis AS Диагноз 
        ,c.AddressReg
        ,c.AddressPlace
		,c.Account AS accountnumber 
		,c.[DateRegister] AS accountdate 
		,c.AttachLPU AS attachMO
		,c.rf_idDoctor as СНИЛСВрача
		,c.[NewBorn] 
FROM #tmp c INNER JOIN t_Case c1 ON
		c.rf_idCase=c1.id
			INNER JOIN vw_sprT001 l ON
		c.CodeM=l.CodeM          
			INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON 
		c.rf_idV002 = v2.Id
			INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON 
		c.rf_idV006 = v6.Id
			INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON 
		c.rf_idV008 = v8.Id
			INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON 
		c1.rf_idV010 = v10.Id
			INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON 
		c.rf_idV005 = v5.Id
		    INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON 
		c.DS1=mkb.DiagnosisCode			
			INNER JOIN OMS_NSI.dbo.sprV009 AS v9 ON 
		c1.rf_idV009 = v9.Id
			INNER JOIN OMS_NSI.dbo.sprV012 AS v12 ON 
		c1.rf_idV012 = v12.Id
			left JOIN OMS_NSI.dbo.sprDocumentType AS dt ON 
		c.rf_idDocumentType = dt.ID  
			left JOIN [dbo].[vw_sprMedicalSpeciality] v4 on 
		c1.rf_idV004=v4.id 
		AND c.DateEnd>=v4.DateBeg 
		AND c.DateEnd<v4.DateEnd
			 LEFT JOIN OMS_NSI.dbo.sprMO AS dmo ON 
		c.rf_idDirectMO =dmo.mcod
			       	
GO 
DROP TABLE #tmp
DROP TABLE #lpu