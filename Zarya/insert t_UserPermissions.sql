USE AccountOMS
GO
BEGIN TRANSACTION
INSERT dbo.t_UserPermissions
(
    [user],
    userName,
    havePermissionToPersonalData,
    filialPermission,
    canCopyFromGrid
)
VALUES
(   N'vtfoms\imednikov', -- user - nvarchar(25)
    N'Медников Игорь Михайлович', -- userName - nvarchar(100)
    1,   -- havePermissionToPersonalData - tinyint
    N'-1', -- filialPermission - nchar(10)
    1    -- canCopyFromGrid - tinyint
    )

SELECT * FROM t_UserPermissions WHERE [user]='vtfoms\imednikov'

commit