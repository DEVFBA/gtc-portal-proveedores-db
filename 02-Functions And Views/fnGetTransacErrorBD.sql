USE PortalProveedores
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- fnGetTransacErrorBD
/* ==================================================================================*/	
PRINT 'Crea fnGetTransacErrorBD'

IF OBJECT_ID('[dbo].[fnGetTransacErrorBD]','FN') IS NOT NULL
       DROP FUNCTION [dbo].[fnGetTransacErrorBD]
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the error generated in a database transaction
Creation:	23-10-2021
Return 
			vError Varchar(Max)
Example:	
			Declare @vError Varchar(Max)
			SET @vError = dbo.fnGetTransacErrorBD()
			SELECT @vError
*/
CREATE FUNCTION [dbo].[fnGetTransacErrorBD]()
RETURNS VARCHAR(Max)
WITH ENCRYPTION AS
BEGIN
	Declare @vError Varchar(Max)
	
	SET @vError = ((SELECT	'|Error Number = '  + CAST(ERROR_NUMBER() AS VARCHAR(MAX)) +
							' |Error_Message = ' + CAST(ERROR_MESSAGE()AS VARCHAR (MAX)) +
							' |Error Procedure = ' + ISNULL( CAST(ERROR_PROCEDURE( )AS VARCHAR (MAX)),'') +
							' |Error Line =' + CAST(ERROR_LINE() AS VARCHAR (MAX)) +
							' |Error Severity = ' + CAST( ERROR_SEVERITY() AS VARCHAR (MAX))  +
							' |Error State = ' + CAST(ERROR_STATE() AS VARCHAR(MAX))))

	RETURN @vError
END
GO

