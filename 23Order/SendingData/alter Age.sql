USE AccountOMS
GO
SELECT rf_idCase, DateBegin,DateEnd,BirthDay,age
	  ,DATEDIFF(YEAR,BirthDay,DateBegin)-CASE WHEN 100*MONTH(BirthDay)+DAY(BirthDay)>100*MONTH(DateBegin)+DAY(DateBegin)-1 THEN 1 ELSE 0 END
		,DATEDIFF(YEAR,BirthDay,DateBegin),CASE WHEN 100*MONTH(BirthDay)+DAY(BirthDay)>100*MONTH(DateBegin)+DAY(DateBegin) THEN 1 ELSE 0 END    
		,100*MONTH(DateBegin),DAY(DateBegin)
FROM dbo.t_SendingDataIntoFFOMS 
WHERE DateBegin='20180320' AND ReportMonth=6 AND Age=60 AND BirthDay='19580320'