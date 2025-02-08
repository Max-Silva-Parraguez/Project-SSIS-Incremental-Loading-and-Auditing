/*CREANDO LA BASE DE DATOS CARGA_INCREMENTAL*/

USE master
GO

IF EXISTS(SELECT NAME FROM SYS.databases WHERE NAME='CARGA_INCREMENTAL')
BEGIN
	DROP DATABASE CARGA_INCREMENTAL
END
GO


CREATE DATABASE CARGA_INCREMENTAL;
USE CARGA_INCREMENTAL;

-- Tabla de origen (datos nuevos llegan aquí)
CREATE TABLE Ventas_Origen (
    Row_ID INT,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code VARCHAR(50),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(18,4),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(18,4),
	Date_Insert DATETIME DEFAULT GETDATE(),
);


-- Tabla de destino (solo almacena nuevos o actualizados)
CREATE TABLE Ventas_Destino (
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(255),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(255),
    State VARCHAR(255),
    Postal_Code VARCHAR(50),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(18,4),
    Quantity INT,
    Discount DECIMAL(5,2),
	Profit DECIMAL(18,4),
    Date_Insert Datetime
);

-- Tabla de Auditoría (almacena detalles de modificaciones de algún registros)
CREATE TABLE Ventas_Auditoria (
    ID_Auditoria INT IDENTITY(1,1) PRIMARY KEY,
    Row_ID INT,  
    Order_ID VARCHAR(50),
    Fecha_Actualizacion DATETIME DEFAULT GETDATE(),
    Columnas_Modificadas VARCHAR(255),
    Valores_Anteriores NVARCHAR(MAX),
    Usuario NVARCHAR(255) DEFAULT SUSER_NAME(), -- Usuario que hizo la modificación
    IP_Equipo NVARCHAR(50) DEFAULT HOST_NAME()  -- IP o nombre del equipo que realizó la modificación
);



/*---------------------------------------------CONSULTA PARA LA LOGICA DEL PROYECTO---------------------------------------------*/


-- 1. Declaración de la tabla variable para almacenar los registros de auditoría
DECLARE @TempAuditoria TABLE (
    Row_ID INT,                           -- Identificador de la fila
    Order_ID VARCHAR(50),                 -- Identificador de la orden
    Fecha_Actualizacion DATETIME,         -- Fecha y hora en que se actualiza el registro
    Columnas_Modificadas VARCHAR(255),    -- Columnas que han sido modificadas
    Valores_Anteriores NVARCHAR(MAX)      -- Valores anteriores de las columnas modificadas
);

-- 2️. Guardar en la variable de tabla los registros que han cambiado
INSERT INTO @TempAuditoria (Row_ID, Order_ID, Fecha_Actualizacion, Columnas_Modificadas, Valores_Anteriores)
SELECT 
    target.Row_ID,
    target.Order_ID,
    GETDATE() AS Fecha_Actualizacion,
    STRING_AGG(CASE  
        WHEN target.Order_Date <> source.Order_Date THEN 'Order_Date' 
        WHEN target.Ship_Date <> source.Ship_Date THEN 'Ship_Date' 
        WHEN target.Ship_Mode <> source.Ship_Mode THEN 'Ship_Mode' 
        WHEN target.Customer_ID <> source.Customer_ID THEN 'Customer_ID' 
        WHEN target.Customer_Name <> source.Customer_Name THEN 'Customer_Name' 
        WHEN target.Segment <> source.Segment THEN 'Segment' 
        WHEN target.Country <> source.Country THEN 'Country' 
        WHEN target.City <> source.City THEN 'City' 
        WHEN target.State <> source.State THEN 'State' 
        WHEN target.Postal_Code <> source.Postal_Code THEN 'Postal_Code' 
        WHEN target.Region <> source.Region THEN 'Region' 
        WHEN target.Product_ID <> source.Product_ID THEN 'Product_ID' 
        WHEN target.Category <> source.Category THEN 'Category' 
        WHEN target.Sub_Category <> source.Sub_Category THEN 'Sub_Category' 
        WHEN target.Product_Name <> source.Product_Name THEN 'Product_Name' 
        WHEN target.Sales <> source.Sales THEN 'Sales' 
        WHEN target.Quantity <> source.Quantity THEN 'Quantity' 
        WHEN target.Discount <> source.Discount THEN 'Discount' 
        WHEN target.Profit <> source.Profit THEN 'Profit' 
    END, ', ') AS Columnas_Modificadas,  -- Se concatena (separado por comas) los nombres de las columnas que han cambiado.       
    STRING_AGG(CASE  
        WHEN target.Order_Date <> source.Order_Date THEN 'Order_Date: ' + CAST(target.Order_Date AS NVARCHAR) 
        WHEN target.Ship_Date <> source.Ship_Date THEN 'Ship_Date: ' + CAST(target.Ship_Date AS NVARCHAR) 
        WHEN target.Ship_Mode <> source.Ship_Mode THEN 'Ship_Mode: ' + target.Ship_Mode 
        WHEN target.Customer_ID <> source.Customer_ID THEN 'Customer_ID: ' + target.Customer_ID 
        WHEN target.Customer_Name <> source.Customer_Name THEN 'Customer_Name: ' + target.Customer_Name 
        WHEN target.Segment <> source.Segment THEN 'Segment: ' + target.Segment 
        WHEN target.Country <> source.Country THEN 'Country: ' + target.Country 
        WHEN target.City <> source.City THEN 'City: ' + target.City 
        WHEN target.State <> source.State THEN 'State: ' + target.State 
        WHEN target.Postal_Code <> source.Postal_Code THEN 'Postal_Code: ' + target.Postal_Code 
        WHEN target.Region <> source.Region THEN 'Region: ' + target.Region 
        WHEN target.Product_ID <> source.Product_ID THEN 'Product_ID: ' + target.Product_ID 
        WHEN target.Category <> source.Category THEN 'Category: ' + target.Category 
        WHEN target.Sub_Category <> source.Sub_Category THEN 'Sub_Category: ' + target.Sub_Category 
        WHEN target.Product_Name <> source.Product_Name THEN 'Product_Name: ' + target.Product_Name 
        WHEN target.Sales <> source.Sales THEN 'Sales: ' + CAST(target.Sales AS NVARCHAR) 
        WHEN target.Quantity <> source.Quantity THEN 'Quantity: ' + CAST(target.Quantity AS NVARCHAR) 
        WHEN target.Discount <> source.Discount THEN 'Discount: ' + CAST(target.Discount AS NVARCHAR) 
        WHEN target.Profit <> source.Profit THEN 'Profit: ' + CAST(target.Profit AS NVARCHAR) 
    END, '; ') AS Valores_Anteriores  -- Se concatena (separado por punto y coma) el nombre de la columna y su valor anterior
