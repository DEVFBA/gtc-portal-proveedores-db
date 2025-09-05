USE PortalProveedores
GO

ALTER TABLE Invoices_Pools_Header ADD Generated_By         varchar(60)   null
GO

ALTER TABLE Invoices_Pools_Header ADD [Path]               varchar(255)  null
GO


UPDATE Invoices_Pools_Header
SET Generated_By = '',
    [Path] = ''
GO

ALTER TABLE Invoices_Pools_Header ALTER COLUMN    Generated_By             varchar(60)   not null
GO

ALTER TABLE Invoices_Pools_Header ALTER COLUMN    [Path]   varchar(255)   not null
GO

SELECT * FROM Invoices_Pools_Header