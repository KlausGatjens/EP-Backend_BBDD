/* =============================================================================
   MYTHOS COWORKING - Sistema de Gestión de Reservas - Script de SQL Server
   DDL 02 · Creación de índices
   -----------------------------------------------------------------------------
   Requiere: DDL/01_creacion_tablas.sql
   Las claves primarias y las restricciones UNIQUE ya crean sus propios índices;
   aquí se agregan los índices de búsqueda de la tabla Reservas.
   ============================================================================= */

USE MythosReservasDB;
GO

/* ---------- Índices ---------- */
-- Acelera la búsqueda de solapamientos (sala + rango de fechas) y los JOIN por FK.
CREATE NONCLUSTERED INDEX IX_Reservas_Sala_Fechas
    ON dbo.Reservas (codigoSala, fechaInicio) INCLUDE (fechaFin);
CREATE NONCLUSTERED INDEX IX_Reservas_Usuario
    ON dbo.Reservas (codigoUsuario, fechaInicio);
GO
