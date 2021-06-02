USE AccountOMSReports
GO
BEGIN TRANSACTION
INSERT dbo.t_SendingDataIntoFFOMS2019
        ( id ,rf_idCase ,CodeM ,rf_idMO ,ReportMonth , ReportYear , rf_idF008 , rf_idV006 , SeriaPolis , NumberPolis , BirthDay , rf_idV005 , idRecordCase , rf_idV014 , UnitOfHospital ,
			DateBegin , DateEnd , DS1 , DS2 , DS3 , rf_idV009 , MES , AmountPayment , AmountPaymentZSL , idMU , MUSurgery , Age , VZST , K_KSG , KSG_PG , PVT , IsDisableCheck , IsFullDoubleDate ,
			IsUnload , IT_SL , ENP , TypeCases , Quantity , TotalPriceMU , UR_K , IDSP,NewValue        )
SELECT  id ,rf_idCase ,CodeM ,  rf_idMO ,  ReportMonth ,  ReportYear ,  rf_idF008 ,  rf_idV006 ,  SeriaPolis ,  NumberPolis ,  BirthDay ,  rf_idV005 ,  idRecordCase ,  rf_idV014 ,
  UnitOfHospital ,  DateBegin ,  DateEnd ,  DS1 ,  DS2 ,  DS3 ,  rf_idV009 ,  MES ,  AmountPayment ,  AmountPaymentZSL ,  idMU ,  MUSurgery ,  Age ,  VZST ,  K_KSG ,  KSG_PG ,
  PVT ,  IsDisableCheck ,  IsFullDoubleDate ,  IsUnload ,  IT_SL ,  ENP ,  TypeCases ,  Quantity ,  TotalPriceMU ,  UR_K ,  IDSP,1
FROM dbo.t_SendingDataIntoFFOMS s 
WHERE NOT EXISTS(SELECT 1 FROM dbo.t_SendingDataIntoFFOMS2019 WHERE rf_idCase=s.rf_idCase)

commit