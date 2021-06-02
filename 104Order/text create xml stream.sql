USE AccountOMS
GO
DECLARE @reportMonth TINYINT=6,
		@reportYear SMALLINT=2018,
		@nameFile varchar(20)='ER3406'
DECLARE @code1 INT

SET @code1=@reportMonth        

--SET @nameFile='MR3418'+ right('00000'+CAST(@reportMonth AS VARCHAR(2)),4)
SELECT t.colXML from(
SELECT (
SELECT '1.0' AS 'VERSION', CAST(GETDATE() AS DATE) AS 'DATA',@nameFile AS 'FILENAME' FOR XML PATH('ZGLV'),TYPE),
(SELECT @code1 AS 'CODE', @reportYear AS 'YEAR',@reportMonth AS 'MONTH' FOR XML PATH('SVD'),TYPE),
------------------------------------------------
(SELECT ROW_NUMBER() OVER(ORDER BY rf_idV006) AS 'N_SV', rf_idV006 AS 'USL_OK'
		,CASE WHEN rf_idV006=1 THEN rf_idV014 ELSE NULL END AS 'FOR_POM',AP_Type AS 'AP_TYPE'
		,(SELECT CASE WHEN age<18 THEN 0 WHEN age>17 AND age<60 THEN 1 ELSE 2 END AS 'VZST'
			,COUNT(rf_idcase) 'ZBL_IT'
			, COUNT(CASE WHEN rf_idV009 IN (105,106,205,206,313,405,406,411) THEN rf_idCase ELSE NULL END) 'SMR_IT'
			FROM  dbo.t_OrderAdult_104_2017 ss
			WHERE ss.ReportMonth=@reportMonth AND ss.rf_idV006=s.rf_idV006 
					AND (CASE WHEN ss.rf_idV006=1 THEN ss.rf_idV014 ELSE 9 END)=ISNULL((CASE WHEN s.rf_idV006=1 THEN s.rf_idV014 ELSE NULL END),9)
			GROUP BY CASE WHEN age<18 THEN 0 WHEN age>17 AND age<60 THEN 1 ELSE 2 END 
			FOR XML PATh('VZS_IT'),TYPE
		 )
FROM dbo.t_OrderAdult_104_2017 s
WHERE ReportMonth=@reportMonth
GROUP BY rf_idV006,CASE WHEN rf_idV006=1 THEN rf_idV014 ELSE NULL END,AP_Type
FOR XML PATh('IT_SV'),TYPE,ROOT('OB_SV')
), 
------------------------------------------------------
(SELECT TOP 10 rf_idCase AS 'N_ZAP',  BirthDay AS 'PACIENT/DR',
		DateBegin AS 'SLUCH/DATE_1',RTRIM(DS1) AS 'SLUCH/DS1',rf_idV009 AS 'SLUCH/RSLT',GOSP_TYPE AS 'SLUCH/GOSP_TYPE',
		rf_idV014 AS 'SLUCH/FOR_POM', AP_Type AS 'SLUCH/AP_TYPE'		
FROM dbo.t_OrderAdult_104_2017 s
WHERE ReportMonth=@reportMonth
FOR XML PATh('ZAP'),TYPE,ROOT('PODR')
) 
FOR XML PATH(''),TYPE,ROOT('MR_OB')
) t(colXML)