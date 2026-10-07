/* =====================================================================
   ACTIVIDAD 4 - EJERCICIO 1: ETL CON CURSORES (filas 1 a 100)
   Motor: SQL Server (T-SQL).  Ejecutar completo en SSMS, de arriba a abajo.
   Es re-ejecutable: limpia las tablas al inicio.
   ===================================================================== */

-- 0. Base de datos (cambia el nombre si ya tienes una)
IF DB_ID('ETL_Actividad4') IS NULL CREATE DATABASE ETL_Actividad4;
GO
USE ETL_Actividad4;
GO

-- 1. TABLAS ----------------------------------------------------------
IF OBJECT_ID('dbo.DEST_Personas_Rechazadas') IS NOT NULL DROP TABLE dbo.DEST_Personas_Rechazadas;
IF OBJECT_ID('dbo.DEST_Personas_Procesadas') IS NOT NULL DROP TABLE dbo.DEST_Personas_Procesadas;
IF OBJECT_ID('dbo.STG_Personas_Raw')         IS NOT NULL DROP TABLE dbo.STG_Personas_Raw;
GO

-- Staging: copia fiel del Excel (todo texto, sin tipar ni limpiar)
CREATE TABLE dbo.STG_Personas_Raw (
    SourceRowId         INT           NOT NULL PRIMARY KEY,
    DocumentType        NVARCHAR(10)  NULL,
    DocumentNumber      NVARCHAR(50)  NULL,
    FirstName           NVARCHAR(100) NULL,
    LastName            NVARCHAR(100) NULL,
    MonthlyIncome_Raw   NVARCHAR(50)  NULL,
    MonthlyExpenses_Raw NVARCHAR(50)  NULL
);

-- Destino: solo registros validos, con tipos correctos y balance
CREATE TABLE dbo.DEST_Personas_Procesadas (
    SourceRowId     INT           NOT NULL PRIMARY KEY,
    DocumentType    NVARCHAR(10)  NOT NULL,
    DocumentNumber  NVARCHAR(50)  NOT NULL,
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    MonthlyIncome   DECIMAL(14,2) NOT NULL,
    MonthlyExpenses DECIMAL(14,2) NOT NULL,
    BalanceMensual  DECIMAL(14,2) NOT NULL
);

-- Rechazados: id de origen + motivo + valor original problematico
CREATE TABLE dbo.DEST_Personas_Rechazadas (
    SourceRowId    INT           NOT NULL PRIMARY KEY,
    Motivo         NVARCHAR(200) NOT NULL,
    ValorOriginal  NVARCHAR(100) NULL
);
GO

-- 2. CARGA DEL STAGING (filas 1-100 del Excel, tal cual vienen) ------
INSERT INTO dbo.STG_Personas_Raw
    (SourceRowId, DocumentType, DocumentNumber, FirstName, LastName, MonthlyIncome_Raw, MonthlyExpenses_Raw)
