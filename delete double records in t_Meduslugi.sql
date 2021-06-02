USE AccountOMSReports
GO
SELECT  rf_idCase ,id , GUID_MU , rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,
        MUGroupCode ,MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MU ,MUSurgery ,MUInt
--INTO tmp_Meduslugi        
FROM dbo.t_Meduslugi
GROUP BY  rf_idCase ,id , GUID_MU , rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,
        MUGroupCode ,MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MU ,MUSurgery ,MUInt
HAVING COUNT(*)>1        

SELECT @@ROWCOUNT

BEGIN TRANSACTION
DELETE FROM dbo.t_Meduslugi 
FROM dbo.t_Meduslugi m INNER JOIN dbo.tmp_Meduslugi m1 ON
			m.rf_idCase=m1.rf_idCase
			AND m.GUID_MU=m1.GUID_MU

INSERT dbo.t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,MUGroupCode ,
						MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MUSurgery)
SELECT rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,DiagnosisCode ,MUGroupCode ,
						MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MUSurgery
FROM tmp_Meduslugi

commit
ROLLBACK
