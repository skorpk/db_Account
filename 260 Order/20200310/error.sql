USE AccountOMS
GO
---------------------Случай с DIAG_CODE=1-----
SELECT o.Account,o.LPU,o.rf_idCase,s.*
FROM dbo.t_260order_ONK o inner JOIN dbo.t_ONK_SL s ON
		o.rf_idCase=s.rf_idCase
WHERE GUID_Case='9F9E07B1-1027-3484-E053-02057DC19ECF'


--SELECT  DIAG_DATE ,DIAG_TIP ,DIAG_CODE ,DIAG_RSLT ,REC_RSLT 
--FROM dbo.vw_B_DIAG260_ONK WHERE rf_idONK_SL=246198

--SELECT *
--FROM oms_nsi.dbo.sprN009 WHERE DS_Mrf='C44'

-----------------------Есть NPR_DATE и нет NPR_MO--------------------------------------
SELECT o.Account,o.LPU,o.rf_idCase, o.USL_OK,o.rf_idRecordCasePatient
FROM dbo.t_260order_ONK o 
WHERE GUID_Case='9FD982FD-0232-412D-E053-02057DC1E7E0'

SELECT * FROM dbo.vw_Z_SL260_ONK WHERE rf_idRecordCasePatient=113154944
--------------------------------------Случай у которых в качестве МО стоит 000000------------------

SELECT rf_idCase
FROM dbo.t_260order_ONK 
WHERE GUID_Case IN('20927928-AEC0-4924-A84A-4D77B1D394FA','157CB0CC-086A-3703-02D2-CF01DF87380C','98FA6F11-A647-0C22-E053-CD9115AC5C3B','98F112A9-0110-0C24-E053-CD9115AC4C69',		'98F112A9-012D-0C24-E053-CD9115AC4C69',	'98F112A9-0161-0C24-E053-CD9115AC4C69',	'C4C57C61-9053-5C08-D753-46518992904E',	'43D2D227-2453-3380-7863-DA91E197F079')

SELECT c.rf_idRecordCasePatient,c.rf_idDoctor,c.GUID_Case,c.rf_idMO, m.*
FROM dbo.t_Case c INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase
WHERE c.id IN(112485340,112952021,112126314,113193435,113278385,113278420,113278491,113287280) AND m.rf_idDoctor IS NULL

