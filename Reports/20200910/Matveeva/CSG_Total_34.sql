USE AccountOMS
GO
DECLARE @dateStartReg DATETIME='20180101',
		@dateEndReg DATETIME='20190122',
		@dateStartRegRAK DATETIME='20180101',
		@dateEndRegRAK DATETIME='20190123',
		@reportYear SMALLINT=2018
		

CREATE TABLE #tCSG(CSG VARCHAR(10),TypeCol TINYINT)
INSERT #tCSG(CSG,TypeCol)
VALUES('1001.0',7),('1002.0',7),('1002.1',7),('1003.0',7),('1004.0',7),('1004.1',7),('1006.0',7),('1008.0',7),('1009.0',7),('1010.0',7),('1011.0',7),('1012.0',7),('1016.0',7),('1017.0',7),('1019.0',7),('1021.0',7),('1023.0',7),
('1029.0',7),('1030.0',7),('1035.0',7),('1047.0',7),('1048.0',7),('1049.0',7),('1056.0',7),('1057.0',7),('1064.0',7),('1065.0',7),('1066.0',7),('1076.0',7),('1079.0',7),('1081.0',7),('1083.0',7),('1087.0',7),('1088.0',7),
('1094.0',7),('1095.0',7),('1097.0',7),('1099.0',7),('1163.0',7),('1164.0',7),('1165.0',7),('1166.0',7),('1167.0',7),('1168.0',7),('1173.0',7),('1174.0',7),('1179.0',7),('1180.0',7),('1182.0',7),('1185.0',7),('1187.0',7),
('1193.0',7),('1195.0',7),('1207.0',7),('1208.0',7),('1209.0',7),('1210.0',7),('1211.0',7),('1212.0',7),('1213.0',7),('1215.0',7),('1217.0',7),('1218.0',7),('1219.0',7),('1221.0',7),('1227.0',7),('1229.0',7),('1230.0',7),
('1231.0',7),('1235.0',7),('1236.0',7),('1240.0',7),('1241.0',7),('1242.0',7),('1243.0',7),('1244.0',7),('1255.0',7),('1256.0',7),('1257.0',7),('1265.0',7),('1266.0',7),('1270.0',7),('1271.0',7),('1272.0',7),
('1284.0',7),('1285.0',7),('1286.0',7),('1300.0',7),('1301.0',7),('1310.0',7),('1317.0',7),('1318.0',7),('1335.0',7),('1336.0',7)
INSERT #tCSG(CSG,TypeCol)
VALUES('1002.2',8),('1004.2',8),('1005.0',8),('1013.0',8),('1014.0',8),('1018.0',8),('1020.0',8),('1026.0',8),('1028.0',8),('1031.0',8),('1036.0',8),('1037.0',8),('1039.0',8),('1040.0',8),('1041.0',8),('1042.0',8),('1043.0',8),
('1050.0',8),('1051.0',8),('1052.0',8),('1053.0',8),('1054.0',8),('1058.0',8),('1059.0',8),('1063.0',8),('1067.0',8),('1068.0',8),('1069.0',8),('1072.0',8),('1073.0',8),('1074.0',8),('1075.0',8),('1077.0',8),('1078.0',8),
('1080.0',8),('1082.0',8),('1084.0',8),('1085.0',8),('1086.0',8),('1089.0',8),('1096.0',8),('1098.0',8),('1100.0',8),('1103.0',8),('1104.0',8),('1105.0',8),('1106.0',8),('1110.0',8),('1111.0',8),('1112.0',8),('1114.0',8),
('1115.0',8),('1116.0',8),('1169.0',8),('1170.0',8),('1171.0',8),('1175.0',8),('1176.0',8),('1177.0',8),('1178.0',8),('1181.0',8),('1183.0',8),('1184.0',8),('1186.0',8),('1188.0',8),('1189.0',8),('1190.0',8),('1191.0',8),
('1192.0',8),('1194.0',8),('1196.0',8),('1197.0',8),('1198.0',8),('1199.0',8),('1202.0',8),('1203.0',8),('1214.0',8),('1216.0',8),('1222.0',8),('1223.0',8),('1224.0',8),('1228.0',8),('1232.0',8),('1237.0',8),('1238.0',8),
('1245.0',8),('1246.0',8),('1247.0',8),('1249.0',8),('1250.0',8),('1251.0',8),('1252.0',8),('1253.0',8),('1258.0',8),('1259.0',8),('1260.0',8),('1261.0',8),('1262.0',8),('1263.0',8),('1267.0',8),('1273.0',8),('1274.0',8),
('1275.0',8),('1278.0',8),('1281.0',8),('1282.0',8),('1283.0',8),('1287.0',8),('1288.0',8),('1289.0',8),('1290.0',8),('1291.0',8),('1292.0',8),('1294.0',8),('1295.0',8),('1302.0',8),('1303.0',8),('1304.0',8),('1305.0',8),
('1306.0',8),('1307.0',8),('1308.0',8),('1311.0',8),('1312.0',8),('1320.0',8),('1322.0',8),('1325.0',8),('1326.0',8),('1329.0',8),('1330.0',8),('1332.0',8),('1333.0',8),('1334.0',8),('1337.0',8),('1338.0',8),('1339.0',8),
('1342.0',8),('1343.0',8)
INSERT #tCSG(CSG,TypeCol)
VALUES('1007.0',9),('1015.0',9),('1022.0',9),('1024.0',9),('1025.0',9),('1027.0',9),('1038.0',9),('1044.0',9),('1045.0',9),('1046.0',9),
('1055.0',9),('1060.0',9),('1061.0',9),('1062.0',9),('1070.0',9),('1071.0',9),('1090.0',9),('1091.0',9),('1092.0',9),('1093.0',9),
('1101.0',9),('1102.0',9),('1107.0',9),('1108.0',9),('1109.0',9),('1113.0',9),('1172.0',9),('1200.0',9),('1201.0',9),('1204.0',9),
('1205.0',9),('1206.0',9),('1220.0',9),('1225.0',9),('1226.0',9),('1233.0',9),('1234.0',9),('1239.0',9),('1248.0',9),('1254.0',9),
('1264.0',9),('1268.0',9),('1269.0',9),('1276.0',9),('1277.0',9),('1279.0',9),('1280.0',9),('1293.0',9),('1296.0',9),('1297.0',9),
('1298.0',9),('1299.0',9),('1309.0',9),('1313.0',9),('1314.0',9),('1315.0',9),('1316.0',9),('1319.0',9),('1321.0',9),('1323.0',9),
('1324.0',9),('1327.0',9),('1328.0',9),('1331.0',9),('1340.0',9),('1341.0',9)

