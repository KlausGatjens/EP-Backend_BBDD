/* =============================================================================
   MYTHOS COWORKING - Sistema de Gestión de Reservas - Script de SQL Server
   DDL 04 · Procedimientos almacenados
   -----------------------------------------------------------------------------
   Requiere: DDL/01 y DDL/03 (los procedimientos devuelven la reserva desde la vista).
     - dbo.RegistrarReserva  : registra una reserva (transacción + control de solapamiento).
     - dbo.ActualizarReserva : reprograma una reserva existente.
   ============================================================================= */

USE MythosReservasDB;
GO

/* ---------- Procedimientos almacenados ----------
   Códigos de error de negocio (THROW) que la API traduce a HTTP:
     50001 -> 400  Fechas inválidas
     50002 -> 404  La sala no existe
     50003 -> 404  El usuario no existe
     50004 -> 409  La sala ya está reservada en ese horario
     50005 -> 404  La reserva no existe
   ------------------------------------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.RegistrarReserva
    @codigoSala    UNIQUEIDENTIFIER,
    @codigoUsuario UNIQUEIDENTIFIER,
    @fechaInicio   DATETIME2(0),
    @fechaFin      DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;   -- cualquier error revierte la transacción completa

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @fechaInicio IS NULL OR @fechaFin IS NULL OR @fechaFin <= @fechaInicio
            THROW 50001, N'Las fechas de la reserva no son válidas', 1;

        -- UPDLOCK + HOLDLOCK bloquea la sala hasta el COMMIT: dos peticiones
        -- simultáneas no pueden reservar el mismo horario (evita condición de carrera).
        IF NOT EXISTS (SELECT 1 FROM dbo.Salas WITH (UPDLOCK, HOLDLOCK) WHERE codigo = @codigoSala)
            THROW 50002, N'La sala no existe', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE codigo = @codigoUsuario)
            THROW 50003, N'El usuario no existe', 1;

        -- Dos intervalos se solapan si uno empieza antes de que termine el otro.
        IF EXISTS (SELECT 1 FROM dbo.Reservas
                   WHERE codigoSala = @codigoSala
                     AND fechaInicio < @fechaFin
                     AND fechaFin    > @fechaInicio)
            THROW 50004, N'La sala ya está reservada en ese horario', 1;

        DECLARE @insertada TABLE (codigo UNIQUEIDENTIFIER);

        INSERT INTO dbo.Reservas (codigoSala, codigoUsuario, fechaInicio, fechaFin)
        OUTPUT INSERTED.codigo INTO @insertada
        VALUES (@codigoSala, @codigoUsuario, @fechaInicio, @fechaFin);

        COMMIT TRANSACTION;

        SELECT v.codigo, v.codigoSala, v.nombreSala, v.codigoUsuario, v.nombresUsuario,
               v.fechaInicio, v.fechaFin, v.fechaCreacion
        FROM dbo.vw_ReservasDetalle v
        INNER JOIN @insertada i ON i.codigo = v.codigo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.ActualizarReserva
    @codigo        UNIQUEIDENTIFIER,
    @codigoSala    UNIQUEIDENTIFIER,
    @codigoUsuario UNIQUEIDENTIFIER,
    @fechaInicio   DATETIME2(0),
    @fechaFin      DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Reservas WITH (UPDLOCK, HOLDLOCK) WHERE codigo = @codigo)
            THROW 50005, N'La reserva no existe', 1;

        IF @fechaInicio IS NULL OR @fechaFin IS NULL OR @fechaFin <= @fechaInicio
            THROW 50001, N'Las fechas de la reserva no son válidas', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Salas WITH (UPDLOCK, HOLDLOCK) WHERE codigo = @codigoSala)
            THROW 50002, N'La sala no existe', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE codigo = @codigoUsuario)
            THROW 50003, N'El usuario no existe', 1;

        -- Se excluye la propia reserva al verificar el solapamiento.
        IF EXISTS (SELECT 1 FROM dbo.Reservas
                   WHERE codigoSala = @codigoSala
                     AND codigo     <> @codigo
                     AND fechaInicio < @fechaFin
                     AND fechaFin    > @fechaInicio)
            THROW 50004, N'La sala ya está reservada en ese horario', 1;

        UPDATE dbo.Reservas
        SET codigoSala    = @codigoSala,
            codigoUsuario = @codigoUsuario,
            fechaInicio   = @fechaInicio,
            fechaFin      = @fechaFin
        WHERE codigo = @codigo;

        COMMIT TRANSACTION;

        SELECT codigo, codigoSala, nombreSala, codigoUsuario, nombresUsuario,
               fechaInicio, fechaFin, fechaCreacion
        FROM dbo.vw_ReservasDetalle
        WHERE codigo = @codigo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
