USE AccountOMS
GO
--таблица в которую помещаем неверное сопостовлени B_DIAG
CREATE TABLE t_BadDiag260
(
	rf_idONK_SL INT NOT NULL,
	CodeDiagnostic SMALLINT NOT NULL
)
GO
CREATE UNIQUE NONCLUSTERED INDEX qu_Id_Code ON dbo.t_BadDiag260(rf_idONK_SL,CodeDiagnostic) WITH IGNORE_DUP_KEY
INSERT dbo.t_BadDiag260
        ( rf_idONK_SL, CodeDiagnostic )
VALUES  ( 144601,3) 