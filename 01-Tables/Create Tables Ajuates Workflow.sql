
/*==============================================================*/
/* Table: Invoices                                              */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Invoices') and o.name = 'FK_CompanyVendor_CartaPorte')
alter table Invoices
   drop constraint FK_CompanyVendor_CartaPorte
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


create table Invoices (
   UUID                 varchar(50)          not null,
   Id_Workflow          numeric              null,
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
   Status               bit                  not null,
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

alter table Invoices
   add constraint FK_CompanyVendor_CartaPorte foreign key (Id_Vendor, Id_Company)
      references Companies_Vendors (Id_Vendor, Id_Company)
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
/* Table: Cat_File_Types                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Files') and o.name = 'FK_FilesTypes_Workflow')
alter table Workflow_Files
   drop constraint FK_FilesTypes_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_File_Types') and o.name = 'FK_FileTypes_WFTracker')
alter table Workflow_Tracker_File_Types
   drop constraint FK_FileTypes_WFTracker
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_File_Types')
            and   type = 'U')
   drop table Cat_File_Types
go


create table Cat_File_Types (
   Id_File_Type         varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Extension            varchar(3)           not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_FILE_TYPES primary key nonclustered (Id_File_Type)
)
go


/*==============================================================*/
/* Table: Workflow_Tracker_File_Types                           */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_File_Types') and o.name = 'FK_FileTypes_WFTracker')
alter table Workflow_Tracker_File_Types
   drop constraint FK_FileTypes_WFTracker
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_File_Types') and o.name = 'FK_WFTracker_FileTypes')
alter table Workflow_Tracker_File_Types
   drop constraint FK_WFTracker_FileTypes
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Tracker_File_Types')
            and   name  = 'IDX__FILETYPES_WFTRACKER_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Tracker_File_Types.IDX__FILETYPES_WFTRACKER_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Tracker_File_Types')
            and   name  = 'IDX_WFTRACKER_FILETYPES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Tracker_File_Types.IDX_WFTRACKER_FILETYPES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Tracker_File_Types')
            and   type = 'U')
   drop table Workflow_Tracker_File_Types
go


create table Workflow_Tracker_File_Types (
   Id_Workflow_Tracker  int                  not null,
   Id_File_Type         varchar(10)          not null,
   Mandatory            bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_WORKFLOW_TRACKER_FILE_TYPES primary key (Id_Workflow_Tracker, Id_File_Type)
)
go


/* Index: IDX_WFTRACKER_FILETYPES_FK                            */

create index IDX_WFTRACKER_FILETYPES_FK on Workflow_Tracker_File_Types (
Id_Workflow_Tracker ASC
)
go


/* Index: IDX__FILETYPES_WFTRACKER_FK                           */

create index IDX__FILETYPES_WFTRACKER_FK on Workflow_Tracker_File_Types (
Id_File_Type ASC
)
go

alter table Workflow_Tracker_File_Types
   add constraint FK_FileTypes_WFTracker foreign key (Id_File_Type)
      references Cat_File_Types (Id_File_Type)
go

alter table Workflow_Tracker_File_Types
   add constraint FK_WFTracker_FileTypes foreign key (Id_Workflow_Tracker)
      references Workflow_Tracker (Id_Workflow_Tracker)
go


/*==============================================================*/
/* Table: Cat_Notifications                                     */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Notifications') and o.name = 'FK_Notifications_Workflow')
alter table Workflow_Notifications
   drop constraint FK_Notifications_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Notifications') and o.name = 'FK_Notifications_WFTracker')
alter table Workflow_Tracker_Notifications
   drop constraint FK_Notifications_WFTracker
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Notifications')
            and   type = 'U')
   drop table Cat_Notifications
go


create table Cat_Notifications (
   Id_Notification      int                  not null,
   Short_Desc           varchar(50)          not null,
   Subject              varchar(255)         not null,
   Template_Path        varchar(255)         not null,
   Images_Path          varchar(255)         not null,
   Specific_Frequency   varchar(255)         null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_NOTIFICATIONS primary key nonclustered (Id_Notification)
)
go



