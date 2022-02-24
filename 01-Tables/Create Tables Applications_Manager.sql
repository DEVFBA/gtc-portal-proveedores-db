
/*==============================================================*/
/* Table: Cat_Applications                                      */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Setting_Templates') and o.name = 'FK_Applications_SettingsTamplate')
alter table Setting_Templates
   drop constraint FK_Applications_SettingsTamplate
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Applications')
            and   type = 'U')
   drop table Cat_Applications
go


create table Cat_Applications (
   Id_Application       smallint             not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Version              varchar(10)          not null,
   Technical_Description varchar(8000)        not null,
   Type                 varchar(50)          not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_APPLICATIONS primary key nonclustered (Id_Application)
)
go

/*==============================================================*/
/* Table: Setting_Templates                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Application_Settings') and o.name = 'FK_SettingsTemplate_App')
alter table Application_Settings
   drop constraint FK_SettingsTemplate_App
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Setting_Templates') and o.name = 'FK_Applications_SettingsTamplate')
alter table Setting_Templates
   drop constraint FK_Applications_SettingsTamplate
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Setting_Templates')
            and   name  = 'IDX_APPLICATIONS_SETTINGSTAMPLATE_FK'
            and   indid > 0
            and   indid < 255)
   drop index Setting_Templates.IDX_APPLICATIONS_SETTINGSTAMPLATE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Setting_Templates')
            and   type = 'U')
   drop table Setting_Templates
go

create table Setting_Templates (
   Id_Application       smallint             not null,
   Settings_Key         varchar(50)          not null,
   Settings_Name        varchar(255)         not null,
   Settings_Default_Value varchar(255)         null,
   Allow_Edit           bit                  not null,
   Required             bit                  not null,
   "Use"                varchar(30)          not null,
   Regular_Expression   varchar(255)         null,
   Tooltip              varchar(255)         null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_SETTING_TEMPLATES primary key nonclustered (Id_Application, Settings_Key)
)
go

create index IDX_APPLICATIONS_SETTINGSTAMPLATE_FK on Setting_Templates (
Id_Application ASC
)
go

alter table Setting_Templates
   add constraint FK_Applications_SettingsTamplate foreign key (Id_Application)
      references Cat_Applications (Id_Application)
go


/*==============================================================*/
/* Table: Application_Settings                                  */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Application_Settings') and o.name = 'FK_SettingsTemplate_App')
alter table Application_Settings
   drop constraint FK_SettingsTemplate_App
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Application_Settings')
            and   type = 'U')
   drop table Application_Settings
go

create table Application_Settings (
   Id_Application       smallint             not null,
   Settings_Key         varchar(50)          not null,
   Settings_Value       varchar(255)         not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_APPLICATION_SETTINGS primary key (Id_Application, Settings_Key)
)
go

alter table Application_Settings
   add constraint FK_SettingsTemplate_App foreign key (Id_Application, Settings_Key)
      references Setting_Templates (Id_Application, Settings_Key)
go
