USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetReport96]    Script Date: 20.04.2020 8:57:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_GetReport96]			
AS
;WITH cteMax
AS 
(
	select MAX(id) AS idMax FROM dbo.t_Report_Templates WHERE NameFile='report96.xlsx'
)
select f.DATA,f.NameFile 
FROM dbo.t_Report_Templates f INNER JOIN cteMax c ON
			f.id=c.idMax
WHERE NameFile='report96.xlsx'
go
