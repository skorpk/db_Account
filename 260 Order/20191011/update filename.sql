USE AccountOMS
GO
BEGIN TRANSACTION
UPDATE dbo.t_260order_ONK SET FILENAME='CT34_19092',IsUnload=null WHERE MONTH=9

SELECT FILENAME,IsUnload from dbo.t_260order_ONK WHERE MONTH=9
commit