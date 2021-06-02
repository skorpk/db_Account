USE AccountOMS
GO
IF OBJECT_ID('t_RefActOfSettledAccountBySMO',N'U') IS NOT NULL
	DROP TABLE t_RefActOfSettledAccountBySMO
GO
IF OBJECT_ID('t_ActFileBySMO',N'U') IS NOT NULL
	DROP TABLE t_ActFileBySMO
GO
CREATE TABLE t_ActFileBySMO
(
	id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ActFileName VARCHAR(25),
	DateCreate DATETIME NOT NULL DEFAULT GETDATE()
)
go
CREATE TABLE t_RefActOfSettledAccountBySMO
(
	rf_idActFileBySMO INT NOT NULL,
	CodeSMO CHAR(5),
	CodeM CHAR(6),
	NumberAct int,
	rf_idAccounts INT,
	DateAct DATE,
	ReportYear SMALLINT,
	CodeA INT	
)
go
ALTER TABLE t_RefActOfSettledAccountBySMO WITH CHECK ADD  CONSTRAINT [FK_ActFileAndAccounts] FOREIGN KEY(rf_idActFileBySMO) 
	REFERENCES t_ActFileBySMO (id) ON DELETE CASCADE
GO    