USE AccountOMS
go
SELECT  id AS 'N_ZAP', rf_idF008 AS 'PACIENT/VPOLIS',SeriaPolis AS 'PACIENT/SPOLIS', RTRIM(NumberPolis) AS 'PACIENT/NPOLIS',rf_idV005 AS 'PACIENT/W', BirthDay AS 'PACIENT/DR',
		VZST AS 'PACIENT/VZST',id AS 'SLUCH/IDCASE',rf_idV014 AS 'SLUCH/FOR_POM',rf_idMO AS 'SLUCH/LPU',UnitOfHospital AS 'SLUCH/PODR',DateBegin AS 'SLUCH/DATE_1',
		DateEnd AS 'SLUCH/DATE_2',RTRIM(DS1) AS 'SLUCH/DS1',RTRIM(DS2) AS 'SLUCH/DS2',RTRIM(DS3) AS 'SLUCH/DS3', rf_idV009 AS 'SLUCH/RSLT',K_KSG AS 'SLUCH/K_KSG', KSG_PG AS 'SLUCH/KSG_PG'
		/*добавить DKK1 и DKK2*/
		,DKK1 AS 'SLUCH/DKK1'
		,DKK2 AS 'SLUCH/DKK2'
		,UR_K AS 'SLUCH/UR_K'
		,SL_K AS 'SLUCH/SL_K',
		IT_SL AS 'SLUCH/IT_SL'
		,(SELECT IDSL AS 'IDSL',Coefficient AS 'Z_SL' FROM dbo.vw_Coefficient cc WHERE cc.id=s.rf_idCase FOR XML PATH('SL_KOEF'),TYPE) 'SLUCH'
		,CASE WHEN TypeCases=9 THEN AmountPayment ELSE NULL end AS 'SLUCH/SUM_KSG',
		CASE WHEN TypeCases=10 THEN AmountPayment ELSE NULL end AS 'SLUCH/SUM_DIAL',
		AmountPayment AS 'SLUCH/SUM_IT',PVT AS 'SLUCH/PVT'
		-------------usl------------------
		,(select idMU AS 'IDSERV', MUSurgery AS 'CODE_USL',Quantity AS 'KOL_USL',TotalPriceMU AS 'SUM_USL' 
		  FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=s.rf_idCase AND idMU IS NOT NULL  FOR XML PATH ('USL'), TYPE ) 'SLUCH'
FROM dbo.vw_SendingDataIntoFFOMS05 s
WHERE rf_idCase=81621774 AND IsFullDoubleDate=0 
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')

select idMU AS 'IDSERV', MUSurgery AS 'CODE_USL',Quantity AS 'KOL_USL',TotalPriceMU AS 'SUM_USL' 
FROM dbo.t_SendingDataIntoFFOMS WHERE rf_idCase=81621774