FROM Ventas_Destino AS target
JOIN Ventas_Origen AS source
    ON target.Row_ID = source.Row_ID
WHERE  
        target.Order_Date <> source.Order_Date OR
        target.Ship_Date <> source.Ship_Date OR
        target.Ship_Mode <> source.Ship_Mode OR
        target.Customer_ID <> source.Customer_ID OR
        target.Customer_Name <> source.Customer_Name OR
        target.Segment <> source.Segment OR
        target.Country <> source.Country OR
        target.City <> source.City OR
        target.State <> source.State OR
        target.Postal_Code <> source.Postal_Code OR
        target.Region <> source.Region OR
        target.Product_ID <> source.Product_ID OR
        target.Category <> source.Category OR
        target.Sub_Category <> source.Sub_Category OR
        target.Product_Name <> source.Product_Name OR
        target.Sales <> source.Sales OR
        target.Quantity <> source.Quantity OR
        target.Discount <> source.Discount OR
        target.Profit <> source.Profit  
       -- Se filtran los registros donde al menos una columna esta diferente entre origen y destino
GROUP BY target.Row_ID, target.Order_ID;

-- 3. Se inserta los cambios en la tabla de auditoría usando la variable de tabla
INSERT INTO Ventas_Auditoria (Row_ID, Order_ID, Fecha_Actualizacion, Columnas_Modificadas, Valores_Anteriores)
SELECT * FROM @TempAuditoria;  -- Se transfiere los registros auditados a la tabla física Ventas_Auditoria

-- 4️. Se realiza la actualización en Ventas_Destino usando MERGE
MERGE INTO Ventas_Destino AS target
USING Ventas_Origen AS source
ON target.Row_ID = source.Row_ID

--Cuando se encuentra un registro en ambas tablas (MATCHED) y existe al menos una diferencia en alguno de los campos especificados,
-- se ejecuta la cláusula UPDATE.
WHEN MATCHED AND (  
    target.Order_Date <> source.Order_Date OR
    target.Ship_Date <> source.Ship_Date OR
    target.Ship_Mode <> source.Ship_Mode OR
    target.Customer_ID <> source.Customer_ID OR
    target.Customer_Name <> source.Customer_Name OR
    target.Segment <> source.Segment OR
    target.Country <> source.Country OR
    target.City <> source.City OR
    target.State <> source.State OR
    target.Postal_Code <> source.Postal_Code OR
    target.Region <> source.Region OR
    target.Product_ID <> source.Product_ID OR
    target.Category <> source.Category OR
    target.Sub_Category <> source.Sub_Category OR
    target.Product_Name <> source.Product_Name OR
    target.Sales <> source.Sales OR
    target.Quantity <> source.Quantity OR
    target.Discount <> source.Discount OR
    target.Profit <> source.Profit
)  
THEN  
UPDATE SET  --Se actualizan los registros
    target.Order_Date = source.Order_Date,
    target.Ship_Date = source.Ship_Date,
    target.Ship_Mode = source.Ship_Mode,
    target.Customer_ID = source.Customer_ID,
    target.Customer_Name = source.Customer_Name,
    target.Segment = source.Segment,
    target.Country = source.Country,
    target.City = source.City,
    target.State = source.State,
    target.Postal_Code = source.Postal_Code,
    target.Region = source.Region,
    target.Product_ID = source.Product_ID,
    target.Category = source.Category,
    target.Sub_Category = source.Sub_Category,
    target.Product_Name = source.Product_Name,
    target.Sales = source.Sales,
    target.Quantity = source.Quantity,
    target.Discount = source.Discount,
    target.Profit = source.Profit

-- 5. Se inserta los datos nuevos si no existen en la tabla destino

WHEN NOT MATCHED THEN  
INSERT (Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name,  
        Segment, Country, City, State, Postal_Code, Region, Product_ID,  
        Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit, Date_Insert)  
VALUES (source.Row_ID, source.Order_ID, source.Order_Date, source.Ship_Date, source.Ship_Mode, source.Customer_ID, source.Customer_Name,  
        source.Segment, source.Country, source.City, source.State, source.Postal_Code, source.Region, source.Product_ID,  
        source.Category, source.Sub_Category, source.Product_Name, source.Sales, source.Quantity, source.Discount, source.Profit, source.Date_Insert);



