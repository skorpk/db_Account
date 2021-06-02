USE AccountOMS
GO

SELECT LPU,Account,DateRegister,IDCASE,GUID_Case,IsUnload,MONTH
FROM dbo.t_260order_ONK 
WHERE GUID_Case IN('90C45588-4F4E-6A2F-E053-02057DC15AB2','915B59A6-82DB-441A-E053-02057DC112C9','B9F00D34-D555-452C-856B-9D1E75FAF15B','41823555-8541-426C-92D2-F345E8240103')

 UPDATE dbo.t_260order_ONK SET IsUnload=null WHERE MONTH=11

 BEGIN TRANSACTION
 delete dbo.t_260order_ONK 
 WHERE GUID_Case IN('90C45588-4F4E-6A2F-E053-02057DC15AB2','915B59A6-82DB-441A-E053-02057DC112C9','B9F00D34-D555-452C-856B-9D1E75FAF15B','41823555-8541-426C-92D2-F345E8240103')
 commit