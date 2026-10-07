/* =====================================================================
   PERSONA A - LAS 4 CONSULTAS DEL DW + VERIFICACION CONTRA EL MODELO RELACIONAL
   Ejecutar en ETL_Personas_DW despues de cargar el DW (SSIS B o A03).
   ===================================================================== */
USE ETL_Personas_DW;
GO

/* ---------- PARTE 1: LAS 4 CONSULTAS SOBRE EL DW ---------- */

-- Q1. Personas distintas por municipio
SELECT u.DepartmentName, u.MunicipalityName,
       COUNT(DISTINCT f.PersonaKey) AS PersonasDistintas
FROM dbo.FACT_OBSERVACION f
JOIN dbo.DIM_UBICACION u ON u.UbicacionKey = f.UbicacionKey
GROUP BY u.DepartmentName, u.MunicipalityName
ORDER BY PersonasDistintas DESC, u.MunicipalityName;

-- Q2. Ingreso promedio por nivel educativo
SELECT e.NivelEducativo,
       CAST(ROUND(AVG(f.IngresoMensual), 2) AS DECIMAL(14,2)) AS IngresoPromedio,
       COUNT(*) AS Observaciones
FROM dbo.FACT_OBSERVACION f
JOIN dbo.DIM_EDUCACION e ON e.EducacionKey = f.EducacionKey
GROUP BY e.NivelEducativo
ORDER BY IngresoPromedio DESC;

-- Q3. Balance promedio por situacion laboral
SELECT s.EstadoLaboral,
       CAST(ROUND(AVG(f.BalanceMensual), 2) AS DECIMAL(14,2)) AS BalancePromedio,
       COUNT(*) AS Observaciones
FROM dbo.FACT_OBSERVACION f
JOIN dbo.DIM_SITUACION_LABORAL s ON s.SituacionLaboralKey = f.SituacionLaboralKey
GROUP BY s.EstadoLaboral
ORDER BY BalancePromedio DESC;

-- Q4. Cantidad de observaciones por anio y mes
SELECT t.Anio, t.Mes, t.NombreMes, SUM(f.CantidadObservaciones) AS Observaciones
FROM dbo.FACT_OBSERVACION f
JOIN dbo.DIM_TIEMPO t ON t.TiempoKey = f.TiempoKey
GROUP BY t.Anio, t.Mes, t.NombreMes
ORDER BY t.Anio, t.Mes;
GO

/* ---------- PARTE 2: COMPARACION DW vs MODELO RELACIONAL ----------
   Cada bloque devuelve las filas que estan en un lado y no en el otro.
   RESULTADO ESPERADO: 0 filas en los cuatro bloques (los resultados coinciden). */

-- Q1 DW vs REL
WITH dw AS (
    SELECT CAST(u.DepartmentName AS NVARCHAR(80)) AS Dep, CAST(u.MunicipalityName AS NVARCHAR(80)) AS Mun,
           COUNT(DISTINCT f.PersonaKey) AS N
    FROM dbo.FACT_OBSERVACION f JOIN dbo.DIM_UBICACION u ON u.UbicacionKey = f.UbicacionKey
    GROUP BY u.DepartmentName, u.MunicipalityName),
rel AS (
    SELECT CAST(d.DepartmentName AS NVARCHAR(80)) COLLATE DATABASE_DEFAULT AS Dep,
           CAST(m.MunicipalityName AS NVARCHAR(80)) COLLATE DATABASE_DEFAULT AS Mun,
           COUNT(DISTINCT o.PersonaId) AS N
    FROM ETL_Personas_REL.dbo.OBSERVACION o
    JOIN ETL_Personas_REL.dbo.MUNICIPIO m    ON m.MunicipalityCode = ISNULL(RTRIM(o.MunicipalityCode), 'M999')
    JOIN ETL_Personas_REL.dbo.DEPARTAMENTO d ON d.DepartmentCode = m.DepartmentCode
    GROUP BY d.DepartmentName, m.MunicipalityName)
SELECT 'Q1: en DW, no en REL' AS Diferencia, * FROM (SELECT * FROM dw EXCEPT SELECT * FROM rel) a
UNION ALL
SELECT 'Q1: en REL, no en DW', * FROM (SELECT * FROM rel EXCEPT SELECT * FROM dw) b;

-- Q2 DW vs REL
WITH dw AS (
    SELECT CAST(e.NivelEducativo AS NVARCHAR(80)) AS Nivel,
           CAST(ROUND(AVG(f.IngresoMensual), 2) AS DECIMAL(14,2)) AS Prom, COUNT(*) AS N
    FROM dbo.FACT_OBSERVACION f JOIN dbo.DIM_EDUCACION e ON e.EducacionKey = f.EducacionKey
    GROUP BY e.NivelEducativo),
rel AS (
    SELECT CAST(c.Nombre AS NVARCHAR(80)) COLLATE DATABASE_DEFAULT AS Nivel,
           CAST(ROUND(AVG(o.MonthlyIncome), 2) AS DECIMAL(14,2)) AS Prom, COUNT(*) AS N
    FROM ETL_Personas_REL.dbo.OBSERVACION o
    JOIN ETL_Personas_REL.dbo.CAT_NIVEL_EDUCATIVO c ON c.NivelEducativoId = o.NivelEducativoId
    GROUP BY c.Nombre)
SELECT 'Q2: en DW, no en REL' AS Diferencia, * FROM (SELECT * FROM dw EXCEPT SELECT * FROM rel) a
UNION ALL
SELECT 'Q2: en REL, no en DW', * FROM (SELECT * FROM rel EXCEPT SELECT * FROM dw) b;