VALUES
    (1, N'PA', N'SIM0000001', N'andrés', N'GARCÍA', N'4200000', N'9500000'),
    (2, N'PA', NULL, N'Andrés', N'López', N'14100000', N'11100000'),
    (3, N'PA', N'SIN-DATO', N'Valentina', N'Torres', N'7500000', N'10200000'),
    (4, N'cc', N'SIM0000004', N'Laura', N'López', N'13900000', N'3700000'),
    (5, N'CC', N'SIM0000005', N'Valentina', N'Álvarez', N'13800000', N'1200000'),
    (6, N'PA', N'SIM0000006', N'Óscar', N'Díaz', N'3200000', N'2500000'),
    (7, N'CC', N'SIM0000007', N'José', N'Álvarez', N'4000000', N'800000'),
    (8, N'CE', N'SIM0000008', N'Andrés', N'López', N'1000000', N'8900000'),
    (9, N'PA', N'SIM0000009', N'Felipe', N'Ruiz', N'8700000', N'10200000'),
    (10, N'CC', N'SIM0000010', N'Camila', N'García', N'2600000', N'11900000'),
    (11, N'CC', N'SIM0000011', N'María', N'Ramírez', N'9000000', N'3300000'),
    (12, N'CC', N'SIM0000012', N'Diana', N'Martínez', N'14600000', N'9800000'),
    (13, N'CC', N'SIM0000013', N'Santiago', N'Ruiz', N'dos millones', N'600000'),
    (14, N'CC', N'SIM0000014', N'Laura', N'García', N'14800000', N'9200000'),
    (15, N'PA', N'SIM0000015', N'Camila', N'Muñoz', N'7000000', N'6900000'),
    (16, N'CC', N'SIM0000016', N'Santiago', N'Ruiz', N'12300000', N'4100000'),
    (17, N'PA', N'SIM0000017', N'Valentina', N'Muñoz', N'8000000', N'8600000'),
    (18, N'CC', N'SIM0000018', N'Valentina', N'Gómez', N'$ 14.700.000,00', N'2600000'),
    (19, N'CC', N'SIM0000019', N'Juan', N'Muñoz', N'-500000', N'6400000'),
    (20, N'CC', N'SIM0000020', N'Camila', N'Peña', N'dos millones', N'400000'),
    (21, N'CC', N'SIM0000021', N'José', N'Muñoz', N'14500000', NULL),
    (22, N'CC', N'SIM0000022', N'Valentina', N'López', N'5300000', N'8900000,50'),
    (23, N'CE', N'SIM0000023', N'María', N'Cañón', N'3600000', N'11000000'),
    (24, N'CC', N'SIM0000024', N'María', N'Rodríguez', N'9500000', N'6200000'),
    (25, N'CE', N'SIM0000025', N'Camila', N'Ramírez', N'4500000', N'12000000'),
    (26, N'CE', N'SIM0000026', N'Andrés', N'Díaz', N'10000000', N'8900000'),
    (27, N'CC', N'SIM0000027', N'Luisa', N'Cañón', N'14800000', N'10700000'),
    (28, N'CC', N'SIM0000028', N'María', N'Álvarez', N'13100000', N'1300000'),
    (29, N'CC', N'SIM0000029', N'Diego', N'Martínez', N'1100000', N'10600000'),
    (30, N'CC', N'SIM0000030', N'Santiago', N'Gómez', N'7500000', N'5900000'),
    (31, N'CC', NULL, N'Santiago', N'García', N'2600000', N'1100000'),
    (32, N'PA', N'SIM0000032', N'María', N'Ruiz', N'4100000', N'7700000'),
    (33, N'PA', N'SIM0000033', NULL, N'Martínez', N'1600000', N'11000000'),
    (34, N'CE', N'SIM0000034', N'Carlos', N'Gómez', N'13200000', N'9300000'),
    (35, N'CC', N'SIM0000035', N'Paula', N'Martínez', N'11300000', N'10500000'),
    (36, N'PA', N'SIM0000036', N'Valentina', N'Cañón', N'3800000', N'12000000'),
    (37, N'CC', N'SIM0000037', N'camila', N'MARTÍNEZ', N'9700000', N'11100000'),
    (38, N'CC', NULL, N'Andrés', N'Muñoz', N'11400000', N'8900000'),
    (39, N'CC', N'SIN-DATO', N'María', N'Martínez', N'3000000', N'200000'),
    (40, N'cc', N'SIM0000040', N'Andrés', N'Díaz', N'4500000', N'9200000'),
    (41, N'CC', N'SIM0000041', N'Ana', N'Díaz', N'10900000', N'9500000'),
    (42, N'CC', N'SIM0000042', N'Santiago', N'Álvarez', N'7400000', N'2300000'),
    (43, N'PA', N'SIM0000043', N'Valentina', N'Torres', N'12300000', N'11600000'),
    (44, N'CC', N'SIM0000044', N'Paula', N'Rodríguez', N'7200000', N'11700000'),
    (45, N'PA', N'SIM0000045', N'Felipe', N'Cañón', N'6900000', N'12000000'),
    (46, N'CE', N'SIM0000046', N'Paula', N'Ramírez', N'5700000', N'9900000'),
    (47, N'PA', N'SIM0000047', N'Valentina', N'Díaz', N'2900000', N'3900000'),
    (48, N'PA', N'SIM0000048', N'Diana', N'Torres', N'7400000', N'4900000'),
    (49, N'CC', N'SIM0000049', N'Santiago', N'Muñoz', N'dos millones', N'3300000'),
    (50, N'CC', N'SIM0000050', N'Diego', N'Díaz', N'8600000', N'11600000'),
    (51, N'CE', N'SIM0000051', N'Felipe', N'Cañón', N'8300000', N'800000'),
    (52, N'CC', N'SIM0000052', N'Laura', N'Álvarez', N'6100000', N'3100000'),
    (53, N'PA', N'SIM0000053', N'Óscar', N'Rodríguez', N'3500000', N'2800000'),
    (54, N'CC', N'SIM0000054', N'Santiago', N'Peña', N'$ 10.500.000,00', N'11200000'),
    (55, N'PA', N'SIM0000055', N'Laura', N'Rodríguez', N'-500000', N'600000'),
    (56, N'PA', N'SIM0000056', N'Felipe', N'Ruiz', N'dos millones', N'8400000'),
    (57, N'CC', N'SIM0000057', N'María', N'Martínez', N'5200000', NULL),
    (58, N'CE', N'SIM0000058', N'Carlos', N'Muñoz', N'1800000', N'500000,50'),
    (59, N'CC', N'SIM0000059', N'Diego', N'Peña', N'12100000', N'10600000'),
    (60, N'CC', N'SIM0000060', N'Diego', N'López', N'2100000', N'6800000'),
    (61, N'CC', N'SIM0000061', N'Luisa', N'Martínez', N'2200000', N'7700000'),
    (62, N'CE', N'SIM0000062', N'Ana', N'Gómez', N'12300000', N'10600000'),
    (63, N'CE', N'SIM0000063', N'Andrés', N'Pérez', N'5200000', N'5500000'),
    (64, N'CC', N'SIM0000064', N'Diana', N'Gómez', N'8400000', N'8600000'),
    (65, N'CC', N'SIM0000065', N'Óscar', N'Pérez', N'13900000', N'6800000'),
    (66, N'CC', N'SIM0000066', N'Santiago', N'Rodríguez', N'12000000', N'600000'),
    (67, N'CC', NULL, N'Andrés', N'Torres', N'8700000', N'1400000'),
    (68, N'PA', N'SIM0000068', N'Luisa', N'Díaz', N'14400000', N'2200000'),
    (69, N'CE', N'SIM0000069', NULL, N'Gómez', N'12800000', N'11600000'),
    (70, N'CC', N'SIM0000070', N'Ana', N'Ramírez', N'11200000', N'600000'),
    (71, N'CC', N'SIM0000071', N'Laura', N'Pérez', N'6000000', N'6000000'),
    (72, N'CC', N'SIM0000072', N'Juan', N'Martínez', N'5200000', N'3600000'),
    (73, N'CC', N'SIM0000073', N'valentina', N'CAÑÓN', N'10100000', N'6700000'),
    (74, N'PA', NULL, N'Santiago', N'Álvarez', N'14900000', N'9300000'),
    (75, N'CC', N'SIN-DATO', N'Diana', N'Peña', N'10600000', N'6700000'),
    (76, N'pa', N'SIM0000076', N'Ana', N'Díaz', N'13400000', N'2100000'),
    (77, N'CC', N'SIM0000077', N'Santiago', N'Álvarez', N'500000', N'3100000'),
    (78, N'CE', N'SIM0000078', N'Andrés', N'Pérez', N'6200000', N'6200000'),
    (79, N'CC', N'SIM0000079', N'Paula', N'Cañón', N'11500000', N'1100000'),
    (80, N'CC', N'SIM0000080', N'Santiago', N'Peña', N'11100000', N'10900000'),
    (81, N'CE', N'SIM0000081', N'Paula', N'Rodríguez', N'3600000', N'3900000'),
    (82, N'CC', N'SIM0000082', N'Camila', N'García', N'10800000', N'1200000'),
    (83, N'CC', N'SIM0000083', N'Andrés', N'Díaz', N'800000', N'4400000'),
    (84, N'CC', N'SIM0000084', N'Paula', N'Rodríguez', N'9200000', N'8300000'),
    (85, N'PA', N'SIM0000085', N'Santiago', N'Martínez', N'dos millones', N'2500000'),
    (86, N'CC', N'SIM0000086', N'Ana', N'Gómez', N'10800000', N'4000000'),
    (87, N'CC', N'SIM0000087', N'Ana', N'Díaz', N'13800000', N'11400000'),
    (88, N'CE', N'SIM0000088', N'Diana', N'Cañón', N'10100000', N'10500000'),
    (89, N'CC', N'SIM0000089', N'Andrés', N'Ruiz', N'11700000', N'400000'),
    (90, N'CE', N'SIM0000090', N'Ana', N'Peña', N'$ 5.200.000,00', N'3600000'),
    (91, N'PA', N'SIM0000091', N'Camila', N'Ruiz', N'-500000', N'3100000'),
    (92, N'CE', N'SIM0000092', N'Carlos', N'Gómez', N'dos millones', N'3300000'),
    (93, N'CE', N'SIM0000093', N'Carlos', N'Gómez', N'5600000', NULL),
    (94, N'CC', N'SIM0000094', N'Laura', N'Cañón', N'1100000', N'4600000,50'),
    (95, N'CC', N'SIM0000095', N'Diana', N'García', N'7500000', N'9400000'),
    (96, N'CC', N'SIM0000096', N'Diana', N'Torres', N'3800000', N'1400000'),
    (97, N'PA', N'SIM0000097', N'Luisa', N'López', N'1700000', N'1600000'),
    (98, N'CC', N'SIM0000098', N'Luisa', N'Cañón', N'7900000', N'11600000'),
    (99, N'CC', N'SIM0000099', N'Diana', N'Rodríguez', N'12500000', N'5200000'),
    (100, N'CC', N'SIM0000100', N'Paula', N'Ruiz', N'10200000', N'6900000');
