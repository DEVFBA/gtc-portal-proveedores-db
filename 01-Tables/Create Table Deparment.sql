/*==============================================================*/
/* Table: Cat_Departments                                       */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Users') and o.name = 'FK_Deparment_Users')
alter table Security_Users
   drop constraint FK_Deparment_Users
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Departments')
            and   type = 'U')
   drop table Cat_Departments
go


create table Cat_Departments (
   Id_Department        varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_DEPARTMENTS primary key nonclustered (Id_Department)
)
go


/*==============================================================*/
/* Table: Security_Users                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Security_Users') and o.name = 'FK_Deparment_Users')
alter table Security_Users
   drop constraint FK_Deparment_Users
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Security_Users')
            and   name  = 'IDX_DEPARRMENT_USERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Security_Users.IDX_DEPARRMENT_USERS_FK
go

ALTER TABLE Security_Users ADD Id_Department  varchar(10)  null

--UPDATE Security_Users SET Id_Department = ''

ALTER TABLE Security_Users ALTER COLUMN Id_Department  varchar(10)  not null

/*==============================================================*/
/* Index: IDX_DEPARRMENT_USERS_FK                               */
/*==============================================================*/
create index IDX_DEPARRMENT_USERS_FK on Security_Users (
Id_Department ASC
)
go

alter table Security_Users
   add constraint FK_Deparment_Users foreign key (Id_Department)
      references Cat_Departments (Id_Department)
go

select * from Cat_Departments
select * from Security_Users

