USE Portal_Config
GO
--SELECT *  FROM dbo.t_PortalRoles

--SELECT * FROM dbo.t_PortalTasks

SELECT * FROM dbo.t_PortalRolesInTasks
SELECT * FROM dbo.t_SprLevels

BEGIN TRANSACTION
INSERT dbo.t_PortalRoles(RoleID,RoleCode,RoleName) VALUES(   35, 'CanserRegister','��: �������� � ���')
INSERT dbo.t_PortalTasks(TaskId,CodeTask,NameTask) VALUES( 8,'CanserRegister', '�� ��������� � ���')
INSERT dbo.t_SprLevels(TaskId,Level,Description) VALUES(   8, 6, '�������� �� ��������� � ���' )
insert dbo.t_PortalRolesInTasks(ID,TaskId,RoleId,Level) VALUES(17,8,35,1)

commit