GO

-- 3. FUNCION DE LIMPIEZA DE MONTOS ------------------------------------
-- Devuelve DECIMAL o NULL si el texto NO se puede convertir.
-- Formatos manejados:  '4200000' | '$ 14.700.000,00' | '8900000,50' | '-500000'
-- Regla: se quita $ y espacios, se quitan los puntos (miles) y la coma pasa a punto (decimal).
-- Nota: esta regla asume formato colombiano (punto = miles, coma = decimal).
CREATE OR ALTER FUNCTION dbo.fn_LimpiarMonto (@Texto NVARCHAR(50))
RETURNS DECIMAL(14,2)
AS
BEGIN
    DECLARE @t NVARCHAR(50) = LTRIM(RTRIM(@Texto));
    IF @t IS NULL OR @t = N'' RETURN NULL;

    SET @t = REPLACE(@t, N'$', N'');
    SET @t = REPLACE(@t, N' ', N'');
    SET @t = REPLACE(@t, N'.', N'');   -- puntos de miles
    SET @t = REPLACE(@t, N',', N'.');  -- coma decimal -> punto

    -- Solo digitos, un signo opcional al inicio y un punto decimal: evita que TRY_CONVERT acepte '1e5', etc.
    IF @t LIKE N'%[^0-9.-]%' OR @t LIKE N'%-%-%' OR @t LIKE N'%.%.%' OR CHARINDEX(N'-', @t) > 1
        RETURN NULL;

    RETURN TRY_CONVERT(DECIMAL(14,2), @t);   -- NULL si no es numerico (ej. 'dos millones')
