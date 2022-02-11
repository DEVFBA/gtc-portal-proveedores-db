USE PortalProveedores
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- [fnGetCodes]
/* ==================================================================================*/	
PRINT 'Crea fnGetCodes'

IF OBJECT_ID('[dbo].[fnGetCodes]','FN') IS NOT NULL
       DROP FUNCTION [dbo].fnGetCodes
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the Code of CRUD operation
Creation:	23-10-2021
Return 
			@iCode Int
Example:	
			Declare @iCode Int
			SET @iCode = dbo.fnGetCodes('Duplicate Record')
			SELECT @iCode
*/
CREATE FUNCTION [dbo].[fnGetCodes](@pvOperation Varchar(30))
RETURNS Int
WITH ENCRYPTION AS
BEGIN
	DECLARE @iCode Int
	DECLARE @iBDClassification SMALLINT = 1

	IF @pvOperation IN ('C','R','U','D','L','W')
	BEGIN
		SET @iCode = CASE @pvOperation
						WHEN 'Success' THEN 1100
						WHEN 'C' THEN 1101
						WHEN 'R' THEN 1102
						WHEN 'U' THEN 1103
						WHEN 'D' THEN 1104
						WHEN 'L' THEN 1105
						WHEN 'W' THEN 1106
					 END
	END
	ELSE
	BEGIN 
		SET @iCode = (SELECT Code FROM Security_Codes WHERE Id_Code_Classification = @iBDClassification AND  Description_TI = @pvOperation )
	END				
	
	RETURN @iCode
END
GO

