USE PortalProveedores
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- fnGetTransacErrorBD
/* ==================================================================================*/	
PRINT 'Crea fnGetOperationCRUD'

IF OBJECT_ID('[dbo].[fnGetOperationCRUD]','FN') IS NOT NULL
       DROP FUNCTION [dbo].[fnGetOperationCRUD]
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the type of CRUD operation
Creation:	23-10-2020
Return 
			@DescOperationCRUD Varchar(50)
Example:	
			Declare @DescOperationCRUD Varchar(50)
			SET @DescOperationCRUD = dbo.fnGetOperationCRUD('R')
			SELECT @DescOperationCRUD
*/
CREATE FUNCTION [dbo].[fnGetOperationCRUD](@pvOperationCRUD Varchar(30))
RETURNS VARCHAR(Max)
WITH ENCRYPTION AS
BEGIN
	Declare @vDescOperationCRUD Varchar(50)
	
	SET @vDescOperationCRUD = CASE @pvOperationCRUD
								WHEN 'C' THEN 'Create Records'
								WHEN 'R' THEN 'Read Records'
								WHEN 'U' THEN 'Update Records'
								WHEN 'D' THEN 'Delete Records'
								WHEN 'L' THEN 'Load Records'
								WHEN 'W' THEN 'Download Records'
								WHEN 'VA' THEN 'API Validate Access'
								WHEN 'S' THEN 'Read Group Records'
								ELSE 'N/A'
							 END
	
	RETURN @vDescOperationCRUD
END
GO

