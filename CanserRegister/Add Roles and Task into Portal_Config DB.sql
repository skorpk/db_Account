USE Portal_Config
GO
EXEC dbo.sp_UserLevelInTask @UserName = 'vtfoms\LAntonova', -- varchar(50)
    @CodeTask = 'CanserRegister' -- varchar(50)
DECLARE @UserName varchar(50)= 'vtfoms\LAntonova',
    @CodeTask varchar(50)= 'CanserRegister' -- varchar(50)

--BEGIN TRANSACTION
-- select max(rt.Level)
--  from t_PortalUsers u
--  inner join t_PortalUsersInRoles ur on ur.UserId = u.UserID
--  inner join t_PortalRoles r on r.RoleID = ur.RoleId
--  inner join t_PortalRolesInTasks rt on rt.RoleId = r.RoleID
--  inner join t_PortalTasks t on t.TaskId = rt.TaskId
--  where u.UserNameLow = lower(@UserName)
--  and t.CodeTask = @CodeTask
--  and u.Status = 1

--SELECT * FROM t_PortalRolesInTasks

--SELECT * FROM  t_PortalRoles

--INSERT dbo.t_PortalRoles
--        ( RoleID, RoleCode, RoleName )
--VALUES  ( 32, -- RoleID - int
--          'CanserRegister_Role', 
--          'ИИ пациентов с ЗНО'  -- RoleName - varchar(250)
--          )

--SELECT * FROM t_PortalTasks
--SELECT * FROM t_PortalRoles

--INSERT dbo.t_PortalRolesInTasks( TaskId, RoleId, Level ) VALUES  ( 8,32,2)

-- select max(rt.Level)
--  from t_PortalUsers u
--  inner join t_PortalUsersInRoles ur on ur.UserId = u.UserID
--  inner join t_PortalRoles r on r.RoleID = ur.RoleId
--  inner join t_PortalRolesInTasks rt on rt.RoleId = r.RoleID
--  inner join t_PortalTasks t on t.TaskId = rt.TaskId
--  where u.UserNameLow = lower(@UserName)
--  and t.CodeTask = @CodeTask
--  and u.Status = 1

--commit