-- Q3 DW vs REL
WITH dw AS (
    SELECT CAST(s.EstadoLaboral AS NVARCHAR(80)) AS Estado,
           CAST(ROUND(AVG(f.BalanceMensual), 2) AS DECIMAL(14,2)) AS Prom, COUNT(*) AS N
    FROM dbo.FACT_OBSERVACION f JOIN dbo.DIM_SITUACION_LABORAL s ON s.SituacionLaboralKey = f.SituacionLaboralKey
    GROUP BY s.EstadoLaboral),
rel AS (
    SELECT CAST(c.Nombre AS NVARCHAR(80)) COLLATE DATABASE_DEFAULT AS Estado,
           CAST(ROUND(AVG(o.BalanceMensual), 2) AS DECIMAL(14,2)) AS Prom, COUNT(*) AS N
    FROM ETL_Personas_REL.dbo.OBSERVACION o
    JOIN ETL_Personas_REL.dbo.CAT_ESTADO_LABORAL c ON c.EstadoLaboralId = o.EstadoLaboralId
    GROUP BY c.Nombre)
SELECT 'Q3: en DW, no en REL' AS Diferencia, * FROM (SELECT * FROM dw EXCEPT SELECT * FROM rel) a
UNION ALL
SELECT 'Q3: en REL, no en DW', * FROM (SELECT * FROM rel EXCEPT SELECT * FROM dw) b;

-- Q4 DW vs REL
WITH dw AS (
    SELECT CAST(t.Anio AS INT) AS Anio, CAST(t.Mes AS INT) AS Mes, CAST(SUM(f.CantidadObservaciones) AS INT) AS N
    FROM dbo.FACT_OBSERVACION f JOIN dbo.DIM_TIEMPO t ON t.TiempoKey = f.TiempoKey
    GROUP BY t.Anio, t.Mes),
rel AS (
    SELECT YEAR(o.SurveyDate) AS Anio, MONTH(o.SurveyDate) AS Mes, COUNT(*) AS N
    FROM ETL_Personas_REL.dbo.OBSERVACION o
    GROUP BY YEAR(o.SurveyDate), MONTH(o.SurveyDate))
SELECT 'Q4: en DW, no en REL' AS Diferencia, * FROM (SELECT * FROM dw EXCEPT SELECT * FROM rel) a
UNION ALL
SELECT 'Q4: en REL, no en DW', * FROM (SELECT * FROM rel EXCEPT SELECT * FROM dw) b;
GO

/* ---------- PARTE 3: CONTROL DE CONTEOS Y DUPLICADOS ----------
   Correr esta parte DESPUES DE CADA EJECUCION de los paquetes (1.a y 2.a).
   Las columnas DW y REL deben ser iguales y NO cambiar entre la 1.a y la 2.a ejecucion. */

SELECT 'FACT_OBSERVACION vs OBSERVACION' AS Control,
       (SELECT COUNT(*) FROM dbo.FACT_OBSERVACION)                          AS DW,
       (SELECT COUNT(*) FROM ETL_Personas_REL.dbo.OBSERVACION)              AS REL
UNION ALL
SELECT 'DIM_PERSONA vs PERSONA',
       (SELECT COUNT(*) FROM dbo.DIM_PERSONA),
       (SELECT COUNT(*) FROM ETL_Personas_REL.dbo.PERSONA)
UNION ALL
SELECT 'DIM_UBICACION vs MUNICIPIO',
       (SELECT COUNT(*) FROM dbo.DIM_UBICACION),
       (SELECT COUNT(*) FROM ETL_Personas_REL.dbo.MUNICIPIO)
UNION ALL
SELECT 'DIM_EDUCACION vs CAT_NIVEL_EDUCATIVO',
       (SELECT COUNT(*) FROM dbo.DIM_EDUCACION),
       (SELECT COUNT(*) FROM ETL_Personas_REL.dbo.CAT_NIVEL_EDUCATIVO)
UNION ALL
SELECT 'DIM_SITUACION_LABORAL vs CAT_ESTADO_LABORAL',
       (SELECT COUNT(*) FROM dbo.DIM_SITUACION_LABORAL),
       (SELECT COUNT(*) FROM ETL_Personas_REL.dbo.CAT_ESTADO_LABORAL)
UNION ALL
SELECT 'DIM_TIEMPO vs fechas distintas de encuesta',
       (SELECT COUNT(*) FROM dbo.DIM_TIEMPO),
       (SELECT COUNT(DISTINCT SurveyDate) FROM ETL_Personas_REL.dbo.OBSERVACION);

-- Duplicados (esperado: 0 filas en cada una)
SELECT DocumentType, DocumentNumber, COUNT(*) AS Veces
FROM dbo.DIM_PERSONA GROUP BY DocumentType, DocumentNumber HAVING COUNT(*) > 1;

SELECT PersonaKey, TiempoKey, COUNT(*) AS Veces
FROM dbo.FACT_OBSERVACION GROUP BY PersonaKey, TiempoKey HAVING COUNT(*) > 1;

SELECT MunicipalityCode, COUNT(*) AS Veces
FROM dbo.DIM_UBICACION GROUP BY MunicipalityCode HAVING COUNT(*) > 1;

-- Hechos cuyo ingreso/gasto/balance no coincide con el modelo relacional (esperado: 0)
SELECT COUNT(*) AS Hechos_con_medidas_distintas
FROM dbo.FACT_OBSERVACION f
JOIN ETL_Personas_REL.dbo.OBSERVACION o ON o.ObservacionId = f.ObservacionId_Origen
WHERE f.IngresoMensual <> o.MonthlyIncome OR f.GastoMensual <> o.MonthlyExpenses OR f.BalanceMensual <> o.BalanceMensual;
