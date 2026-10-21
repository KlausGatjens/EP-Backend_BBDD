/* =============================================================================
   MYTHOS COWORKING - Sistema de Gestión de Reservas - Script de SQL Server
   DML 05 · Carga inicial de información (INSERT)
   -----------------------------------------------------------------------------
   Requiere: DDL/01 a DDL/04 (la reserva de ejemplo se registra con dbo.RegistrarReserva).
   Para volver a cargar los datos desde cero, ejecutar otra vez desde DDL/01.
   ============================================================================= */

USE MythosReservasDB;
GO

/* ---------- Datos de ejemplo ---------- */
INSERT INTO dbo.Salas (nombre, capacidad) VALUES
    (N'Sala Olimpo',  8),
    (N'Sala Atenea',  12),
    (N'Sala Hermes',  4);

INSERT INTO dbo.Usuarios (nombres, correo) VALUES
    (N'Ana Torres',   N'ana.torres@mythos.pe'),
    (N'Luis Ramírez', N'luis.ramirez@mythos.pe');

-- Reserva de ejemplo registrada mediante el procedimiento almacenado.
DECLARE @sala UNIQUEIDENTIFIER    = (SELECT codigo FROM dbo.Salas    WHERE nombre = N'Sala Olimpo');
DECLARE @usuario UNIQUEIDENTIFIER = (SELECT codigo FROM dbo.Usuarios WHERE correo = N'ana.torres@mythos.pe');
EXEC dbo.RegistrarReserva
    @codigoSala    = @sala,
    @codigoUsuario = @usuario,
    @fechaInicio   = '2026-12-01T14:00:00',
    @fechaFin      = '2026-12-01T15:00:00';
GO

/* ---------- Verificación rápida ---------- */
SELECT * FROM dbo.vw_ReservasDetalle;
GO
