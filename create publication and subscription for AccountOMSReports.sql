-- Включение базы данных репликации
use master
exec sp_replicationdboption @dbname = N'AccountOMS', @optname = N'publish', @value = N'true'
GO

exec [AccountOMS].sys.sp_addlogreader_agent @job_login = null, @job_password = null, @publisher_security_mode = 1
GO
exec [AccountOMS].sys.sp_addqreader_agent @job_login = null, @job_password = null, @frompublisher = 1
GO
-- Добавление публикации моментальных снимков
use [AccountOMS]
exec sp_addpublication @publication = N'AccountOMSReports', @description = N'Snapshot publication of database ''AccountOMS'' from Publisher ''SRVSQL2-ST1''.', @sync_method = N'native', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'snapshot', @status = N'active', @independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1
GO


exec sp_addpublication_snapshot @publication = N'AccountOMSReports', @frequency_type = 8, @frequency_interval = 63, @frequency_relative_interval = 1, @frequency_recurrence_factor = 1, @frequency_subday = 1, @frequency_subday_interval = 1, @active_start_time_of_day = 225000, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'NT AUTHORITY\SYSTEM'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VLZ\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'UZH\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'HOPER\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'MED\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'SEVER\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VTFOMS\sysdba'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VTFOMS\MSoft'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VTFOMS\LAntonova'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VTFOMS\VKalinichev'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'VTFOMS\skrainov'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'NT SERVICE\SQLSERVERAGENT'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'NT SERVICE\MSSQLSERVER'
GO
exec sp_grant_publication_access @publication = N'AccountOMSReports', @login = N'distributor_admin'
GO

-- Добавление статей моментальных снимков
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_Case', @source_owner = N'dbo', @source_object = N't_Case', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'manual', @destination_table = N't_Case', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_Case_PID_ENP', @source_owner = N'dbo', @source_object = N't_Case_PID_ENP', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509D, @identityrangemanagementoption = N'none', @destination_table = N't_Case_PID_ENP', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_Diagnosis', @source_owner = N'dbo', @source_object = N't_Diagnosis', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'none', @destination_table = N't_Diagnosis', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_File', @source_owner = N'dbo', @source_object = N't_File', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'manual', @destination_table = N't_File', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'

-- Добавление столбцов секционирования статьи
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'GUID', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'id', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'DateRegistration', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'FileVersion', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'DateCreate', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'FileNameHR', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'FileNameLR', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'CodeM', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_File', @column = N'Insurance', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Добавление объекта синхронизации статей
exec sp_articleview @publication = N'AccountOMSReports', @article = N't_File', @view_name = N'SYNC_t_File_1__79', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_Meduslugi', @source_owner = N'dbo', @source_object = N't_Meduslugi', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'none', @destination_table = N't_Meduslugi', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_MES', @source_owner = N'dbo', @source_object = N't_MES', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'none', @destination_table = N't_MES', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @source_owner = N'dbo', @source_object = N't_RecordCasePatient', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'manual', @destination_table = N't_RecordCasePatient', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'

-- Добавление столбцов секционирования статьи
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'id', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'rf_idRegistersAccounts', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'idRecord', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'IsNew', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'ID_Patient', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'rf_idF008', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'NewBorn', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @column = N'AttachLPU', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Добавление объекта синхронизации статей
exec sp_articleview @publication = N'AccountOMSReports', @article = N't_RecordCasePatient', @view_name = N'SYNC_t_RecordCasePatient_1__79', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @source_owner = N'dbo', @source_object = N't_RegisterPatient', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509D, @identityrangemanagementoption = N'manual', @destination_table = N't_RegisterPatient', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'true', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'

-- Добавление столбцов секционирования статьи
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @column = N'id', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @column = N'rf_idFiles', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @column = N'rf_idV005', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @column = N'rf_idRecordCase', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
exec sp_articlecolumn @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @column = N'Sex', @operation = N'add', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

-- Добавление объекта синхронизации статей
exec sp_articleview @publication = N'AccountOMSReports', @article = N't_RegisterPatient', @view_name = N'SYNC_t_RegisterPatient_1__63', @filter_clause = N'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_RegistersAccounts', @source_owner = N'dbo', @source_object = N't_RegistersAccounts', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x00000000080352DD, @identityrangemanagementoption = N'manual', @destination_table = N't_RegistersAccounts', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N't_UserPermissions', @source_owner = N'dbo', @source_object = N't_UserPermissions', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509D, @identityrangemanagementoption = N'none', @destination_table = N't_UserPermissions', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'SQL', @del_cmd = N'SQL', @upd_cmd = N'SQL'
GO
use [AccountOMS]
exec sp_addarticle @publication = N'AccountOMSReports', @article = N'vw_sprMU', @source_owner = N'dbo', @source_object = N'vw_sprMU', @type = N'view schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_table = N'vw_sprMU', @destination_owner = N'dbo', @status = 16
GO

-- Добавление подписок на моментальные снимки
use [AccountOMS]
exec sp_addsubscription @publication = N'AccountOMSReports', @subscriber = N'SRVSQL1-ST2', @destination_db = N'AccountOMSReports', @subscription_type = N'Pull', @sync_type = N'automatic', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
GO

