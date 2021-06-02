--ALTER TABLE tmpGood2020DN ADD id INT IDENTITY(1,1) NOT NULL

SELECT ReportYear,
       ENP,
       W,
       DateEnd,
       DS1,
       ISNULL(DS2,'') AS DS2,
       IsDNType,
       col8,
       Col9 AS Col9
       FROM tmpGood2020DN-- WHERE id>500000


SELECT ReportYear,
       ENP,
       W,
       DateEnd,
       DS1,
       ISNULL(DS2,'') AS DS2,
       IsDNType,
       col8,
       Col9 AS Col9
FROM tmpGood2019DN 

--SELECT ReportYear,
--       ENP,
--       W,
--       DateEnd,
--       DS1,
--       ISNULL(DS2,'') AS DS2,
--       IsDNType,
--       col8,
--       Col9 AS Col9
--FROM tmpGood2018DN 