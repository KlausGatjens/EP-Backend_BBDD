/* =============================================================================
   MYTHOS COWORKING - Sistema de Gestión de Reservas - Script de SQL Server
   DDL 01 · Creación de la base de datos y de las tablas
   -----------------------------------------------------------------------------
   Crea la base MythosReservasDB con un esquema normalizado (3FN):
     - dbo.Usuarios  : personas que reservan.
     - dbo.Salas     : salas de reuniones disponibles.
     - dbo.Reservas  : tabla asociativa Usuario-Sala con un intervalo de tiempo.
   Incluye restricciones con nombre (PK, FK, UNIQUE, CHECK y DEFAULT).

   Orden de ejecución (completo, F5 en SSMS):
     DDL/01_creacion_tablas.sql
     DDL/02_creacion_indices.sql
     DDL/03_creacion_vista.sql
     DDL/04_procedimientos_almacenados.sql
     DML/05_carga_inicial.sql

   ATENCIÓN: es re-ejecutable; elimina y vuelve a crear los objetos, por lo
   que borra los datos existentes. Después de este script, ejecutar del 02 al 05.
   ============================================================================= */

IF DB_ID(N'MythosReservasDB') IS NULL
    CREATE DATABASE MythosReservasDB;
GO

USE MythosReservasDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ---------- Limpieza (orden inverso a las dependencias) ---------- */
DROP PROCEDURE IF EXISTS dbo.ActualizarReserva;
DROP PROCEDURE IF EXISTS dbo.RegistrarReserva;
DROP VIEW      IF EXISTS dbo.vw_ReservasDetalle;
DROP TABLE     IF EXISTS dbo.Reservas;
DROP TABLE     IF EXISTS dbo.Salas;
DROP TABLE     IF EXISTS dbo.Usuarios;
GO

/* ---------- Tablas ---------- */

CREATE TABLE dbo.Usuarios (
    codigo        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Usuarios_codigo        DEFAULT NEWSEQUENTIALID(),
    nombres       NVARCHAR(100)    NOT NULL,
    correo        NVARCHAR(150)    NOT NULL,
    fechaCreacion DATETIME2(0)     NOT NULL CONSTRAINT DF_Usuarios_fechaCreacion DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Usuarios         PRIMARY KEY CLUSTERED (codigo),
    CONSTRAINT UQ_Usuarios_correo  UNIQUE (correo),
    CONSTRAINT CK_Usuarios_nombres CHECK (LEN(LTRIM(RTRIM(nombres))) > 0),
    CONSTRAINT CK_Usuarios_correo  CHECK (correo LIKE N'%_@_%._%')
);
GO

CREATE TABLE dbo.Salas (
    codigo        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Salas_codigo        DEFAULT NEWSEQUENTIALID(),
    nombre        NVARCHAR(100)    NOT NULL,
    capacidad     INT              NOT NULL,
    fechaCreacion DATETIME2(0)     NOT NULL CONSTRAINT DF_Salas_fechaCreacion DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Salas           PRIMARY KEY CLUSTERED (codigo),
    CONSTRAINT UQ_Salas_nombre    UNIQUE (nombre),
    CONSTRAINT CK_Salas_nombre    CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),
    CONSTRAINT CK_Salas_capacidad CHECK (capacidad BETWEEN 1 AND 500)
);
GO

CREATE TABLE dbo.Reservas (
    codigo        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Reservas_codigo        DEFAULT NEWSEQUENTIALID(),
    codigoSala    UNIQUEIDENTIFIER NOT NULL,
    codigoUsuario UNIQUEIDENTIFIER NOT NULL,
    fechaInicio   DATETIME2(0)     NOT NULL,
    fechaFin      DATETIME2(0)     NOT NULL,
    fechaCreacion DATETIME2(0)     NOT NULL CONSTRAINT DF_Reservas_fechaCreacion DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Reservas         PRIMARY KEY CLUSTERED (codigo),
    -- Integridad referencial: no se puede eliminar una sala o usuario con reservas (NO ACTION).
    CONSTRAINT FK_Reservas_Salas    FOREIGN KEY (codigoSala)    REFERENCES dbo.Salas (codigo)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Reservas_Usuarios FOREIGN KEY (codigoUsuario) REFERENCES dbo.Usuarios (codigo)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Reservas_fechas   CHECK (fechaFin > fechaInicio)
);
GO
