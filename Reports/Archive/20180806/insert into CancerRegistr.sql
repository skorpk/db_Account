USE PeopleAttach
GO
BEGIN TRANSACTION
INSERT dbo.CancerRegistr( Fam ,Im ,Ot ,DR ,W ,BeginUchetDate ,BeginUchetCode ,DiagCode ,DiagDate ,DiagStadia ,NumRegistr ,CodeRegion ,Address ,[Year] ,[Month] )
SELECT Фамилия ,Имя ,Отчество,[Дата рождения] ,CASE WHEN Пол='М' THEN 1 ELSE 2 END  , 
	CASE WHEN LEN([Взят на учет дата])<9 THEN  '20'+RIGHT([Взят на учет дата] ,2)+SUBSTRING([Взят на учет дата],4,2)+SUBSTRING([Взят на учет дата],1,2) ELSE CONVERT(DATETIME,[Взят на учет дата],104) END,
    [Взят на учет признак] ,Диагноз ,
    CASE WHEN RIGHT([Диагноз дата] ,2)>='00' AND RIGHT([Диагноз дата] ,2)<'19' THEN '20'+RIGHT([Диагноз дата] ,2)+SUBSTRING([Диагноз дата],4,2)+SUBSTRING([Диагноз дата],1,2) 
						ELSE '19'+RIGHT([Диагноз дата] ,2)+SUBSTRING([Диагноз дата],4,2)+SUBSTRING([Диагноз дата],1,2) END,
     [Диагноз стадия] ,[Регистр# Номер] ,Код ,Адрес, 2018,6         
FROM dbo.tmpCancer062018
commit
go