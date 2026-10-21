-- Ejecutar desde la carpeta de este repositorio.
-- En SSMS: activar Consulta > Modo SQLCMD antes de ejecutar.
-- ATENCION: el primer script borra las tablas y sus datos anteriores.
:On Error exit
:r .\DDL\01_creacion_tablas.sql
:r .\DDL\02_creacion_indices.sql
:r .\DDL\03_creacion_vista.sql
:r .\DDL\04_procedimientos_almacenados.sql
:r .\DML\05_carga_inicial.sql