/*==============================================================*/
/* Table: Workflow_Tracker_Notifications                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Notifications') and o.name = 'FK_Notifications_WFTracker')
alter table Workflow_Tracker_Notifications
   drop constraint FK_Notifications_WFTracker
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Notifications') and o.name = 'FK_WFTracker_Notifications')
alter table Workflow_Tracker_Notifications
   drop constraint FK_WFTracker_Notifications
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Tracker_Notifications')
            and   type = 'U')
   drop table Workflow_Tracker_Notifications
go


create table Workflow_Tracker_Notifications (
   Id_Workflow_Tracker  int                  not null,
   Id_Notification      int                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_WORKFLOW_TRACKER_NOTIFICATI primary key (Id_Workflow_Tracker, Id_Notification)
)
go

alter table Workflow_Tracker_Notifications
   add constraint FK_Notifications_WFTracker foreign key (Id_Notification)
      references Cat_Notifications (Id_Notification)
go

alter table Workflow_Tracker_Notifications
   add constraint FK_WFTracker_Notifications foreign key (Id_Workflow_Tracker)
      references Workflow_Tracker (Id_Workflow_Tracker)
go




/*==============================================================*/
/* Table: Cat_Reject_Reasons                                    */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Reject_Reasons') and o.name = 'FK_RejectReasons_Workflow')
alter table Workflow_Reject_Reasons
   drop constraint FK_RejectReasons_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Reject_Reasons') and o.name = 'FK_RejectReason_WFTracker')
alter table Workflow_Tracker_Reject_Reasons
   drop constraint FK_RejectReason_WFTracker
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Reject_Reasons')
            and   type = 'U')
   drop table Cat_Reject_Reasons
go


create table Cat_Reject_Reasons (
   Id_Reject_Reason     varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_REJECT_REASONS primary key nonclustered (Id_Reject_Reason)
)
go



/*==============================================================*/
/* Table: Workflow_Tracker_Reject_Reasons                       */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Reject_Reasons') and o.name = 'FK_RejectReason_WFTracker')
alter table Workflow_Tracker_Reject_Reasons
   drop constraint FK_RejectReason_WFTracker
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Tracker_Reject_Reasons') and o.name = 'FK_WFTracker_RejectReason')
alter table Workflow_Tracker_Reject_Reasons
   drop constraint FK_WFTracker_RejectReason
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Tracker_Reject_Reasons')
            and   name  = 'IDX__REJECTREASON_WFTRACKER_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Tracker_Reject_Reasons.IDX__REJECTREASON_WFTRACKER_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Tracker_Reject_Reasons')
            and   name  = 'IDX_WFTRACKER_REJECTREASON_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Tracker_Reject_Reasons.IDX_WFTRACKER_REJECTREASON_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Tracker_Reject_Reasons')
            and   type = 'U')
   drop table Workflow_Tracker_Reject_Reasons
go


create table Workflow_Tracker_Reject_Reasons (
   Id_Workflow_Tracker  int                  not null,
   Id_Reject_Reason     varchar(10)          not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_WORKFLOW_TRACKER_REJECT_REA primary key nonclustered (Id_Workflow_Tracker, Id_Reject_Reason)
)
go


/* Index: IDX_WFTRACKER_REJECTREASON_FK                         */

create index IDX_WFTRACKER_REJECTREASON_FK on Workflow_Tracker_Reject_Reasons (
Id_Workflow_Tracker ASC
)
go

/* Index: IDX__REJECTREASON_WFTRACKER_FK                        */

create index IDX__REJECTREASON_WFTRACKER_FK on Workflow_Tracker_Reject_Reasons (
Id_Reject_Reason ASC
)
go

alter table Workflow_Tracker_Reject_Reasons
   add constraint FK_RejectReason_WFTracker foreign key (Id_Reject_Reason)
      references Cat_Reject_Reasons (Id_Reject_Reason)
go

alter table Workflow_Tracker_Reject_Reasons
   add constraint FK_WFTracker_RejectReason foreign key (Id_Workflow_Tracker)
      references Workflow_Tracker (Id_Workflow_Tracker)
go


/*==============================================================*/
/* Table: Workflow_Files                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Files') and o.name = 'FK_FilesTypes_Workflow')
alter table Workflow_Files
   drop constraint FK_FilesTypes_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Files') and o.name = 'FK_Workflow_FileTypes')
alter table Workflow_Files
   drop constraint FK_Workflow_FileTypes
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Files')
            and   name  = 'IDX__FILESTYPES_WORKFLOW_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Files.IDX__FILESTYPES_WORKFLOW_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Files')
            and   name  = 'IDX_WORKFLOW_FILETYPES_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Files.IDX_WORKFLOW_FILETYPES_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Files')
            and   type = 'U')
   drop table Workflow_Files
go


create table Workflow_Files (
   Id_Workflow          numeric              not null,
   Id_File_Type         varchar(10)          not null,
   constraint PK_WORKFLOW_FILES primary key (Id_Workflow, Id_File_Type)
)
go

/* Index: IDX_WORKFLOW_FILETYPES_FK                             */

