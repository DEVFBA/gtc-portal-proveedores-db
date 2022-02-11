/*==============================================================*/
/* Table: SAT_CAT_States                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_CAT_States') and o.name = 'FK_SAT_Countries_States')
alter table SAT_CAT_States
   drop constraint FK_SAT_Countries_States
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Locations') and o.name = 'FK_SAT_States_Locations')
alter table SAT_Cat_Locations
   drop constraint FK_SAT_States_Locations
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Municipalities') and o.name = 'FK_SAT_States_Municipalities')
alter table SAT_Cat_Municipalities
   drop constraint FK_SAT_States_Municipalities
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SAT_CAT_States')
            and   name  = 'FK_SAT_COUNTRIES_STATES_FK'
            and   indid > 0
            and   indid < 255)
   drop index SAT_CAT_States.FK_SAT_COUNTRIES_STATES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('SAT_CAT_States')
            and   type = 'U')
   drop table SAT_CAT_States
go


create table SAT_CAT_States (
   Id_Country           varchar(50)          not null,
   Id_State             varchar(10)          not null,
   Description          varchar(500)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SAT_CAT_STATES primary key nonclustered (Id_Country, Id_State)
)
go

/* Index: FK_SAT_COUNTRIES_STATES_FK                            */

create index FK_SAT_COUNTRIES_STATES_FK on SAT_CAT_States (
Id_Country ASC
)
go

alter table SAT_Cat_States
   add constraint FK_SAT_Countries_States foreign key (Id_Country)
      references SAT_Cat_Countries (Id_Country)
go


/*==============================================================*/
/* Table: SAT_Cat_Municipalities                                */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Municipalities') and o.name = 'FK_SAT_States_Municipalities')
alter table SAT_Cat_Municipalities
   drop constraint FK_SAT_States_Municipalities
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Zip_Codes_Counties') and o.name = 'FK_SAT_ZipCodes_CountryStateMunicipality')
alter table SAT_Cat_Zip_Codes_Counties
   drop constraint FK_SAT_ZipCodes_CountryStateMunicipality
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SAT_Cat_Municipalities')
            and   name  = 'FK_SAT_STATES_MUNICIPALITIES_FK'
            and   indid > 0
            and   indid < 255)
   drop index SAT_Cat_Municipalities.FK_SAT_STATES_MUNICIPALITIES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('SAT_Cat_Municipalities')
            and   type = 'U')
   drop table SAT_Cat_Municipalities
go


create table SAT_Cat_Municipalities (
   Id_Country           varchar(50)          not null,
   Id_State             varchar(10)          not null,
   Id_Municipality      varchar(10)          not null,
   Description          varchar(500)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SAT_CAT_MUNICIPALITIES primary key nonclustered (Id_Country, Id_State, Id_Municipality)
)
go

/* Index: FK_SAT_STATES_MUNICIPALITIES_FK                       */
create index FK_SAT_STATES_MUNICIPALITIES_FK on SAT_Cat_Municipalities (
Id_Country ASC,
Id_State ASC
)
go

alter table SAT_Cat_Municipalities
   add constraint FK_SAT_States_Municipalities foreign key (Id_Country, Id_State)
      references SAT_CAT_States (Id_Country, Id_State)
go


/*==============================================================*/
/* Table: SAT_Cat_Locations                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Locations') and o.name = 'FK_SAT_States_Locations')
alter table SAT_Cat_Locations
   drop constraint FK_SAT_States_Locations
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SAT_Cat_Locations')
            and   name  = 'FK_SAT_STATES_LOCATIONS_FK'
            and   indid > 0
            and   indid < 255)
   drop index SAT_Cat_Locations.FK_SAT_STATES_LOCATIONS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('SAT_Cat_Locations')
            and   type = 'U')
   drop table SAT_Cat_Locations
go


create table SAT_Cat_Locations (
   Id_Country           varchar(50)          not null,
   Id_State             varchar(10)          not null,
   Id_Location          varchar(10)          not null,
   Description          varchar(500)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SAT_CAT_LOCATIONS primary key nonclustered (Id_Country, Id_State, Id_Location)
)
go

/* Index: FK_SAT_STATES_LOCATIONS_FK                            */
create index FK_SAT_STATES_LOCATIONS_FK on SAT_Cat_Locations (
Id_Country ASC,
Id_State ASC
)
go

alter table SAT_Cat_Locations
   add constraint FK_SAT_States_Locations foreign key (Id_Country, Id_State)
      references SAT_CAT_States (Id_Country, Id_State)
go



/*==============================================================*/
/* Table: SAT_Cat_Zip_Codes_Counties                            */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SAT_Cat_Zip_Codes_Counties') and o.name = 'FK_SAT_ZipCodes_CountryStateMunicipality')
alter table SAT_Cat_Zip_Codes_Counties
   drop constraint FK_SAT_ZipCodes_CountryStateMunicipality
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SAT_Cat_Zip_Codes_Counties')
            and   name  = 'IDXZIPCODE_COUNTY'
            and   indid > 0
            and   indid < 255)
   drop index SAT_Cat_Zip_Codes_Counties.IDXZIPCODE_COUNTY
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SAT_Cat_Zip_Codes_Counties')
            and   name  = 'FK_SAT_ZIPCODES_COUNTRYSTATEMUNICIPALITY_FK'
            and   indid > 0
            and   indid < 255)
   drop index SAT_Cat_Zip_Codes_Counties.FK_SAT_ZIPCODES_COUNTRYSTATEMUNICIPALITY_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('SAT_Cat_Zip_Codes_Counties')
            and   type = 'U')
   drop table SAT_Cat_Zip_Codes_Counties
go


create table SAT_Cat_Zip_Codes_Counties (
   Id_Country           varchar(50)          not null,
   Id_State             varchar(10)          not null,
   Id_Municipality      varchar(10)          not null,
   Id_Location          varchar(10)          not null,
   Zip_Code            varchar(10)          not null,
   Id_County            varchar(10)          not null,
   Description          varchar(500)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SAT_CAT_ZIP_CODES_COUNTIES primary key nonclustered (Id_Country, Id_State, Id_Municipality, Id_County, Zip_Code, Id_Location)
)
go

/* Index: FK_SAT_ZIPCODES_COUNTRYSTATEMUNICIPALITY_FK           */
create index FK_SAT_ZIPCODES_COUNTRYSTATEMUNICIPALITY_FK on SAT_Cat_Zip_Codes_Counties (
Id_Country ASC,
Id_State ASC,
Id_Municipality ASC
)
go

/* Index: IDXZIPCODE_COUNTY                                     */
create index IDXZIPCODE_COUNTY on SAT_Cat_Zip_Codes_Counties (
Zip_Code ASC,
Id_County ASC
)
go

alter table SAT_Cat_Zip_Codes_Counties
   add constraint FK_SAT_ZipCodes_CountryStateMunicipality foreign key (Id_Country, Id_State, Id_Municipality)
      references SAT_Cat_Municipalities (Id_Country, Id_State, Id_Municipality)
go
