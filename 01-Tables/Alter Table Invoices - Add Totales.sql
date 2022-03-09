use PortalProveedores
GO

/*==============================================================*/
/* ALTER Invoices Add Totals Fields                                 */ 
/*==============================================================*/
ALTER TABLE Invoices ADD    SubTotal            float   null
ALTER TABLE Invoices ADD    Transferred_Taxes   float   null
ALTER TABLE Invoices ADD    Withholded_Taxes    float   null
ALTER TABLE Invoices ADD    Total               float   null

UPDATE Invoices
SET SubTotal = 0,
    Transferred_Taxes = 0,
    Withholded_Taxes = 0,
    Total = 0

ALTER TABLE Invoices ALTER COLUMN    SubTotal            float   not null
ALTER TABLE Invoices ALTER COLUMN    Transferred_Taxes   float   not null
ALTER TABLE Invoices ALTER COLUMN    Withholded_Taxes    float   not null
ALTER TABLE Invoices ALTER COLUMN    Total               float   not null


/*==============================================================*/
/* ALTER Invoices Add Id_Currency Fields                                 */ 
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_Currency_Invoices')
alter table Invoices
   drop constraint FK_Currency_Invoices
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX_CURRENCY_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX_CURRENCY_INVOICES_FK
go


ALTER TABLE Invoices ADD Id_Currency Varchar(50) null
GO

UPDATE Invoices SET Id_Currency = 'MXN'
GO

ALTER TABLE Invoices ALTER COLUMN Id_Currency  Varchar(50) not null
GO

create index IDX_CURRENCY_INVOICES_FK on Invoices (
Id_Currency ASC
)
go

alter table Invoices
   add constraint FK_Currency_Invoices foreign key (Id_Currency)
      references SAT_Cat_Currencies (Id_Currency)
go