SELECT DISTINCT c.id AS rf_idCase, c.AmountPayment,mes,cs.TypeCol
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts					
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_Mes m ON
			c.id=m.rf_idCase
					INNER JOIN #tCSG cs ON
			m.MES=cs.CSG			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=1 AND c.rf_idV008=31 AND a.rf_idSMO='34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

SELECT 2018 AS ReportYear,CAST(SUM(t.AmountPayment) AS MONEY) AS Col2
	,cast(SUM(CASE WHEN t.TypeCol=7 THEN t.AmountPayment ELSE 0.0 END ) as money) AS Col3
	,cast(SUM(CASE WHEN t.TypeCol=8 THEN t.AmountPayment ELSE 0.0 END ) as money) AS Col4
	,cast(SUM(CASE WHEN t.TypeCol=9 THEN t.AmountPayment ELSE 0.0 END ) as money) AS Col5
	,COUNT(t.rf_idCase) AS Col6
	,Count(CASE WHEN t.TypeCol=7 THEN t.rf_idCase ELSE null END ) AS Col7
	,Count(CASE WHEN t.TypeCol=8 THEN t.rf_idCase ELSE null END ) AS Col8
	,Count(CASE WHEN t.TypeCol=9 THEN t.rf_idCase ELSE null END ) AS Col9
INTO #total
FROM #t t
WHERE t.AmountPayment>0
GO
DROP TABLE #t
GO
DROP TABLE #tCSG
--------------------------------------------------------------2019--------------------------------
DECLARE @dateStartReg DATETIME='20190101',
		@dateEndReg DATETIME='20200118',
		@dateStartRegRAK DATETIME='20190101',
		@dateEndRegRAK DATETIME='20200121',
		@reportYear SMALLINT=2019

