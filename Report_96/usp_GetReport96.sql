USE AccountOMS
GO
create proc [dbo].[usp_GetReport96]			
as
select f.DATA,f.NameFile from dbo.t_Report_Templates f WHERE NameFile='report96.xlsx'
go

