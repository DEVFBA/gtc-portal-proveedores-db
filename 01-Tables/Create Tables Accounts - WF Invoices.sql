USE PORTALPROVEEDORES

/*==============================================================*/
/* Alter Table: Invoices_Pools_Detail                                 */
/*==============================================================*/

Alter table Cat_File_Types ADD File_Name_Prefix     varchar(50)          null
Alter table Cat_File_Types ADD [Path]               varchar(255)         null
   
/*==============================================================*/
/* Table: Cat_Account_Types                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Accounts') and o.name = 'FK_AccountType_Accounts')
alter table Cat_Accounts
   drop constraint FK_AccountType_Accounts
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Account_Type') and o.name = 'FK_AccountType_Role')
alter table Role_Account_Type
   drop constraint FK_AccountType_Role
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Account_Types')
            and   type = 'U')
   drop table Cat_Account_Types
go

create table Cat_Account_Types (
   Id_Account_Type      varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_ACCOUNT_TYPES primary key nonclustered (Id_Account_Type)
)
go


/*==============================================================*/
/* Table: Cat_Accounts                                          */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_Accounts') and o.name = 'FK_AccountType_Accounts')
alter table Cat_Accounts
   drop constraint FK_AccountType_Accounts
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Cat_Accounts')
            and   name  = 'IDX_ACCOUNTTYPE_ACCOUNTS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Cat_Accounts.IDX_ACCOUNTTYPE_ACCOUNTS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Accounts')
            and   type = 'U')
   drop table Cat_Accounts
go

create table Cat_Accounts (
   Id_Account           numeric              identity,
   Id_Account_Type      varchar(10)          null,
   Business_Unit        varchar(15)          not null,
   Object_Account       varchar(15)          not null,
   Subsidiary           varchar(15)          not null,
   Account_Name         varchar(50)          not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_ACCOUNTS primary key nonclustered (Id_Account)
)
go

/* Index: IDX_ACCOUNTTYPE_ACCOUNTS_FK                           */
create index IDX_ACCOUNTTYPE_ACCOUNTS_FK on Cat_Accounts (
Id_Account_Type ASC
)
go

alter table Cat_Accounts
   add constraint FK_AccountType_Accounts foreign key (Id_Account_Type)
      references Cat_Account_Types (Id_Account_Type)
go



/*==============================================================*/
/* Table: Role_Account_Type                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Account_Type') and o.name = 'FK_AccountType_Role')
alter table Role_Account_Type
   drop constraint FK_AccountType_Role
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Account_Type') and o.name = 'FK_Roles_AccountType')
alter table Role_Account_Type
   drop constraint FK_Roles_AccountType
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Role_Account_Type')
            and   name  = 'IDX_ROLES_ACCOUNTTYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Role_Account_Type.IDX_ROLES_ACCOUNTTYPE_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Role_Account_Type')
            and   name  = 'IDX_ACCOUNTTYPE_ROLE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Role_Account_Type.IDX_ACCOUNTTYPE_ROLE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Role_Account_Type')
            and   type = 'U')
   drop table Role_Account_Type
go


create table Role_Account_Type (
   Id_Account_Type      varchar(10)          not null,
   Id_Role              varchar(10)          not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_ROLE_ACCOUNT_TYPE primary key (Id_Account_Type, Id_Role)
)
go

/* Index: IDX_ACCOUNTTYPE_ROLE_FK                               */
create index IDX_ACCOUNTTYPE_ROLE_FK on Role_Account_Type (
Id_Account_Type ASC
)
go

/* Index: IDX_ROLES_ACCOUNTTYPE_FK                              */
create index IDX_ROLES_ACCOUNTTYPE_FK on Role_Account_Type (
Id_Role ASC
)
go

alter table Role_Account_Type
   add constraint FK_AccountType_Role foreign key (Id_Account_Type)
      references Cat_Account_Types (Id_Account_Type)
go

alter table Role_Account_Type
   add constraint FK_Roles_AccountType foreign key (Id_Role)
      references Security_Roles (Id_Role)
go



/*==============================================================*/
/* Table: Invoices_Pools_Header                                 */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Detail') and o.name = 'FK_Invoices_Pool_Header_Pool_Detail')
alter table Invoices_Pools_Detail
   drop constraint FK_Invoices_Pool_Header_Pool_Detail
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Invoices_Pools_Header')
            and   type = 'U')
   drop table Invoices_Pools_Header
go


create table Invoices_Pools_Header (
   Id_Invoice_Pool       numeric              identity,
   Comments             varchar(Max)         null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_INVOICES_POOLS_HEADER primary key nonclustered (Id_Invoice_Pool)
)
go



/*==============================================================*/
/* Table: Invoices_Pools_Detail                                 */
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
   Id_Invoice_Pool       numeric              not null,
   UUID                 varchar(50)          not null,
   Id_Workflow          numeric              null,
   constraint PK_INVOICES_POOLS_DETAIL primary key (Id_Invoice_Pool, UUID)
)
go

/* Index: IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK               */
create index IDX_INVOICES_POOL_HEADER_POOL_DETAIL_FK on Invoices_Pools_Detail (
Id_Invoice_Pool ASC
)
go

/* Index: IDX_WF_POOLS_DATAIL_FK                                */
create index IDX_WF_POOLS_DATAIL_FK on Invoices_Pools_Detail (
Id_Workflow ASC
)
go

/* Index: IDX_INVOICES_POOLS_DATAIL_FK                          */
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
