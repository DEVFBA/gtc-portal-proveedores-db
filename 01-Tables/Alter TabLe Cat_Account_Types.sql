use PortalProveedores

/*==============================================================*/
/* Table: Cat_Account_Types                                     */
/*==============================================================*/
ALTER TABLE Cat_Account_Types ADD Freight_Withholding   bit   null


UPDATE Cat_Account_Types
SET Freight_Withholding = 0


ALTER TABLE Cat_Account_Types ALTER COLUMN Freight_Withholding bit   not null