END
GO

-- 4. CURSOR -----------------------------------------------------------
TRUNCATE TABLE dbo.DEST_Personas_Procesadas;
TRUNCATE TABLE dbo.DEST_Personas_Rechazadas;

DECLARE @SourceRowId INT,
        @DocTypeRaw  NVARCHAR(10),  @DocNumRaw  NVARCHAR(50),
        @FirstRaw    NVARCHAR(100), @LastRaw    NVARCHAR(100),
        @IncomeRaw   NVARCHAR(50),  @ExpenseRaw NVARCHAR(50);

-- Valores ya estandarizados
DECLARE @DocType NVARCHAR(10), @DocNum NVARCHAR(50),
        @First NVARCHAR(100),  @Last NVARCHAR(100),
        @Income DECIMAL(14,2), @Expense DECIMAL(14,2);

DECLARE @Motivo NVARCHAR(200), @ValorOriginal NVARCHAR(100);
DECLARE @Procesados INT = 0, @Aceptados INT = 0, @Rechazados INT = 0;

DECLARE cur_personas CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR
    SELECT SourceRowId, DocumentType, DocumentNumber, FirstName, LastName,
           MonthlyIncome_Raw, MonthlyExpenses_Raw
    FROM dbo.STG_Personas_Raw
    WHERE SourceRowId BETWEEN 1 AND 100
    ORDER BY SourceRowId;

