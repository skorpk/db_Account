USE PeopleAttach
GO
BEGIN TRANSACTION
INSERT dbo.CancerRegistr( Fam ,Im ,Ot ,DR ,W ,BeginUchetDate ,BeginUchetCode ,DiagCode ,DiagDate ,DiagStadia ,NumRegistr ,CodeRegion ,Address ,[Year] ,[Month] )
SELECT ������� ,��� ,��������,[���� ��������] ,CASE WHEN ���='�' THEN 1 ELSE 2 END  , 
	CASE WHEN LEN([���� �� ���� ����])<9 THEN  '20'+RIGHT([���� �� ���� ����] ,2)+SUBSTRING([���� �� ���� ����],4,2)+SUBSTRING([���� �� ���� ����],1,2) ELSE CONVERT(DATETIME,[���� �� ���� ����],104) END,
    [���� �� ���� �������] ,������� ,
    CASE WHEN RIGHT([������� ����] ,2)>='00' AND RIGHT([������� ����] ,2)<'19' THEN '20'+RIGHT([������� ����] ,2)+SUBSTRING([������� ����],4,2)+SUBSTRING([������� ����],1,2) 
						ELSE '19'+RIGHT([������� ����] ,2)+SUBSTRING([������� ����],4,2)+SUBSTRING([������� ����],1,2) END,
     [������� ������] ,[�������# �����] ,��� ,�����, 2018,6         
FROM dbo.tmpCancer062018
commit
go