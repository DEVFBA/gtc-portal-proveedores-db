
/*==============================================================*/
/* 1 - Table: Invoices_Pools_Header                                 */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Detail') and o.name = 'FK_Invoices_Pool_Header_Pool_Detail')
alter table Invoices_Pools_Detail
   drop constraint FK_Invoices_Pool_Header_Pool_Detail
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Header') and o.name = 'FK_CompanyVendor_PoolHeader')
alter table Invoices_Pools_Header
   drop constraint FK_CompanyVendor_PoolHeader
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Header') and o.name = 'FK_Workflow_PoolHeader')
alter table Invoices_Pools_Header
   drop constraint FK_Workflow_PoolHeader
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Header')
            and   name  = 'IDX_WORKFLOW_POOLHEADER_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Header.IDX_WORKFLOW_POOLHEADER_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Header')
            and   name  = 'IDX_COMPANYVENDOR_POOLHEADER_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Header.IDX_COMPANYVENDOR_POOLHEADER_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Invoices_Pools_Header')
            and   type = 'U')
   drop table Invoices_Pools_Header
go


create table Invoices_Pools_Header (
   Id_Invoice_Pool      numeric              identity,
   Id_Workflow          numeric              null,
   Id_Company           int                  not null,
   Id_Vendor            smallint             not null,
   Pool_Date            datetime             not null,
   Total_Invoices       float                not null,
   Total_Amount         float                not null,
   Comments             varchar(Max)         null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_INVOICES_POOLS_HEADER primary key nonclustered (Id_Invoice_Pool)
)
go

/*==============================================================*/
/* Index: IDX_COMPANYVENDOR_POOLHEADER_FK                       */
/*==============================================================*/
create index IDX_COMPANYVENDOR_POOLHEADER_FK on Invoices_Pools_Header (
Id_Vendor ASC,
Id_Company ASC
)
go

/*==============================================================*/
/* Index: IDX_WORKFLOW_POOLHEADER_FK                            */
/*==============================================================*/
create index IDX_WORKFLOW_POOLHEADER_FK on Invoices_Pools_Header (
Id_Workflow ASC
)
go

alter table Invoices_Pools_Header
   add constraint FK_CompanyVendor_PoolHeader foreign key (Id_Vendor, Id_Company)
      references Companies_Vendors (Id_Vendor, Id_Company)
go

alter table Invoices_Pools_Header
   add constraint FK_Workflow_PoolHeader foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go



/*==============================================================*/
/* 2 - Table: Invoices_Pools_Detail                                 */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Detail') and o.name = 'FK_Invoices_Pool_Header_Pool_Detail')
alter table Invoices_Pools_Detail
   drop constraint FK_Invoices_Pool_Header_Pool_Detail
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Detail') and o.name = 'FK_Invoices_Pools_Datail')
alter table Invoices_Pools_Detail
   drop constraint FK_Invoices_Pools_Datail
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Detail') and o.name = 'FK_WF_Pools_Datail')
alter table Invoices_Pools_Detail
   drop constraint FK_WF_Pools_Datail
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Detail')
            and   name  = 'IDX_INVOICES_POOLS_DATAIL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Detail.IDX_INVOICES_POOLS_DATAIL_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Detail')
            and   name  = 'IDX_WF_POOLS_DATAIL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Detail.IDX_WF_POOLS_DATAIL_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Detail')
            and   name  = 'IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Detail.IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Invoices_Pools_Detail')
            and   type = 'U')
   drop table Invoices_Pools_Detail
go


create table Invoices_Pools_Detail (
   Id_Invoice_Pool      numeric              not null,
   UUID                 varchar(50)          not null,
   Id_Workflow          numeric              null,
   constraint PK_INVOICES_POOLS_DETAIL primary key (Id_Invoice_Pool, UUID)
)
go

/*==============================================================*/
/* Index: IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK               */
/*==============================================================*/
create index IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK on Invoices_Pools_Detail (
Id_Invoice_Pool ASC
)
go

/*==============================================================*/
/* Index: IDX_WF_POOLS_DATAIL_FK                                */
/*==============================================================*/
create index IDX_WF_POOLS_DATAIL_FK on Invoices_Pools_Detail (
Id_Workflow ASC
)
go

/*==============================================================*/
/* Index: IDX_INVOICES_POOLS_DATAIL_FK                          */
/*==============================================================*/
create index IDX_INVOICES_POOLS_DATAIL_FK on Invoices_Pools_Detail (
UUID ASC
)
go

alter table Invoices_Pools_Detail
   add constraint FK_Invoices_Pool_Header_Pool_Detail foreign key (Id_Invoice_Pool)
      references Invoices_Pools_Header (Id_Invoice_Pool)
go

alter table Invoices_Pools_Detail
   add constraint FK_Invoices_Pools_Datail foreign key (UUID)
      references Invoices (UUID)
go

alter table Invoices_Pools_Detail
   add constraint FK_WF_Pools_Datail foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go

