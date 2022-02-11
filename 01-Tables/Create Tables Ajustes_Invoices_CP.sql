USE PortalProveedores
GO


/*==============================================================*/
/* Table: Cat_Invoice_Types                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Invoice_Types') and o.name = 'FK_WFType_InvoicesType')
alter table Cat_Invoice_Types
   drop constraint FK_WFType_InvoicesType
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_InvocesType_Invoices')
alter table Invoices
   drop constraint FK_InvocesType_Invoices
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Invoice_Types')
            and   name  = 'IDX_WFTYPE_INVOICESTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Invoice_Types.IDX_WFTYPE_INVOICESTYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Invoice_Types')
            and   type = 'U')
   drop table Cat_Invoice_Types
go

/* Table: Cat_Invoice_Types                                     */
create table Cat_Invoice_Types (
   Id_Invoice_Type      varchar(10)          not null,
   Id_Workflow_Type     varchar(10)          null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_INVOICE_TYPES primary key nonclustered (Id_Invoice_Type)
)
go

/* Index: IDX_WFTYPE_INVOICESTYPE_FK                            */
create index IDX_WFTYPE_INVOICESTYPE_FK on Cat_Invoice_Types (
Id_Workflow_Type ASC
)
go

alter table Cat_Invoice_Types
   add constraint FK_WFType_InvoicesType foreign key (Id_Workflow_Type)
      references Cat_Workflow_Type (Id_Workflow_Type)
go


/*==============================================================*/
/* Table: Invoices                                              */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Carta_Porte_Requests') and o.name = 'FK_Invoces_RequestCP')
alter table Carta_Porte_Requests
   drop constraint FK_Invoces_RequestCP
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_CompanyVendor_CartaPorte')
alter table Invoices
   drop constraint FK_CompanyVendor_CartaPorte
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_InvocesType_Invoices')
alter table Invoices
   drop constraint FK_InvocesType_Invoices
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_ReceiptTypes_Invoices')
alter table Invoices
   drop constraint FK_ReceiptTypes_Invoices
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_SAT_EntityTypes_Invoices')
alter table Invoices
   drop constraint FK_SAT_EntityTypes_Invoices
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_Workflow_CartaPorte')
alter table Invoices
   drop constraint FK_Workflow_CartaPorte
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX_INVOCESTYPE_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX_INVOCESTYPE_INVOICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX__SAT_ENTITYTYPES_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX__SAT_ENTITYTYPES_INVOICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX_COMPANIVENDORS_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX_COMPANIVENDORS_INVOICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX_WORKFLOW_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX_WORKFLOW_INVOICES_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices')
            and   name  = 'IDX_RECEIPTTYPES_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices.IDX_RECEIPTTYPES_INVOICES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Invoices')
            and   type = 'U')
   drop table Invoices
go

/* Table: Invoices                                              */
create table Invoices (
   UUID                 varchar(50)          not null,
   Id_Workflow          numeric              null,
   Id_Invoice_Type      varchar(10)          not null,
   Id_Vendor            smallint             null,
   Id_Company           int                  null,
   Id_Receipt_Type      varchar(50)          not null,
   Id_Entity_Type       varchar(10)          not null,
   Serie                varchar(50)          not null,
   Folio                varchar(50)          not null,
   Invoice_Date         datetime             not null,
   XML_Path             varchar(255)         not null,
   PDF_Path             varchar(255)         null,
   Request_Number       int                  null,
   Due_Date             datetime             null,
   Payment_Date         datetime             null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_INVOICES primary key nonclustered (UUID)
)
go

/* Index: IDX_RECEIPTTYPES_INVOICES_FK                          */
create index IDX_RECEIPTTYPES_INVOICES_FK on Invoices (
Id_Receipt_Type ASC
)
go

/* Index: IDX_WORKFLOW_INVOICES_FK                              */
create index IDX_WORKFLOW_INVOICES_FK on Invoices (
Id_Workflow ASC
)
go

/* Index: IDX_COMPANIVENDORS_INVOICES_FK                        */
create index IDX_COMPANIVENDORS_INVOICES_FK on Invoices (
Id_Vendor ASC,
Id_Company ASC
)
go

/* Index: IDX__SAT_ENTITYTYPES_INVOICES_FK                      */
create index IDX__SAT_ENTITYTYPES_INVOICES_FK on Invoices (
Id_Entity_Type ASC
)
go

/* Index: IDX_INVOCESTYPE_INVOICES_FK                           */
create index IDX_INVOCESTYPE_INVOICES_FK on Invoices (
Id_Invoice_Type ASC
)
go

alter table Invoices
   add constraint FK_CompanyVendor_CartaPorte foreign key (Id_Vendor, Id_Company)
      references Companies_Vendors (Id_Vendor, Id_Company)
go

alter table Invoices
   add constraint FK_InvocesType_Invoices foreign key (Id_Invoice_Type)
      references Cat_Invoice_Types (Id_Invoice_Type)
go

alter table Invoices
   add constraint FK_ReceiptTypes_Invoices foreign key (Id_Receipt_Type)
      references SAT_Cat_Receipt_Types (Id_Receipt_Type)
go

alter table Invoices
   add constraint FK_SAT_EntityTypes_Invoices foreign key (Id_Entity_Type)
      references SAT_Cat_Entity_Types (Id_Entity_Type)
go

alter table Invoices
   add constraint FK_Workflow_CartaPorte foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go



/*==============================================================*/
/* Table: Carta_Porte_Requests                                  */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Carta_Porte_Requests') and o.name = 'FK_Company_RequestCP')
alter table Carta_Porte_Requests
   drop constraint FK_Company_RequestCP
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Carta_Porte_Requests') and o.name = 'FK_Invoces_RequestCP')
alter table Carta_Porte_Requests
   drop constraint FK_Invoces_RequestCP
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Carta_Porte_Requests')
            and   name  = 'IDX_COMPANY_REQUESTCP_FK'
            and   indid > 0
            and   indid < 255)
   drop index Carta_Porte_Requests.IDX_COMPANY_REQUESTCP_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Carta_Porte_Requests')
            and   name  = 'IDX_INVOCES_REQUESTCP_FK'
            and   indid > 0
            and   indid < 255)
   drop index Carta_Porte_Requests.IDX_INVOCES_REQUESTCP_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Carta_Porte_Requests')
            and   type = 'U')
   drop table Carta_Porte_Requests
go

/* Table: Carta_Porte_Requests                                  */
create table Carta_Porte_Requests (
   Id_Request_CP        numeric              identity,
   Id_Company           int                  not null,
   UUID                 varchar(50)          null,
   Request_Number       int                  not null,
   Path                 varchar(255)         not null,
   Register_Date        datetime             not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CARTA_PORTE_REQUESTS primary key nonclustered (Id_Request_CP)
)
go

/* Index: IDX_INVOCES_REQUESTCP_FK                              */
create index IDX_INVOCES_REQUESTCP_FK on Carta_Porte_Requests (
UUID ASC
)
go

/* Index: IDX_COMPANY_REQUESTCP_FK                              */
create index IDX_COMPANY_REQUESTCP_FK on Carta_Porte_Requests (
Id_Company ASC
)
go

alter table Carta_Porte_Requests
   add constraint FK_Company_RequestCP foreign key (Id_Company)
      references Companies (Id_Company)
go

alter table Carta_Porte_Requests
   add constraint FK_Invoces_RequestCP foreign key (UUID)
      references Invoices (UUID)
go

