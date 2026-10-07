/* =====================================================================
   PERSONA A - ESQUEMA ESTRELLA (DW)         Base: ETL_Personas_DW
   Granularidad del hecho: UNA OBSERVACION por persona y fecha de encuesta.
   Re-ejecutable: BORRA y recrea el DW (usar solo para empezar de cero).
   ===================================================================== */
IF DB_ID('ETL_Personas_DW') IS NULL CREATE DATABASE ETL_Personas_DW;
GO
USE ETL_Personas_DW;
GO

DROP TABLE IF EXISTS dbo.FACT_OBSERVACION;
DROP TABLE IF EXISTS dbo.DIM_PERSONA;
DROP TABLE IF EXISTS dbo.DIM_SITUACION_LABORAL;
DROP TABLE IF EXISTS dbo.DIM_EDUCACION;
DROP TABLE IF EXISTS dbo.DIM_UBICACION;
DROP TABLE IF EXISTS dbo.DIM_TIEMPO;
GO

/* Texto en NVARCHAR para que SSIS (Unicode) no choque con VARCHAR.
   Cada dimension: clave sustituta (IDENTITY) + clave natural UNIQUE.
   La UNIQUE sobre la clave natural es lo que impide duplicados al repetir la carga. */

CREATE TABLE dbo.DIM_TIEMPO (
    TiempoKey  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DIM_TIEMPO PRIMARY KEY,
    Fecha      DATE          NOT NULL CONSTRAINT UQ_DIM_TIEMPO_Fecha UNIQUE,
    Anio       SMALLINT      NOT NULL,
    Mes        TINYINT       NOT NULL,
    NombreMes  NVARCHAR(15)  NOT NULL,
    Trimestre  TINYINT       NOT NULL
);

CREATE TABLE dbo.DIM_UBICACION (
    UbicacionKey      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DIM_UBICACION PRIMARY KEY,
    MunicipalityCode  NVARCHAR(10) NOT NULL CONSTRAINT UQ_DIM_UBICACION_Mun UNIQUE,
    MunicipalityName  NVARCHAR(80) NOT NULL,
    DepartmentCode    NVARCHAR(10) NOT NULL,
    DepartmentName    NVARCHAR(80) NOT NULL
);

CREATE TABLE dbo.DIM_EDUCACION (
    EducacionKey      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DIM_EDUCACION PRIMARY KEY,
    NivelEducativoId  TINYINT      NOT NULL CONSTRAINT UQ_DIM_EDUCACION_Id UNIQUE,
    NivelEducativo    NVARCHAR(40) NOT NULL
);

CREATE TABLE dbo.DIM_SITUACION_LABORAL (
    SituacionLaboralKey INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DIM_SITUACION PRIMARY KEY,
    EstadoLaboralId     TINYINT      NOT NULL CONSTRAINT UQ_DIM_SITUACION_Id UNIQUE,
    EstadoLaboral       NVARCHAR(40) NOT NULL
);

CREATE TABLE dbo.DIM_PERSONA (
    PersonaKey      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DIM_PERSONA PRIMARY KEY,
    DocumentType    NVARCHAR(10) NOT NULL,
    DocumentNumber  NVARCHAR(50) NOT NULL,
    Sex             NVARCHAR(5)  NOT NULL,
    MaritalStatus   NVARCHAR(30) NULL,
    Disability      NVARCHAR(5)  NOT NULL,
    CONSTRAINT UQ_DIM_PERSONA_Doc UNIQUE (DocumentType, DocumentNumber)
);

CREATE TABLE dbo.FACT_OBSERVACION (
    FactKey               INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FACT_OBSERVACION PRIMARY KEY,
    PersonaKey            INT NOT NULL CONSTRAINT FK_FACT_Persona   REFERENCES dbo.DIM_PERSONA(PersonaKey),
    TiempoKey             INT NOT NULL CONSTRAINT FK_FACT_Tiempo    REFERENCES dbo.DIM_TIEMPO(TiempoKey),
    UbicacionKey          INT NOT NULL CONSTRAINT FK_FACT_Ubicacion REFERENCES dbo.DIM_UBICACION(UbicacionKey),
    EducacionKey          INT NOT NULL CONSTRAINT FK_FACT_Educacion REFERENCES dbo.DIM_EDUCACION(EducacionKey),
    SituacionLaboralKey   INT NOT NULL CONSTRAINT FK_FACT_Situacion REFERENCES dbo.DIM_SITUACION_LABORAL(SituacionLaboralKey),
    IngresoMensual        DECIMAL(14,2) NOT NULL,
    GastoMensual          DECIMAL(14,2) NOT NULL,
    BalanceMensual        DECIMAL(14,2) NOT NULL,
    CantidadObservaciones TINYINT       NOT NULL CONSTRAINT DF_FACT_Cant DEFAULT 1,
    ObservacionId_Origen  INT           NOT NULL,   -- trazabilidad hacia ETL_Personas_REL
    -- Clave unica del hecho: una observacion por persona y fecha
    CONSTRAINT UQ_FACT_Persona_Tiempo UNIQUE (PersonaKey, TiempoKey),
    CONSTRAINT UQ_FACT_ObsOrigen      UNIQUE (ObservacionId_Origen)
);
GO

SELECT name AS Tabla FROM sys.tables ORDER BY name;
