USE AccountOMS
GO
USE  AccountOMS
GO
--SELECT *
--FROM dbo.V_KOEF_U
--WHERE lpu='340017'
SELECT *
INTO #t
FROM (VALUES ('901A33D4-0F1B-717D-E053-02057DC10229','DT_CONS'),('901A33D4-0F3E-717D-E053-02057DC10229','DT_CONS'),('901A33D4-0B9B-717D-E053-02057DC10229','DT_CONS'),('90FE8E9F-3B47-396A-E053-02057DC102CC','KSG_KPG'),
			('90FE8E9F-3B4A-396A-E053-02057DC102CC','KSG_KPG'),('8F119282-601B-46AE-E053-02057DC108B6','KSG_KPG'),('8F119282-601F-46AE-E053-02057DC108B6','KSG_KPG'),('8F119282-6038-46AE-E053-02057DC108B6','DT_CONS'),
			('8F119282-6339-46AE-E053-02057DC108B6','DT_CONS'),('8F119282-656C-46AE-E053-02057DC108B6','DT_CONS'),('8F119282-65A6-46AE-E053-02057DC108B6','KSG_KPG'),('8F119282-65BC-46AE-E053-02057DC108B6','STAD'),
			('8F119282-65BD-46AE-E053-02057DC108B6','STAD'),('915B59A6-8217-441A-E053-02057DC112C9','DT_CONS'),('915B59A6-83CC-441A-E053-02057DC112C9','KSG_KPG'),('915B59A6-82D4-441A-E053-02057DC112C9','KSG_KPG'),
			('915B59A6-82DB-441A-E053-02057DC112C9','KSG_KPG'),('8F1C7868-EA8E-46B8-E053-02057DC146D1','KSG_KPG'),('8F1C7868-EA90-46B8-E053-02057DC146D1','KSG_KPG'),('90C45588-4F4E-6A2F-E053-02057DC15AB2','KSG_KPG'),
			('90C45588-4F50-6A2F-E053-02057DC15AB2','KSG_KPG'),('90C45588-4F52-6A2F-E053-02057DC15AB2','KSG_KPG'),('90C45588-4F55-6A2F-E053-02057DC15AB2','KSG_KPG'),('90C45588-4F5C-6A2F-E053-02057DC15AB2','KSG_KPG'),
('90C45588-4F5E-6A2F-E053-02057DC15AB2','KSG_KPG'),
('90C45588-4A72-6A2F-E053-02057DC15AB2','DT_CONS'),
('90C45588-4EB5-6A2F-E053-02057DC15AB2','KSG_KPG'),
('90C45588-4EBC-6A2F-E053-02057DC15AB2','KSG_KPG'),
('90C45588-48FB-6A2F-E053-02057DC15AB2','DT_CONS'),
('8F117724-6165-31F2-E053-02057DC15F4F','DT_CONS'),
('8F117724-75AF-31F2-E053-02057DC15F4F','KSG_KPG'),
('8F117724-75C8-31F2-E053-02057DC15F4F','STAD'),
('8F117724-61D6-31F2-E053-02057DC15F4F','DT_CONS'),
('8F117724-62D7-31F2-E053-02057DC15F4F','KSG_KPG'),
('8F117724-75D7-31F2-E053-02057DC15F4F','STAD'),
('8F117724-75D9-31F2-E053-02057DC15F4F','STAD'),
('8F117724-75DD-31F2-E053-02057DC15F4F','STAD'),
('8F117724-62E3-31F2-E053-02057DC15F4F','KSG_KPG'),
('8F117724-62F0-31F2-E053-02057DC15F4F','KSG_KPG'),
('9117CEBC-D00C-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D00F-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D010-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D018-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-CD23-6E9C-E053-02057DC16039','DT_CONS'),
('9117CEBC-D027-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D029-6E9C-E053-02057DC16039','DT_CONS'),
('9117CEBC-D054-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D056-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-CC59-6E9C-E053-02057DC16039','DT_CONS'),
('9117CEBC-CD63-6E9C-E053-02057DC16039','DT_CONS'),
('9117CEBC-CD6B-6E9C-E053-02057DC16039','DT_CONS'),
('9117CEBC-CC7B-6E9C-E053-02057DC16039','STAD'),
('9117CEBC-D088-6E9C-E053-02057DC16039','KSG_KPG'),
('9117CEBC-D094-6E9C-E053-02057DC16039','KSG_KPG'),
('8F1FEC7B-C4A2-279B-E053-02057DC1666A','KSG_KPG'),
('8F1FEC7B-C4B4-279B-E053-02057DC1666A','STAD'),
('909D9FB7-A15E-59F0-E053-02057DC16F7B','KSG_KPG'),
('8F1FE732-07B5-31C3-E053-02057DC178CB','KSG_KPG'),
('8F1FE732-07B6-31C3-E053-02057DC178CB','DT_CONS'),
('9039DFA0-CBDB-36BD-E053-02057DC18018','KSG_KPG'),
('9089F381-BD1A-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-B628-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-BD2A-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-BD2B-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-BD31-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-BD32-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-B739-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-BD42-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-BD48-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-B759-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-B65B-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-B76B-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-B77C-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-B595-3E06-E053-02057DC180F7','DT_CONS'),
('9089F381-BCA5-3E06-E053-02057DC180F7','KSG_KPG'),
('9089F381-BCB5-3E06-E053-02057DC180F7','KSG_KPG'),
('90CAEACD-0FE0-2033-E053-02057DC18327','DT_CONS'),
('9150D1BE-B44E-5565-E053-02057DC18685','KSG_KPG'),
('9150D1BE-B457-5565-E053-02057DC18685','KSG_KPG'),
('9150D1BE-B458-5565-E053-02057DC18685','KSG_KPG'),
('9150D1BE-B481-5565-E053-02057DC18685','KSG_KPG'),
('9150D1BE-B48F-5565-E053-02057DC18685','KSG_KPG'),
('9150D1BE-B4AA-5565-E053-02057DC18685','DT_CONS'),
('9150D1BE-B2B4-5565-E053-02057DC18685','DT_CONS'),
('9150D1BE-B3ED-5565-E053-02057DC18685','DT_CONS'),
('913C8907-B79B-60F2-E053-02057DC18BD3','DT_CONS'),
('913C8907-BBB8-60F2-E053-02057DC18BD3','KSG_KPG'),
('913C8907-B7E8-60F2-E053-02057DC18BD3','DT_CONS'),
('913C8907-BBFE-60F2-E053-02057DC18BD3','KSG_KPG'),
('8F0F4A3E-6A0E-5456-E053-02057DC18E09','KSG_KPG'),
('8F0F4A3E-6A12-5456-E053-02057DC18E09','KSG_KPG'),
('8F0F4A3E-7346-5456-E053-02057DC18E09','DT_CONS'),
('8F0F4A3E-804D-5456-E053-02057DC18E09','STAD'),
('8F0F4A3E-8F70-5456-E053-02057DC18E09','KSG_KPG'),
('8F0F4A3E-8D97-5456-E053-02057DC18E09','DT_CONS'),
('8F0F4A3E-73B9-5456-E053-02057DC18E09','STAD'),
('8F0F4A3E-72E4-5456-E053-02057DC18E09','DT_CONS'),
('8F0FB975-82AA-33E7-E053-02057DC1B949','KSG_KPG'),
('8F1D0BB8-F52A-31C1-E053-02057DC1F6D3','DT_CONS'),
('8F1D0BB9-0043-31C1-E053-02057DC1F6D3','DT_CONS'),
('8F1D0BB9-0443-31C1-E053-02057DC1F6D3','KSG_KPG'),
('8F1D0BB8-F54D-31C1-E053-02057DC1F6D3','DT_CONS'),
('8F1D0BB8-F56B-31C1-E053-02057DC1F6D3','DT_CONS'),
('8F1D0BB9-0776-31C1-E053-02057DC1F6D3','KSG_KPG')) v(GUID_C,IM_POL)

CREATE NONCLUSTERED INDEX ix1 ON #t(GUID_C) INCLUDE(IM_POL)

BEGIN TRANSACTION
DELETE FROM dbo.t_260order_ONK
FROM dbo.t_260order_ONK o INNER JOIN #t t ON
			o.GUID_Case=t.GUID_C
commit
go
DROP TABLE #t
		