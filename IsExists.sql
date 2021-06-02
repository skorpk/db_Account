use AccountOMS
go
IF OBJECT_ID (N'dbo.IsExists', N'FN') IS NOT NULL
    DROP FUNCTION dbo.IsExists;
GO
CREATE FUNCTION dbo.IsExists(@id int)
RETURNS tinyint
AS 
begin
	return(
			select COUNT(*) from t_FileExit where rf_idFile=@id
			)
end
go
alter table t_File add IsUnLoad as dbo.IsExists(id)
go