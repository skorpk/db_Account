USE AccountOMS
GO
CREATE TABLE #LPU(CodeM VARCHAR(6), filialName VARCHAR(50),MOName VARCHAR(250), FilialId int)
INSERT #LPU (CodeM,filialName,MOName,FilialId) 
SELECT CodeM,filialName,NAMES,FilialId FROM dbo.vw_sprT001 WHERE filialCode=1
--SET STATISTICS TIME ON
--SELECT  c.id AS CaseId
--					,c.idRecordCase AS ������ 	
--					,c.AmountPayment AS ���������� 
--					,v6.Name AS ���������������
--					,v8.Name AS ���������
--                    ,'���������� �������' AS �����������
--                    ,CAST(CASE WHEN c.HopitalisationType = 1 THEN '��������' ELSE '����������' END AS varchar(20)) AS ����������������� 
--                    ,v2.name AS �������
--                    ,CAST(CASE WHEN c.IsChildTariff = 0 THEN '��������' ELSE '�������' END AS VARCHAR(20)) AS ����� 
--					,c.NumberHistoryCase AS ���������� 
--					,c.DateBegin AS ����� 
--					,c.DateEnd AS �������
--					,'���������� �������' AS ���������
--                    ,'���������� �������' AS �����
--                    ,'���������� �������' AS �������������������������
--                    ,v10.Name AS ������������
--                    ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as �������      
--					,v5.Name AS ��� 
--					,rp.BirthDay AS ������������
--					,c.age AS ������� 
--					,rp.BirthPlace AS �������������
--					,'���������� �������' AS �������������
--					,'���������� �������' AS ������������ 
--                    ,'���������� �������' AS ����� 
--                    ,'���������� �������' AS ����� 
--                    ,'���������� �������' AS ����� 
--					,rcp.SeriaPolis AS ����������� 
--				    ,rcp.NumberPolis AS ����������� 
--					,f.DateRegistration AS ��������������� 
--					,mo.filialName AS ������ 
--					,f.CodeM AS CodeMO 				
--					,mo.FilialId AS CodeFilial 
--					,mo.MOName AS �� 
--                    ,d.DS1 AS ����������� 
--                    ,mkb.Diagnosis AS ������� 
--                    ,'���������� �������' AS ���������������� 
--                    ,'���������� �������' AS �������������������� 
--				    ,ra.Account AS accountnumber 
--				    ,ra.[DateRegister] AS accountdate 
--				    ,rcp.[AttachLPU] AS attachMO
--				    ,c.rf_idDoctor as ����������
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
					,c.idRecordCase AS ������ 	
					,c.AmountPayment AS ���������� 
                    ,c.HopitalisationType
                    ,c.IsChildTariff 
					,c.NumberHistoryCase AS ���������� 
					,c.DateBegin AS ����� 
					,c.DateEnd AS �������				
                    ,rp.Fam + ' ' + rp.Im + ' ' + ISNULL(rp.Ot,'') as �������      
					,rp.BirthDay AS ������������
					,c.age AS ������� 
					,rp.BirthPlace AS �������������					
					,rcp.SeriaPolis AS ����������� 
				    ,rcp.NumberPolis AS ����������� 
					,f.DateRegistration AS ��������������� 
					,mo.filialName AS ������ 
					,f.CodeM AS CodeMO 				
					,mo.FilialId AS CodeFilial 
					,mo.MOName AS �� 
                    ,d.DS1 AS ����������� 		                       
				    ,ra.Account AS accountnumber 
				    ,ra.[DateRegister] AS accountdate 
				    ,rcp.[AttachLPU] AS attachMO
				    ,c.rf_idDoctor as ����������
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