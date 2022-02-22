USE PortalProveedores
GO

/* ==================================================================================*/
-- 1. UDT_Security_Access
/* ==================================================================================*/
PRINT 'Crea 1.  UDT_Security_Access' 
IF type_id('[dbo].[UDT_Security_Access]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Security_Access]
GO
CREATE TYPE [dbo].[UDT_Security_Access]AS TABLE
(
   Id_Role              varchar(10)          not null,
   Id_Module            smallint             not null,
   Id_SubModule         smallint             not null,
   Component_Module     varchar(50)          null,
   Layout_Module        varchar(50)          null,
   Order_Module         smallint             not null,
   Component_Submodule  varchar(50)          null,
   Layout_SubModule     varchar(50)          null,
   Order_Submodule      smallint             not null,
   Url                  varchar(255)         null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null
)
go


/* ==================================================================================*/
-- 2. UDT_Invoices_Pools
/* ==================================================================================*/
PRINT 'Crea 2.  UDT_Invoices_Pools' 
IF type_id('[dbo].[UDT_Invoices_Pools]') IS NOT NULL
        DROP TYPE  [dbo].[UDT_Invoices_Pools]
GO
CREATE TYPE [dbo].[UDT_Invoices_Pools]AS TABLE
(
   Comments             varchar(MAX)    not null,
   UUID                 varchar(50)     null,
   Id_Workflow          numeric         null
)
go
