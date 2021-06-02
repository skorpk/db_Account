USE AccountOMS
GO
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
                    ,/*rpd.OKATO*/okato1.namel AS АдресРегистрации 
                    ,/*rpd.OKATO_place*/okato2.namel  AS АдресМестаЖительства 
				    ,ra.Account AS accountnumber 
				    ,ra.[DateRegister] AS accountdate 
				    ,rcp.[AttachLPU] AS attachMO
				    ,c.rf_idDoctor as СНИЛСВрача
				    ,RTRIM(rcp.[NewBorn]) as NewBorn
		FROM   dbo.t_File f 
		INNER JOIN #LPU AS mo ON f.CodeM = mo.CodeM	
		INNER JOIN dbo.t_RegistersAccounts ra ON f.id=ra.rf_idFiles AND ra.PrefixNumberRegister<>'34'
		INNER JOIN dbo.t_RecordCasePatient AS rcp ON ra.id=rcp.rf_idRegistersAccounts
		INNER JOIN dbo.t_Case c ON rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20161103 23:59:59'
		INNER JOIN dbo.t_RegisterPatient AS rp ON rp.rf_idRecordCase=rcp.id/*rp.[rf_idFiles]=f.id*//*rp.rf_idRecordCase = c.idRecordCase AND rp.rf_idFiles=f.id*/
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
        LEFT JOIN [dbo].[vw_sprMedicalSpeciality] v4 on c.rf_idV004=v4.id AND c.DateEnd>=v4.DateBeg AND c.DateEnd<v4.DateEnd

        														
		WHERE  f.DateRegistration >= '20161101' AND f.DateRegistration <='20161103 23:59:59'  AND v6.Id=3