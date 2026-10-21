/* =============================================================================
   MYTHOS COWORKING - Sistema de Gestión de Reservas - Script de SQL Server
   DDL 03 · Creación de la vista
   -----------------------------------------------------------------------------
   Requiere: DDL/01_creacion_tablas.sql
   dbo.vw_ReservasDetalle une Reservas con Salas y Usuarios para las lecturas de la API.
   ============================================================================= */

USE MythosReservasDB;
GO

/* ---------- Vista ---------- */
-- Une Reservas con Salas y Usuarios para las lecturas de la API,
-- sin duplicar nombres en la tabla Reservas (se respeta la 3FN).
CREATE VIEW dbo.vw_ReservasDetalle
AS
SELECT r.codigo,
       r.codigoSala,
       s.nombre  AS nombreSala,
       r.codigoUsuario,
       u.nombres AS nombresUsuario,
       r.fechaInicio,
       r.fechaFin,
       r.fechaCreacion
FROM dbo.Reservas r
INNER JOIN dbo.Salas    s ON s.codigo = r.codigoSala
INNER JOIN dbo.Usuarios u ON u.codigo = r.codigoUsuario;
GO
