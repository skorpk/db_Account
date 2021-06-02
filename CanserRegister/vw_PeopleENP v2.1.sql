USE CanserRegister
GO
ALTER VIEW vw_PeopleENP
as
SELECT e.id,e.ENP, e.Fam+' '+e.Im+' '+ISNULL(e.Ot,'') AS FIO, BirthYear, e.Sex
		--, CASE WHEN d.DS_ONK=1 THEN 'Да' ELSE 'Нет' END AS DS_ONK
		, CASE WHEN d.DS_ONK=1 THEN 1 ELSE 0 END AS DS_ONK
		, CASE WHEN d.DS_ONK=1 THEN d.DateDS_ONK ELSE null END AS Date_DS_ONK
		,b.DirectionDate
		,n.NAPR_DATE, n.N_MET
		, ds.Diagnosis,ds.DateSetup
		,s.KOD_St AS Stad
		,pc.DateEnd AS DateEnd_PCEL
		,CASE WHEN l.USL_TIP=1 then l.DateEnd ELSE NULL end	AS DateEndONK_Hir
		------------------------------------------------------------------------
		,CASE WHEN l.USL_TIP=2 then l.DateEnd ELSE NULL end	AS DateEndONK_Lek
		------------------------------------------------------------------------
		,CASE WHEN l.USL_TIP=3 then l.DateEnd ELSE NULL end	AS DateEndONK_Luch
		------------------------------------------------------------------------
		,CASE WHEN l.USL_TIP=4 then l.DateEnd ELSE NULL end	AS DateEndONK_Chem
		,sm.CodeSMO+' - '+sm.sNameS AS SMO
		,pe.DateEnd
		,CASE WHEN pe.typeEnd=1 THEN 'Отсутствие страхование в ВО' WHEN pe.typeEnd=2 THEN 'Смерть' ELSE null END AS StopType
		,ISNULL(typeEnd,0) AS TypeEnd
FROM dbo.t_PeopleEnp e LEFT JOIN dbo.t_PeopleDS_ONK d ON	
			e.id=d.rf_idPeopleENP
						LEFT JOIN dbo.t_PeopleBiopsy b ON
			e.id=b.rf_idPeopleENP                        
						LEFT JOIN dbo.vw_PeopleNAPR n ON
			e.id=n.rf_idPeopleENP
						LEFT JOIN dbo.vw_PeopleDiagnosis ds ON
			e.id=ds.rf_idPeopleENP     
						LEFT JOIN dbo.vw_PeopleSTAD s ON
			e.id=s.rf_idPeopleENP                   
						LEFT JOIN dbo.t_PeoplePCEL pc ON
			e.id=pc.rf_idPeopleENP                        
						LEFT JOIN dbo.vw_PeopleONK_USL l ON
			e.id=l.rf_idPeopleENP       
						LEFT JOIN dbo.vw_PeopleSMO sm ON
			e.id=sm.rf_idPeopleENP
						LEFT JOIN dbo.t_PeopleEND pe ON
			e.id=pe.rf_idPeopleENP            
GO