create index IDX_WORKFLOW_FILETYPES_FK on Workflow_Files (
Id_Workflow ASC
)
go


/* Index: IDX__FILESTYPES_WORKFLOW_FK                           */

create index IDX__FILESTYPES_WORKFLOW_FK on Workflow_Files (
Id_File_Type ASC
)
go

alter table Workflow_Files
   add constraint FK_FilesTypes_Workflow foreign key (Id_File_Type)
      references Cat_File_Types (Id_File_Type)
go

alter table Workflow_Files
   add constraint FK_Workflow_FileTypes foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go



/*==============================================================*/
/* Table: Workflow_Notifications                                */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Notifications') and o.name = 'FK_Notifications_Workflow')
alter table Workflow_Notifications
   drop constraint FK_Notifications_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Notifications') and o.name = 'FK_Workflow_Notifications')
alter table Workflow_Notifications
   drop constraint FK_Workflow_Notifications
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Notifications')
            and   name  = 'IDX_NOTIFICATIONS_WORKFLOW_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Notifications.IDX_NOTIFICATIONS_WORKFLOW_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Notifications')
            and   name  = 'IDX_WORKFLOW_NOTIFICATIONS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Notifications.IDX_WORKFLOW_NOTIFICATIONS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Notifications')
            and   type = 'U')
   drop table Workflow_Notifications
go


create table Workflow_Notifications (
   Id_Mail_Notification numeric              identity,
   Id_Notification      int                  not null,
   Id_Workflow          numeric              not null,
   "To"                 varchar(255)         not null,
   CC                   varchar(255)         null,
   Register_Date        datetime             not null,
   Notification_Date    datetime             null,
   Notification_Send    bit                  not null,
   constraint PK_WORKFLOW_NOTIFICATIONS primary key nonclustered (Id_Mail_Notification)
)
go

/* Index: IDX_WORKFLOW_NOTIFICATIONS_FK                         */
create index IDX_WORKFLOW_NOTIFICATIONS_FK on Workflow_Notifications (
Id_Workflow ASC
)
go

/* Index: IDX_NOTIFICATIONS_WORKFLOW_FK                         */

create index IDX_NOTIFICATIONS_WORKFLOW_FK on Workflow_Notifications (
Id_Notification ASC
)
go

alter table Workflow_Notifications
   add constraint FK_Notifications_Workflow foreign key (Id_Notification)
      references Cat_Notifications (Id_Notification)
go

alter table Workflow_Notifications
   add constraint FK_Workflow_Notifications foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go



/*==============================================================*/
/* Table: Workflow_Reject_Reasons                               */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Reject_Reasons') and o.name = 'FK_RejectReasons_Workflow')
alter table Workflow_Reject_Reasons
   drop constraint FK_RejectReasons_Workflow
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Workflow_Reject_Reasons') and o.name = 'FK_Workflow_RejectReasons')
alter table Workflow_Reject_Reasons
   drop constraint FK_Workflow_RejectReasons
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Reject_Reasons')
            and   name  = 'IDX__REJECTREASONS_WORKFLOW_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Reject_Reasons.IDX__REJECTREASONS_WORKFLOW_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Workflow_Reject_Reasons')
            and   name  = 'IDX_WORKFLOW_REJECTREASONS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Workflow_Reject_Reasons.IDX_WORKFLOW_REJECTREASONS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Workflow_Reject_Reasons')
            and   type = 'U')
   drop table Workflow_Reject_Reasons
go


create table Workflow_Reject_Reasons (
   Id_Workflow          numeric              not null,
   Id_Reject_Reason     varchar(10)          not null,
   constraint PK_WORKFLOW_REJECT_REASONS primary key (Id_Workflow, Id_Reject_Reason)
)
go


/* Index: IDX_WORKFLOW_REJECTREASONS_FK                         */

create index IDX_WORKFLOW_REJECTREASONS_FK on Workflow_Reject_Reasons (
Id_Workflow ASC
)
go


/* Index: IDX__REJECTREASONS_WORKFLOW_FK                        */

create index IDX__REJECTREASONS_WORKFLOW_FK on Workflow_Reject_Reasons (
Id_Reject_Reason ASC
)
go

alter table Workflow_Reject_Reasons
   add constraint FK_RejectReasons_Workflow foreign key (Id_Reject_Reason)
      references Cat_Reject_Reasons (Id_Reject_Reason)
go

alter table Workflow_Reject_Reasons
   add constraint FK_Workflow_RejectReasons foreign key (Id_Workflow)
      references Workflow (Id_Workflow)
go
