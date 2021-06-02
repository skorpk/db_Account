USE PlanDD
GO
CREATE TABLE t_173N_First
(
	rf_idCase BIGINT,
	AmountPayment DECIMAL(15,2),
	CodeM CHAR(6),
	ENP VARCHAR(20),
	rf_idRecordCasePatient int,
	ReportMonth tinyint,
	DateEnd DATE,
	ReportYear smallint,
	DateRegistration DATETIME
)