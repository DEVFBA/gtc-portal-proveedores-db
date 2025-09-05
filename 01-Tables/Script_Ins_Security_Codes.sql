USE PortalProveedores
GO

INSERT INTO Security_Codes
VALUES (1302,1,3,'Request Number - Not Exists ','El numero de solictud no existe','AZEPEDA',GETDATE(),'0.0.0.0')

SELECT * FROM Security_Codes 