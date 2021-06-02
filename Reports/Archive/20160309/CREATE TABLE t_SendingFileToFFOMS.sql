USE AccountOMS
GO
DROP TABLE dbo.t_SendingFileToFFOMS

CREATE TABLE t_SendingFileToFFOMS
(
	id INT IDENTITY(1,1) NOT null,
	NameFile VARCHAR(12),
	ReportMonth TINYINT,
	ReportYear SMALLINT,
	DateCreate datetime NOT NULL DEFAULT GETDATE(), 
	NumberOfEndFile TINYINT
)

CREATE UNIQUE NONCLUSTERED INDEX QU_idNumber_FileName ON dbo.t_SendingFileToFFOMS(NameFile)