CREATE TABLE #tCSG(CSG VARCHAR(10),TypeCol TINYINT)
INSERT #tCSG(CSG,TypeCol)
VALUES('st01.001',7),('st02.001',7),('st02.002',7),('st02.003',7),('st02.005',7),('st02.007',7),('st02.008',7),('st02.009',7),('st02.010',7),('st02.011',7),('st03.002',7),('st04.001',7),('st04.003',7),('st04.005',7),
('st05.001',7),('st06.002',7),('st06.003',7),('st09.001',7),('st10.003',7),('st10.004',7),('st10.005',7),('st12.001',7),('st12.002',7),('st12.009',7),('st12.010',7),('st12.011',7),('st12.012',7),
('st14.001',7),('st15.001',7),('st15.003',7),('st15.005',7),('st15.010',7),('st15.011',7),('st15.017',7),('st16.001',7),('st16.003',7),('st16.005',7),('st20.001',7),('st20.002',7),('st20.003',7),
('st20.004',7),('st20.005',7),('st20.006',7),('st21.001',7),('st21.002',7),('st21.007',7),('st21.008',7),('st22.002',7),('st23.001',7),('st23.003',7),('st24.003',7),('st25.001',7),('st26.001',7),
('st27.001',7),('st27.002',7),('st27.003',7),('st27.004',7),('st27.005',7),('st27.006',7),('st27.008',7),('st27.010',7),('st27.011',7),('st27.012',7),('st27.014',7),('st29.001',7),('st29.003',7),
('st29.004',7),('st29.005',7),('st29.009',7),('st29.010',7),('st30.001',7),('st30.002',7),('st30.003',7),('st30.004',7),('st30.005',7),('st31.001',7),('st31.002',7),('st31.003',7),('st31.011',7),
('st31.012',7),('st31.016',7),('st31.017',7),('st31.018',7),('st32.011',7),('st32.012',7),('st32.013',7),('st34.001',7),('st34.002',7),('st35.006',7),('st36.004',7),('st36.005',7),('st36.012',7),
('st37.011',7),('st37.012',7)
INSERT #tCSG(CSG,TypeCol)
VALUES('st02.004',8),('st02.012',8),('st02.013',8),('st04.002',8),('st04.004',8),('st05.004',8),('st05.008',8),('st06.001',8),('st07.001',8),('st09.002',8),('st09.003',8),
('st09.005',8),('st09.006',8),('st09.007',8),('st09.008',8),('st09.009',8),('st10.006',8),('st10.007',8),('st11.001',8),('st11.002',8),('st11.003',8),('st12.003',8),
('st12.004',8),('st12.008',8),('st12.014',8),('st13.001',8),('st13.004',8),('st13.005',8),('st13.006',8),('st13.007',8),('st14.002',8),('st14.003',8),('st15.002',8),
('st15.004',8),('st15.006',8),('st15.007',8),('st15.008',8),('st15.009',8),('st15.012',8),('st16.002',8),('st16.004',8),('st16.006',8),('st16.009',8),('st16.010',8),
('st16.011',8),('st16.012',8),('st17.004',8),('st17.005',8),('st17.006',8),('st18.001',8),('st18.002',8),('st18.003',8),('st20.007',8),('st20.008',8),('st20.009',8),
('st21.003',8),('st21.004',8),('st21.005',8),('st21.006',8),('st22.001',8),('st22.003',8),('st22.004',8),('st23.002',8),('st23.004',8),('st23.005',8),('st23.006',8),
('st24.001',8),('st24.002',8),('st24.004',8),('st25.002',8),('st25.003',8),('st25.004',8),('st25.005',8),('st25.008',8),('st25.009',8),('st27.007',8),('st27.009',8),
('st28.001',8),('st28.002',8),('st28.003',8),('st29.002',8),('st29.006',8),('st29.011',8),('st29.012',8),('st30.006',8),('st30.007',8),('st30.008',8),('st30.010',8),
('st30.011',8),('st30.012',8),('st30.013',8),('st30.014',8),('st31.004',8),('st31.005',8),('st31.006',8),('st31.007',8),('st31.008',8),('st31.009',8),('st31.013',8),
('st31.019',8),('st32.001',8),('st32.002',8),('st32.005',8),('st32.008',8),('st32.009',8),('st32.010',8),('st32.014',8),('st32.015',8),('st32.016',8),('st32.017',8),
('st32.018',8),('st33.001',8),('st33.003',8),('st33.004',8),('st34.003',8),('st34.004',8),('st34.005',8),('st35.001',8),('st35.002',8),('st35.003',8),('st35.004',8),
('st35.007',8),('st35.008',8),('st36.007',8),('st36.009',8),('st37.001',8),('st37.002',8),('st37.005',8),('st37.006',8),('st37.008',8),('st37.009',8),('st37.010',8),
('st37.013',8),('st37.014',8),('st37.015',8),('st37.018',8),('st38.001',8)

