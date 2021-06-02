USE RegisterCases
GO
DECLARE @dateRegStart DATETIME='20150101',
		@dateRegEnd DATETIME='20150212',
		@reportYear SMALLINT=2015,
		@reportMonth TINYINT=1

CREATE TABLE #tCase
(
	Account VARCHAR(15),
	id BIGINT,
	DateEnd DATE,
	IsChildTariff  BIT,
	rf_idMO CHAR(6),
	IsCompletedCase TINYINT,
	NumberCase bigint 	
)
INSERT #tCase( Account,id ,DateEnd ,IsChildTariff ,rf_idMO ,IsCompletedCase,NumberCase)
SELECT Account,c.id,c.DateEnd,c.IsChildTariff,c.rf_idMO,c.IsCompletedCase,c.idRecordCase
FROM AccountOMS.dbo.t_File f INNER JOIN AccountOMS.dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
			AND a.rf_idSMO='34'
					INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts
					INNER JOIN AccountOMS.dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient
WHERE f.DateRegistration>@dateRegStart AND f.DateRegistration<@dateRegEnd AND a.ReportYear=@reportYear AND a.ReportMonth=@reportMonth AND c.rf_idV006=3
-------------------------------------------------------------------------------------
select c.id,mes.MES,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Tariff,c.rf_idMO,c.Account,c.NumberCase
INTO #tmpCasePriceMES
from #tCase c inner join AccountOMS.dbo.t_MES mes on
				c.id=mes.rf_idCase
								inner join (SELECT MU FROM dbo.vw_sprMUCompletedCase 
											UNION ALL SELECT code FROM vw_sprCSG
											) m on
						mes.MES=m.MU
								inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						--and c.rf_idV006=t1.rf_idV006
						AND t1.rf_idV006=3
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4


--SELECT DISTINCT  t.Account, t.rf_idMO,t.id ,t.MES , t.DateEnd ,t.LevelPayType ,t.IsChildTariff ,t.Tariff,mp.Price 
--FROM #tmpCasePriceMES t	INNER JOIN (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
--								 UNION ALL 
--								 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp ON
--					t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
--					  and t.DateEnd<=mp.MUPriceDateEnd 																					
--where NOT EXISTS( SELECT * FROM (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
--								 UNION ALL 
--								 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp  
--				WHERE t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
--					  and t.DateEnd<=mp.MUPriceDateEnd and t.Tariff=mp.Price)     


--------------------------Meduslugi------------------------------------------					  
select c.id,mes.MU AS MUCode,c.DateEnd,t1.LevelPayType,c.IsChildTariff,mes.Price,c.rf_idMO,c.Account,c.NumberCase
INTO #tmpCasePrice
from #tCase c inner join AccountOMS.dbo.t_Meduslugi mes on
						c.id=mes.rf_idCase
			  inner join vw_sprMU m on
						mes.MU=m.MU								
			  inner join dbo.vw_sprPriceLevelMO t1 on
						c.rf_idMO=t1.CodeM
						--and c.rf_idV006=t1.rf_idV006
						AND t1.rf_idV006=3
						and c.DateEnd>=t1.DateBegin
						and c.DateEnd<=t1.DateEnd
						and t1.LevelPayType=4				
where c.IsCompletedCase=0 AND mes.Price>0


SELECT DISTINCT  t.Account, t.rf_idMO,l.NameS,t.id ,t.MES , t.DateEnd ,t.Tariff, mp.Price,t.NumberCase 
FROM #tmpCasePriceMES t	INNER JOIN (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
								 UNION ALL 
								 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp ON
					t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					  and t.DateEnd<=mp.MUPriceDateEnd 																					
							INNER JOIN dbo.vw_sprT001 l ON
					t.rf_idMO=l.CodeM
where NOT EXISTS( SELECT * FROM (SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM vw_sprCompletedCaseMUTariff 
								 UNION ALL 
								 SELECT CodeM,MU,LevelType,IsChild,MUPriceDateBeg,MUPriceDateEnd,Price FROM OMS_NSI.dbo.vw_sprCompletedCaseCSGTariff) mp  
				WHERE t.MES=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
					  and t.DateEnd<=mp.MUPriceDateEnd and t.Tariff=mp.Price)     
UNION ALL
SELECT DISTINCT t.Account, t.rf_idMO, l.NameS,t.id ,t.MUCode , t.DateEnd ,t.Price AS Tariff,mp.Price,t.NumberCase
FROM #tmpCasePrice t INNER JOIN vw_sprNotCompletedCaseMUTariff mp on
						t.MUCode=mp.MU 
						and t.rf_idMO=mp.CodeM 
						and t.LevelPayType=mp.LevelType
						and t.IsChildTariff=mp.IsChild 
						and t.DateEnd>=mp.MUPriceDateBeg
						and t.DateEnd<=mp.MUPriceDateEnd
					INNER JOIN dbo.vw_sprT001 l ON
						t.rf_idMO=l.CodeM 
where NOT EXISTS( SELECT * FROM vw_sprNotCompletedCaseMUTariff mp WHERE t.MUCode=mp.MU and t.rf_idMO=mp.CodeM and t.LevelPayType=mp.LevelType
																		and t.IsChildTariff=mp.IsChild and t.DateEnd>=mp.MUPriceDateBeg
																		and t.DateEnd<=mp.MUPriceDateEnd and t.Price=mp.Price)     
go
																		
DROP TABLE #tmpCasePrice
DROP TABLE #tmpCasePriceMES
DROP TABLE #tCase