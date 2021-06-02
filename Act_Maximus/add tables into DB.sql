USE AccountOMS
GO
DROP TABLE t_RefActOfSettledAccount_EKMP_MEE
go
CREATE TABLE dbo.t_RefActOfSettledAccount_EKMP_MEE
(
rf_idActFileBySMO int NOT NULL,
CodeSMO char (5) COLLATE Cyrillic_General_CI_AS NULL,
CodeM char (6) COLLATE Cyrillic_General_CI_AS NULL,
rf_idAccounts int NULL,
rf_idCase BIGINT,
rf_idAct_Accounts_MEEAndEKMP INT,
CodeA int NULL
) 
GO
ALTER TABLE dbo.t_RefActOfSettledAccount_EKMP_MEE ADD CONSTRAINT FK_ActFileAndAccountsMEE_EKMP FOREIGN KEY (rf_idActFileBySMO) REFERENCES dbo.t_ActFileBySMO (id) ON DELETE CASCADE
GO