INSERT #tCSG(CSG,TypeCol)
VALUES('st02.006',9),('st03.001',9),('st04.006',9),('st05.002',9),('st05.003',9),('st05.005',9),('st05.006',9),('st05.007',9),('st05.009',9),('st05.010',9),('st05.011',9),
('st09.004',9),('st09.010',9),('st10.001',9),('st10.002',9),('st11.004',9),('st12.005',9),('st12.006',9),('st12.007',9),('st12.013',9),('st13.002',9),('st13.003',9),
('st15.013',9),('st15.014',9),('st15.015',9),('st15.016',9),('st16.007',9),('st16.008',9),('st17.001',9),('st17.002',9),('st17.003',9),('st17.007',9),('st20.010',9),
('st25.006',9),('st25.007',9),('st25.010',9),('st25.011',9),('st25.012',9),('st27.013',9),('st28.004',9),('st28.005',9),('st29.007',9),('st29.008',9),('st29.013',9),
('st30.009',9),('st30.015',9),('st31.010',9),('st31.014',9),('st31.015',9),('st32.003',9),('st32.004',9),('st32.006',9),('st32.007',9),('st33.002',9),('st33.005',9),
('st33.006',9),('st33.007',9),('st33.008',9),('st35.005',9),('st35.009',9),('st36.001',9),('st36.002',9),('st36.003',9),('st36.006',9),('st36.008',9),('st36.010',9),
('st36.011',9),('st37.003',9),('st37.004',9),('st37.007',9),('st37.016',9),('st37.017',9)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,m.Tariff AS amountCase,mes,cs.TypeCol,c.rf_idRecordCasePatient,cc.AmountPayment AS Amm
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_Mes m ON
			c.id=m.rf_idCase
					INNER JOIN #tCSG cs ON
			m.MES=cs.CSG			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=1 AND c.rf_idV008=31 AND a.rf_idSMO='34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

--SELECT *
--FROM #t
--WHERE AmountPayment>0 AND Amm<>AmountPayment AND amountCase<>Amm

ALTER TABLE #t ADD IsAmount TINYINT

update #t SET IsAmount=1
WHERE AmountPayment>0 AND Amm<>AmountPayment AND amountCase<>Amm

update t SET IsAmount=2
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
			t.rf_idCase=m.rf_idCase
WHERE AmountPayment>0 AND m.MUGroupCode=60 AND m.MUUnGroupCode=3

