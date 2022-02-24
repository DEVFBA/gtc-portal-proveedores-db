if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('Cat_General_Parameters') and o.name = 'FK_Gruopers_GeneralParam')
alter table Cat_General_Parameters
   drop constraint FK_Gruopers_GeneralParam
go


alter table Cat_General_Parameters
   add constraint FK_Gruopers_GeneralParam foreign key (Id_Grouper)
      references Cat_Groupers (Id_Grouper)
go
