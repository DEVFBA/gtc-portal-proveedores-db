USE PortalProveedores
GO

/*==============================================================*/
/* Table: Cat_Adobe_Sign_Agreement_Status                       */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_AgreementStatus_Invoices')
alter table Invoices
   drop constraint FK_AgreementStatus_Invoices
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Adobe_Sign_Agreement_Status')
            and   type = 'U')
   drop table Cat_Adobe_Sign_Agreement_Status
go

create table Cat_Adobe_Sign_Agreement_Status (
   Id_Agreement_Status  varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_ADOBE_SIGN_AGREEMENT_ST primary key nonclustered (Id_Agreement_Status)
)
go

/*==============================================================*/
/* Table: Invoices_Pools_Header                       */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices_Pools_Header') and o.name = 'FK_AgreementStatus_Invoices')
alter table Invoices_Pools_Header
   drop constraint FK_AgreementStatus_Invoices
go


if exists (select 1
            from  sysindexes
           where  id    = object_id('Invoices_Pools_Header')
            and   name  = 'IDX_FK_AGREEMENTSTATUS_INVOICES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Invoices_Pools_Header.IDX_FK_AGREEMENTSTATUS_INVOICES_FK
go

ALTER TABLE Invoices_Pools_Header ADD	Id_Agreement_Status varchar(10)          null
GO
ALTER TABLE Invoices_Pools_Header ADD	Document_Id			varchar(50)          null
GO
ALTER TABLE Invoices_Pools_Header ADD	Agreement_Id        varchar(50)          null
GO
ALTER TABLE Invoices_Pools_Header ADD	Next_Signer			varchar(50)          null
GO

create index IDX_FK_AGREEMENTSTATUS_INVOICES_FK on Invoices_Pools_Header (
Id_Agreement_Status ASC
)
go

alter table Invoices_Pools_Header
   add constraint FK_AgreementStatus_Invoices foreign key (Id_Agreement_Status)
      references Cat_Adobe_Sign_Agreement_Status (Id_Agreement_Status)
go