OPEN cur_personas;
FETCH NEXT FROM cur_personas
    INTO @SourceRowId, @DocTypeRaw, @DocNumRaw, @FirstRaw, @LastRaw, @IncomeRaw, @ExpenseRaw;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Procesados += 1;
    SET @Motivo = NULL;
    SET @ValorOriginal = NULL;

    -- (a) TRIM + estandarizacion de texto (vacio -> NULL; mayusculas consistentes)
    SET @DocType = UPPER(NULLIF(LTRIM(RTRIM(@DocTypeRaw)), N''));
    SET @DocNum  = UPPER(NULLIF(LTRIM(RTRIM(@DocNumRaw)),  N''));
    SET @First   = UPPER(NULLIF(LTRIM(RTRIM(@FirstRaw)),   N''));
    SET @Last    = UPPER(NULLIF(LTRIM(RTRIM(@LastRaw)),    N''));

    -- (b) Conversion de montos (NULL si falta o no es numerico)
    SET @Income  = dbo.fn_LimpiarMonto(@IncomeRaw);
    SET @Expense = dbo.fn_LimpiarMonto(@ExpenseRaw);

    -- (c) Validaciones en orden; se registra el PRIMER motivo que falle
    IF @DocNum IS NULL OR @DocNum = N'SIN-DATO'
        SELECT @Motivo = N'Documento faltante o SIN-DATO', @ValorOriginal = @DocNumRaw;
    ELSE IF @DocType IS NULL OR @DocType NOT IN (N'CC', N'CE', N'PA')
        SELECT @Motivo = N'Tipo de documento invalido', @ValorOriginal = @DocTypeRaw;
    ELSE IF @First IS NULL
        SELECT @Motivo = N'Nombre faltante', @ValorOriginal = @FirstRaw;
    ELSE IF @Last IS NULL
        SELECT @Motivo = N'Apellido faltante', @ValorOriginal = @LastRaw;
    ELSE IF NULLIF(LTRIM(RTRIM(@IncomeRaw)), N'') IS NULL
        SELECT @Motivo = N'Ingreso faltante', @ValorOriginal = @IncomeRaw;
    ELSE IF @Income IS NULL
        SELECT @Motivo = N'Ingreso no numerico', @ValorOriginal = @IncomeRaw;
    ELSE IF NULLIF(LTRIM(RTRIM(@ExpenseRaw)), N'') IS NULL
        SELECT @Motivo = N'Gasto faltante', @ValorOriginal = @ExpenseRaw;
    ELSE IF @Expense IS NULL
        SELECT @Motivo = N'Gasto no numerico', @ValorOriginal = @ExpenseRaw;

    -- (d) Destino segun resultado (ingreso negativo es valido: no se rechaza)
    IF @Motivo IS NULL
    BEGIN
        INSERT INTO dbo.DEST_Personas_Procesadas
            (SourceRowId, DocumentType, DocumentNumber, FirstName, LastName,
             MonthlyIncome, MonthlyExpenses, BalanceMensual)
        VALUES
            (@SourceRowId, @DocType, @DocNum, @First, @Last,
             @Income, @Expense, @Income - @Expense);
        SET @Aceptados += 1;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.DEST_Personas_Rechazadas (SourceRowId, Motivo, ValorOriginal)
        VALUES (@SourceRowId, @Motivo, ISNULL(@ValorOriginal, N'<NULL>'));
        SET @Rechazados += 1;
    END

    FETCH NEXT FROM cur_personas
        INTO @SourceRowId, @DocTypeRaw, @DocNumRaw, @FirstRaw, @LastRaw, @IncomeRaw, @ExpenseRaw;
END

CLOSE cur_personas;
DEALLOCATE cur_personas;

-- 5. RESULTADOS -------------------------------------------------------
SELECT @Procesados AS Total_Procesados,
       @Aceptados  AS Total_Aceptados,
       @Rechazados AS Total_Rechazados;     -- esperado: 100 / 81 / 19
GO

-- Evidencia para el informe
SELECT Motivo, COUNT(*) AS Cantidad
FROM dbo.DEST_Personas_Rechazadas GROUP BY Motivo ORDER BY Cantidad DESC;

SELECT * FROM dbo.DEST_Personas_Rechazadas ORDER BY SourceRowId;

-- Antes / despues de casos clave (filas 18 = simbolos, 19 = negativo, 22 = coma decimal)
SELECT s.SourceRowId, s.MonthlyIncome_Raw, s.MonthlyExpenses_Raw,
       p.MonthlyIncome, p.MonthlyExpenses, p.BalanceMensual
FROM dbo.STG_Personas_Raw s
JOIN dbo.DEST_Personas_Procesadas p ON p.SourceRowId = s.SourceRowId
WHERE s.SourceRowId IN (1, 18, 19, 22, 54);

SELECT TOP 10 * FROM dbo.DEST_Personas_Procesadas ORDER BY SourceRowId;
