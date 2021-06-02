USE AccountOMS
GO
CREATE TABLE #LPU(CodeM VARCHAR(6), filialName VARCHAR(50),MOName VARCHAR(250), FilialId int)
INSERT #LPU (CodeM,filialName,MOName,FilialId) 
SELECT CodeM,filialName,NAMES,FilialId FROM dbo.vw_sprT001 WHERE filialCode=1
--SET STATISTICS TIME ON
--SELECT  c.id AS CaseId
--					,c.idRecordCase AS Случай 	
--					,c.AmountPayment AS Выставлено 
--					,v6.Name AS УсловияОказания
--					,v8.Name AS ВидПомощи
--                    ,'Упрощенная выборка' AS Направление
--                    ,CAST(CASE WHEN c.HopitalisationType = 1 THEN 'Плановая' ELSE 'Экстренная' END AS varchar(20)) AS ТипГоспитализации 
--                    ,v2.name AS Профиль
--                    ,CAST(CASE WHEN c.IsChildTariff = 0 THEN 'Взрослый' ELSE 'Детский' END AS VARCHAR(20)) AS Тариф 
--					,c.NumberHistoryCase AS НомерКарты 
--					,c.DateBegin AS Начат 
--					,c.DateEnd AS Окончен
--					,'Упрощенная выборка' AS Результат
--                    ,'Упрощенная выборка' AS Исход
--                    ,'Упрощенная выборка' AS СпециальностьМедРаботника
--                    ,v10.Name AS СпособОплаты
--                    ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as Пациент      
--					,v5.Name AS Пол 
--					,rp.BirthDay AS ДатаРождения
--					,c.age AS Возраст 
--					,rp.BirthPlace AS МестоРождения
--					,'Упрощенная выборка' AS Представитель
--					,'Упрощенная выборка' AS ТипДокумента 
--                    ,'Упрощенная выборка' AS Серия 
--                    ,'Упрощенная выборка' AS Номер 
--                    ,'Упрощенная выборка' AS СНИЛС 
--					,rcp.SeriaPolis AS СерияПолиса 
--				    ,rcp.NumberPolis AS НомерПолиса 
--					,f.DateRegistration AS ДатаРегистрации 
--					,mo.filialName AS Филиал 
--					,f.CodeM AS CodeMO 				
--					,mo.FilialId AS CodeFilial 
--					,mo.MOName AS МО 
--                    ,d.DS1 AS КодДиагноза 
--                    ,mkb.Diagnosis AS Диагноз 
--                    ,'Упрощенная выборка' AS АдресРегистрации 
--                    ,'Упрощенная выборка' AS АдресМестаЖительства 
--				    ,ra.Account AS accountnumber 
--				    ,ra.[DateRegister] AS accountdate 
--				    ,rcp.[AttachLPU] AS attachMO
--				    ,c.rf_idDoctor as СНИЛСВрача
--				    ,RTRIM(rcp.[NewBorn]) as NewBorn
--				    ,[SMOKOD] + ' - ' + [NAM_SMOK] as SMO
--		FROM   dbo.t_File f 
--		INNER JOIN #LPU AS mo ON f.CodeM = mo.CodeM	
--		INNER JOIN dbo.t_RegistersAccounts ra ON f.id=ra.rf_idFiles AND ra.PrefixNumberRegister<>'34'
--		INNER JOIN dbo.t_RecordCasePatient AS rcp ON ra.id=rcp.rf_idRegistersAccounts
--		INNER JOIN dbo.t_Case c ON rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20170213 23:59:59'
--		INNER JOIN dbo.t_RegisterPatient AS rp ON rp.rf_idRecordCase=rcp.id/*rp.[rf_idFiles]=f.id*//*rp.rf_idRecordCase = c.idRecordCase AND rp.rf_idFiles=f.id*/
--        INNER JOIN OMS_NSI.dbo.sprV002 AS v2 ON c.rf_idV002 = v2.Id
--        INNER JOIN OMS_NSI.dbo.sprV006 AS v6 ON c.rf_idV006 = v6.Id
--        INNER JOIN OMS_NSI.dbo.sprV008 AS v8 ON c.rf_idV008 = v8.Id
--        INNER JOIN OMS_NSI.dbo.sprV010 AS v10 ON c.rf_idV010 = v10.Id
--        INNER JOIN OMS_NSI.dbo.sprV005 AS v5 ON rp.rf_idV005 = v5.Id
--        INNER JOIN dbo.vw_Diagnosis AS d ON c.id = d.rf_idCase
--        INNER JOIN OMS_NSI.dbo.sprMKB AS mkb ON mkb.DiagnosisCode = d.DS1
--        INNER JOIN [OMS_NSI].[dbo].[sprSMO] AS SMO ON ra.[rf_idSMO] = SMO.[SMOKOD]
     														
--		WHERE  f.DateRegistration >= '20170101' AND f.DateRegistration <='20170213 23:59:59'  AND v6.Id=3
--SET STATISTICS TIME OFF
PRINT 'My query'
SET STATISTICS TIME ON
-------------------------------
SELECT  c.id AS CaseId
					,c.idRecordCase AS Случай 	
					,c.AmountPayment AS Выставлено 
                    ,c.HopitalisationType
                    ,c.IsChildTariff 
					,c.NumberHistoryCase AS НомерКарты 
					,c.DateBegin AS Начат 
					,c.DateEnd AS Окончен				
                    ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as Пациент      
					,rp.BirthDay AS ДатаРождения
					,c.age AS Возраст 
					,rp.BirthPlace AS МестоРождения					
					,rcp.SeriaPolis AS СерияПолиса 
				    ,rcp.NumberPolis AS НомерПолиса 
					,f.DateRegistration AS ДатаРегистрации 
					,mo.filialName AS Филиал 
					,f.CodeM AS CodeMO 				
					,mo.FilialId AS CodeFilial 
					,mo.MOName AS МО 
                    ,d.DS1 AS КодДиагноза 		                       
				    ,ra.Account AS accountnumber 
				    ,ra.[DateRegister] AS accountdate 
				    ,rcp.[AttachLPU] AS attachMO
				    ,c.rf_idDoctor as СНИЛСВрача
				    ,RTRIM(rcp.[NewBorn]) as NewBorn
		FROM   dbo.t_File f 
		INNER JOIN #LPU AS mo ON f.CodeM = mo.CodeM	
		INNER JOIN dbo.t_RegistersAccounts ra ON f.id=ra.rf_idFiles AND ra.PrefixNumberRegister<>'34'
		INNER JOIN dbo.t_RecordCasePatient AS rcp ON ra.id=rcp.rf_idRegistersAccounts
		INNER JOIN dbo.t_Case c ON rcp.id=c.rf_idRecordCasePatient AND c.DateEnd<'20170213 23:59:59'
		INNER JOIN dbo.t_RegisterPatient AS rp ON rp.rf_idRecordCase=rcp.id        
        INNER JOIN dbo.vw_Diagnosis AS d ON c.id = d.rf_idCase
		WHERE  f.DateRegistration >= '20170101' AND f.DateRegistration <='20170213 23:59:59'  AND c.rf_idV006=3
SET STATISTICS TIME OFF
GO
DROP TABLE #LPU