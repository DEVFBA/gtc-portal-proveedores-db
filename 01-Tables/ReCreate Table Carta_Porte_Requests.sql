/*=====================================================================================*/
--ELIMINA VERSION 1 - SELECT * FROM Carta_Porte_Requests
/*=====================================================================================*/
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

/*=====================================================================================*/
--REGENERACION DE TABLA
/*=====================================================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Carta_Porte_Requests') and o.name = 'FK_CompanyVendor_RequestCP')
alter table Carta_Porte_Requests
   drop constraint FK_CompanyVendor_RequestCP
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
            and   name  = 'IDX_COMPANYVENDOR_REQUESTCP_FK'
            and   indid > 0
            and   indid < 255)
   drop index Carta_Porte_Requests.IDX_COMPANYVENDOR_REQUESTCP_FK
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
   Id_Vendor            smallint             not null,
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

/* Index: IDX_COMPANYVENDOR_REQUESTCP_FK                        */
create index IDX_COMPANYVENDOR_REQUESTCP_FK on Carta_Porte_Requests (
Id_Vendor ASC,
Id_Company ASC
)
go

alter table Carta_Porte_Requests
   add constraint FK_CompanyVendor_RequestCP foreign key (Id_Vendor, Id_Company)
      references Companies_Vendors (Id_Vendor, Id_Company)
go

alter table Carta_Porte_Requests
   add constraint FK_Invoces_RequestCP foreign key (UUID)
      references Invoices (UUID)
go