INSERT #total
SELECT 2019,SUM(CASE WHEN IsAmount IS not NULL THEN t.amountCase else  t.AmountPayment  END )AS Col2
	,SUM(CASE WHEN t.TypeCol=7 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=7 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END ) AS Col3
	,SUM(CASE WHEN t.TypeCol=8 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=8 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col4
	,SUM(CASE WHEN t.TypeCol=9 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=9 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col5
	,COUNT(t.rf_idCase) AS Col6
	,Count(CASE WHEN t.TypeCol=7 THEN t.rf_idCase ELSE null END ) AS Col7
	,Count(CASE WHEN t.TypeCol=8 THEN t.rf_idCase ELSE null END ) AS Col4
	,Count(CASE WHEN t.TypeCol=9 THEN t.rf_idCase ELSE null END ) AS Col5
FROM #t t
WHERE t.AmountPayment>0
GO
DROP TABLE #t
GO
DROP TABLE #tCSG
GO
DECLARE @dateStartReg DATETIME='20200101',
		@dateEndReg DATETIME='20200708',
		@dateStartRegRAK DATETIME='20200101',
		@dateEndRegRAK DATETIME='20200710',
		@reportYear SMALLINT=2020,
		@reportMonth TINYINT=7

CREATE TABLE #tCSG(CSG VARCHAR(10),TypeCol TINYINT)
INSERT #tCSG(CSG,TypeCol)
VALUES('st01.001',7),('st02.001',7),('st02.002',7),('st02.003',7),('st02.005',7),('st02.007',7),('st02.008',7),('st02.009',7),('st02.010',7),('st02.011',7),('st03.002',7),
('st04.001',7),('st04.003',7),('st04.005',7),('st05.001',7),('st06.002',7),('st06.003',7),('st09.001',7),('st10.003',7),('st10.004',7),('st10.005',7),('st12.001',7),
('st12.002',7),('st12.010',7),('st12.011',7),('st12.012',7),('st14.001',7),('st15.001',7),('st15.003',7),('st15.005',7),('st15.010',7),('st15.011',7),('st15.017',7),
('st16.001',7),('st16.003',7),('st16.005',7),('st20.001',7),('st20.002',7),('st20.003',7),('st20.004',7),('st20.005',7),('st20.006',7),('st21.001',7),('st21.002',7),
('st21.007',7),('st21.008',7),('st22.002',7),('st23.001',7),('st23.003',7),('st24.003',7),('st25.001',7),('st26.001',7),('st27.001',7),('st27.002',7),('st27.003',7),
('st27.004',7),('st27.005',7),('st27.006',7),('st27.008',7),('st27.010',7),('st27.011',7),('st27.012',7),('st27.014',7),('st29.001',7),('st29.003',7),('st29.004',7),
('st29.005',7),('st29.009',7),('st29.010',7),('st30.001',7),('st30.002',7),('st30.003',7),('st30.004',7),('st30.005',7),('st31.001',7),('st31.002',7),('st31.003',7),
('st31.011',7),('st31.012',7),('st31.016',7),('st31.017',7),('st31.018',7),('st32.011',7),('st32.012',7),('st32.013',7),('st34.001',7),('st34.002',7),('st35.006',7),
('st36.004',7),('st36.005',7),('st36.012',7),('st37.011',7),('st37.012',7),('st12.009.2',7)
-------------------Covid
,('st12.009',7),('st12.008',8),('st12.013',9),('st23.004',8)
INSERT #tCSG(CSG,TypeCol)
VALUES('st02.004',8),('st02.012',8),('st02.013',8),('st04.002',8),('st04.004',8),('st05.004',8),('st05.008',8),('st06.001',8),('st07.001',8),('st09.002',8),('st09.003',8),('st09.005',8),
('st09.006',8),('st09.007',8),('st09.008',8),('st09.009',8),('st10.006',8),('st10.007',8),('st11.001',8),('st11.002',8),('st11.003',8),('st12.003',8),('st12.004',8),('st12.014',8),
('st13.001',8),('st13.004',8),('st13.005',8),('st13.006',8),('st13.007',8),('st14.002',8),('st14.003',8),('st15.002',8),('st15.004',8),('st15.018',8),('st15.007',8),('st15.008',8),
('st15.009',8),('st15.012',8),('st16.002',8),('st16.004',8),('st16.006',8),('st16.009',8),('st16.010',8),('st16.011',8),('st16.012',8),('st17.004',8),('st17.005',8),('st17.006',8),
('st18.001',8),('st18.002',8),('st18.003',8),('st20.007',8),('st20.008',8),('st20.009',8),('st21.003',8),('st21.004',8),('st21.005',8),('st21.006',8),('st22.001',8),('st22.003',8),
('st22.004',8),('st23.002',8),('st23.005',8),('st23.006',8),('st24.001',8),('st24.002',8),('st24.004',8),('st25.002',8),('st25.003',8),('st25.004',8),('st25.005',8),('st25.008',8),
('st25.009',8),('st27.007',8),('st27.009',8),('st28.001',8),('st28.002',8),('st28.003',8),('st29.002',8),('st29.006',8),('st29.011',8),('st29.012',8),('st30.006',8),('st30.007',8),
('st30.008',8),('st30.010',8),('st30.011',8),('st30.012',8),('st30.013',8),('st30.014',8),('st31.004',8),('st31.005',8),('st31.006',8),('st31.007',8),('st31.008',8),('st31.009',8),
('st31.013',8),('st31.019',8),('st32.001',8),('st32.002',8),('st32.005',8),('st32.008',8),('st32.009',8),('st32.010',8),('st32.014',8),('st32.015',8),('st32.016',8),('st32.017',8),
('st32.018',8),('st33.001',8),('st33.003',8),('st33.004',8),('st34.003',8),('st34.004',8),('st34.005',8),('st35.001',8),('st35.002',8),('st35.003',8),('st35.004',8),('st35.007',8),
('st35.008',8),('st36.007',8),('st36.009',8),('st37.001',8),('st37.002',8),('st37.005',8),('st37.006',8),('st37.008',8),('st37.009',8),('st37.010',8),('st37.013',8),('st37.014',8),
('st37.015',8),('st37.018',8),('st38.001',8),('st12.008.1',8),('st12.008.2',8),('st12.009.1',8),('st23.004.2',8)

INSERT #tCSG(CSG,TypeCol)
VALUES ('st02.006',9),('st03.001',9),('st04.006',9),('st05.002',9),('st05.003',9),('st05.005',9),('st09.004',9),('st09.010',9),('st10.001',9),('st10.002',9),('st11.004',9),('st12.005',9)
,('st12.006',9),('st12.007',9),('st13.002',9),('st13.003',9),('st15.019',9),('st15.020',9),('st15.013',9),('st15.014',9),('st15.015',9),('st15.016',9),('st16.007',9),('st16.008',9)
,('st17.001',9),('st17.002',9),('st17.003',9),('st17.007',9),('st20.010',9),('st25.006',9),('st25.007',9),('st25.010',9),('st25.011',9),('st25.012',9),('st27.013',9),('st28.004',9)
,('st28.005',9),('st29.007',9),('st29.008',9),('st29.013',9),('st30.009',9),('st30.015',9),('st31.010',9),('st31.014',9),('st31.015',9),('st32.003',9),('st32.004',9),('st32.006',9)
,('st32.007',9),('st33.002',9),('st33.005',9),('st33.006',9),('st33.007',9),('st33.008',9),('st35.005',9),('st35.009',9),('st36.001',9),('st36.002',9),('st36.003',9),('st36.006',9)
,('st36.008',9),('st36.010',9),('st36.011',9),('st37.003',9),('st37.004',9),('st37.007',9),('st37.016',9),('st37.017',9),('st12.013.1',9),('st12.013.2',9),('st12.013.3',9),('st23.004.1',9)

SELECT DISTINCT c.id AS rf_idCase, cc.AmountPayment,m.Tariff AS amountCase,mes,cs.TypeCol,c.rf_idRecordCasePatient,cc.AmountPayment AS Amm
INTO #t
FROM dbo.t_File f INNER JOIN dbo.t_RegistersAccounts a ON
			f.id=a.rf_idFiles
					INNER JOIN dbo.t_RecordCasePatient r ON
			a.id=r.rf_idRegistersAccounts	
					INNER JOIN dbo.t_CompletedCase cc ON
			cc.rf_idRecordCasePatient = r.id				
					INNER JOIN dbo.t_Case c ON
			r.id=c.rf_idRecordCasePatient		
					INNER JOIN t_Mes m ON
			c.id=m.rf_idCase
					INNER JOIN #tCSG cs ON
			m.MES=cs.CSG			
WHERE f.DateRegistration>=@dateStartReg AND f.DateRegistration<@dateEndReg  AND a.ReportYear=@reportYear AND  c.rf_idV006=1 AND c.rf_idV008=31 AND a.rf_idSMO='34'

UPDATE p SET p.AmountPayment=p.AmountPayment-r.AmountDeduction
FROM #t p INNER JOIN (SELECT c.rf_idCase,SUM(c.AmountDeduction) AS AmountDeduction
								FROM dbo.t_PaymentAcceptedCase2 c
								WHERE c.DateRegistration>=@dateStartRegRAK AND c.DateRegistration<@dateEndRegRAK 
								GROUP BY c.rf_idCase
							) r ON
			p.rf_idCase=r.rf_idCase

ALTER TABLE #t ADD IsAmount TINYINT

update #t SET IsAmount=1
WHERE AmountPayment>0 AND Amm<>AmountPayment AND amountCase<>Amm

update t SET IsAmount=2
FROM #t t INNER JOIN dbo.t_Meduslugi m ON
			t.rf_idCase=m.rf_idCase
WHERE AmountPayment>0 AND m.MUGroupCode=60 AND m.MUUnGroupCode=3

INSERT #total
SELECT 2020,SUM(CASE WHEN IsAmount IS not NULL THEN t.amountCase else  t.AmountPayment  END )AS Col2
	,SUM(CASE WHEN t.TypeCol=7 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=7 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END ) AS Col3
	,SUM(CASE WHEN t.TypeCol=8 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=8 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col4
	,SUM(CASE WHEN t.TypeCol=9 AND IsAmount IS NULL THEN t.AmountPayment WHEN t.TypeCol=9 AND IsAmount IS NOT NULL THEN t.amountCase ELSE 0.0 END )AS Col5
	,COUNT(t.rf_idCase) AS Col6
	,Count(CASE WHEN t.TypeCol=7 THEN t.rf_idCase ELSE null END ) AS Col7
	,Count(CASE WHEN t.TypeCol=8 THEN t.rf_idCase ELSE null END ) AS Col4
	,Count(CASE WHEN t.TypeCol=9 THEN t.rf_idCase ELSE null END ) AS Col5
FROM #t t
WHERE t.AmountPayment>0
GO
DROP TABLE #t
GO
DROP TABLE #tCSG
GO
SELECT * FROM #total ORDER BY ReportYear
GO
DROP TABLE #total