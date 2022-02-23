/*==============================================================*/
/* Table: Cat_Approval_Types                                    */
/*==============================================================*/

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Approvals') and o.name = 'FK_ApprovalType_RoleApproval')
alter table Role_Approvals
   drop constraint FK_ApprovalType_RoleApproval
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Cat_Approval_Types')
            and   type = 'U')
   drop table Cat_Approval_Types
go


create table Cat_Approval_Types (
   Id_Approval_Type     varchar(10)          not null,
   Short_Desc           varchar(50)          not null,
   Long_Desc            varchar(255)         not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_CAT_APPROVAL_TYPES primary key nonclustered (Id_Approval_Type)
)
go


/*==============================================================*/
/* Table: Role_Approvals                                        */
/*==============================================================*/
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Approvals') and o.name = 'FK_ApprovalType_RoleApproval')
alter table Role_Approvals
   drop constraint FK_ApprovalType_RoleApproval
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Approvals') and o.name = 'FK_Roles_RoleApprovals')
alter table Role_Approvals
   drop constraint FK_Roles_RoleApprovals
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Role_Approvals') and o.name = 'FK_Users_RoleApprovals')
alter table Role_Approvals
   drop constraint FK_Users_RoleApprovals
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Role_Approvals')
            and   name  = 'IDX_APPROVALTYPE_ROLEAPPROVAL_FK'
            and   indid > 0
            and   indid < 255)
   drop index Role_Approvals.IDX_APPROVALTYPE_ROLEAPPROVAL_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Role_Approvals')
            and   name  = 'IDX_USERS_ROLEAPPROVALS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Role_Approvals.IDX_USERS_ROLEAPPROVALS_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('Role_Approvals')
            and   name  = 'IDX_ROLES_ROLEAPPROVALS_FK'
            and   indid > 0
            and   indid < 255)
   drop index Role_Approvals.IDX_ROLES_ROLEAPPROVALS_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('Role_Approvals')
            and   type = 'U')
   drop table Role_Approvals
go


create table Role_Approvals (
   Id_Role              varchar(10)          not null,
   "User"               varchar(60)          not null,
   Id_Approval_Type     varchar(10)          not null,
   Apply_Sign           bit                  not null,
   Order_Sign           smallint             not null,
   Status               bit                  not null,
   Modify_By            varchar(60)          not null,
   Modify_Date          datetime             not null,
   Modify_IP            varchar(20)          not null,
   constraint PK_ROLE_APPROVALS primary key (Id_Role, "User")
)
go

/*==============================================================*/
/* Index: IDX_ROLES_ROLEAPPROVALS_FK                            */
/*==============================================================*/
create index IDX_ROLES_ROLEAPPROVALS_FK on Role_Approvals (
Id_Role ASC
)
go

/*==============================================================*/
/* Index: IDX_USERS_ROLEAPPROVALS_FK                            */
/*==============================================================*/
create index IDX_USERS_ROLEAPPROVALS_FK on Role_Approvals (
"User" ASC
)
go

/*==============================================================*/
/* Index: IDX_APPROVALTYPE_ROLEAPPROVAL_FK                      */
/*==============================================================*/
create index IDX_APPROVALTYPE_ROLEAPPROVAL_FK on Role_Approvals (
Id_Approval_Type ASC
)
go

alter table Role_Approvals
   add constraint FK_ApprovalType_RoleApproval foreign key (Id_Approval_Type)
      references Cat_Approval_Types (Id_Approval_Type)
go

alter table Role_Approvals
   add constraint FK_Roles_RoleApprovals foreign key (Id_Role)
      references Security_Roles (Id_Role)
go

alter table Role_Approvals
   add constraint FK_Users_RoleApprovals foreign key ("User")
      references Security_Users ("User")
go
