USE AccountOMS
GO
IF OBJECT_ID('usp_IsCODEExists', N'P') IS NOT NULL
	DROP PROC usp_IsCODEExists
GO
CREATE PROCEDURE usp_IsCODEExists
				@code int,
				@codeM char(6)
as
select COUNT(*) 
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
where CodeM=@codeM and a.idRecord=@code
go