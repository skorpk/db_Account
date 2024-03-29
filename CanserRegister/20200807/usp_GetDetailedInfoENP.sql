USE [CanserRegister]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetDetailedInfoENP]    Script Date: 07.08.2020 9:26:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetDetailedInfoENP]
			@enp varchar(16)
as
SELECT distinct  c.rf_idCase ,c.CodeM +' - '+l.NAMES AS LPU,Account ,DateRegistr AS DateAccount,NumberCase ,DS1+' - '+mkb.Diagnosis AS Diagnosis
		,RTRIM(DS2)+' - '+mkb2.Diagnosis AS DS2,
        c.DateBegin ,c.DateEnd ,CASE WHEN DS_ONK=0 THEN 'Нет' ELSE 'Да' END AS DS_ONK ,v6.name AS USL_OK,v8.name AS Vid_MP,v9.name AS RSLT,m.MES+' - '+mu.name AS MES ,NULL P_CEL ,NULL AS DN
FROM dbo.t_PeopleCase c INNER JOIN dbo.vw_sprMKB10 mkb ON
			c.DS1=mkb.DiagnosisCode						
						INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM			                      
						INNER JOIN dbo.vw_sprV006 v6 ON
			c.USL_OK=v6.id     
						INNER JOIN dbo.vw_sprV008 v8 ON
			c.rf_idv008=v8.ID                 
						INNER JOIN dbo.vw_sprV009 v9 ON
			c.rf_idv009=v9.ID  
						INNER JOIN dbo.t_PeopleMES m ON
			c.rf_idCase=m.rf_idCase
						INNER JOIN dbo.vw_sprCSGAndCompletedMU mu ON
			m.MES=mu.MU            
						left JOIN dbo.vw_sprMKB10 mkb2 ON
			c.DS2=mkb2.DiagnosisCode          
WHERE c.ENP=@enp AND c.USL_OK<3
UNION ALL
SELECT distinct  rf_idCase ,c.CodeM +' - '+l.NAMES AS LPU,Account ,DateRegistr AS DateAccount,NumberCase ,DS1+' - '+mkb.Diagnosis AS Diagnosis
		,RTRIM(DS2)+' - '+mkb2.Diagnosis AS DS2,
        c.DateBegin ,c.DateEnd ,CASE WHEN DS_ONK=0 THEN 'Нет' ELSE 'Да' END AS DS_ONK ,v6.name AS USL_OK,v8.name AS Vid_MP,v9.name AS RSLT, NULL ,P_CEL 
		,CASE WHEN c.DS1 LIKE 'C%' AND P_CEL='1.3' THEN dn.NameDN ELSE NULL END AS DN
FROM dbo.t_PeopleCase c INNER JOIN dbo.vw_sprMKB10 mkb ON
			c.DS1=mkb.DiagnosisCode
						INNER JOIN dbo.vw_sprT001 l ON
			c.CodeM=l.CodeM			                      
						INNER JOIN dbo.vw_sprV006 v6 ON
			c.USL_OK=v6.id     
						INNER JOIN dbo.vw_sprV008 v8 ON
			c.rf_idv008=v8.ID                 
						INNER JOIN dbo.vw_sprV009 v9 ON
			c.rf_idv009=v9.ID  
						LEFT JOIN dbo.vw_sprDN dn ON
			c.DN=dn.id				
						left JOIN dbo.vw_sprMKB10 mkb2 ON
			c.DS2=mkb2.DiagnosisCode
WHERE ENP=@enp AND c.USL_OK>2
ORDER BY rf_idCase
